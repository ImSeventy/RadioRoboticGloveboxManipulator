#include <ESP8266WiFi.h>
#include <espnow.h>
#include "Wire.h"       
#include "I2Cdev.h"     
#include "MPU6050.h"    

uint8_t broadcastAddress[] = {0xF0, 0x08, 0xD1, 0xD2, 0xED, 0x38};


typedef struct CommunicationData {
    byte id;
    bool bluetoothOn;
    byte baseAngle;
    byte leftBaseAngle;
    byte shoulderAngle;
    byte leftShoulderAngle;
    byte elbowAngle;
    byte leftElbowAngle;
    byte wristAngle;
    byte leftWristAngle;
    byte rotationAngle;
    byte leftRotationAngle;
    byte clapsAngle;
    byte leftClapsAngle;  
    byte servoSpeed;
} CommunicationData;
CommunicationData communicationData;

int oldBase, oldElbow, oldClaps;


struct GyroData {
  byte rotation;
  byte wrist;
};
MPU6050 mpu;
GyroData gyroData;
GyroData oldGyroData;
int16_t ax, ay, az;
int16_t gx, gy, gz;

int buttonsPins[]  = {D0, D5, D6};  
bool buttonsStates[] = {LOW, LOW, LOW};
int lastButtonsStates[] = {LOW, LOW, LOW};
int gripperReading = 0;
int baseReading = 512;

unsigned long lastDebounceTimes[] = {0, 0, 0};
unsigned long debounceDelay = 50;
unsigned long lastGripperChangeTime = 0;
int GripperChangeDelay = 100;

unsigned long lastBaseIncreaseTime = 0;
unsigned long lastBaseDecreaseTime = 0;
int baseChangeDelay = 145;



void OnDataSent(uint8_t *mac_addr, uint8_t sendStatus) {
  Serial.print("Last Packet Send Status: ");
  if (sendStatus == 0){
    Serial.println("Delivery success");
  }
  else{
    Serial.println("Delivery fail");
  }
}

void setupButtonsPins() {
  for (int i; i < buttonsPins; i++) {
    pinMode(buttonsPins[i], INPUT);
  }
}

bool setupEspNow() {
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();

  if (esp_now_init() != 0) {
    return false;
  }

  esp_now_set_self_role(ESP_NOW_ROLE_CONTROLLER);
  esp_now_add_peer(broadcastAddress, ESP_NOW_ROLE_SLAVE, 1, NULL, 0);
  esp_now_register_send_cb(OnDataSent);
  esp_now_send(broadcastAddress, (uint8_t *) &communicationData, sizeof(communicationData));
  return true;
}


void setInitialPositions() {
  communicationData.shoulderAngle = 90;
  communicationData.elbowAngle = 90;
  communicationData.wristAngle = 180;
  communicationData.clapsAngle = 50;
  communicationData.rotationAngle = 90;
  communicationData.baseAngle = 90;
  communicationData.id = 2;
}
 
void setup() {
  setInitialPositions();
  Serial.begin(115200);
  Wire.begin();
  mpu.initialize();
  setupButtonsPins();

  if (!setupEspNow()) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }
}

void loop() {
    bool gripperButtonState = getButtonState(0);
    bool baseLeftButtonState = getButtonState(1);
    bool baseRightButtonState = getButtonState(2);

    changeReadingWithRespectToTime(gripperReading, GripperChangeDelay, lastGripperChangeTime, 100, 100, gripperButtonState, 1023);
    changeReadingWithRespectToTime(baseReading, baseChangeDelay, lastBaseIncreaseTime, 50, 0, baseRightButtonState, 1023);
    changeReadingWithRespectToTime(baseReading, baseChangeDelay, lastBaseDecreaseTime, -50, 0, baseLeftButtonState, 1023);

    GyroData newGyroData = getGyroData();
    int elbowReading = analogRead(A0);

    if (
        valueWithinRange(elbowReading, oldElbow, 10) ||
        valueWithinRange(gripperReading, oldClaps, 30) ||
        valueWithinRange(baseReading, oldBase, 30) ||
        valueWithinRange(newGyroData.rotation, oldGyroData.rotation, 5) ||
        valueWithinRange(newGyroData.wrist, oldGyroData.wrist, 5)
    ) {
      int elbowDebouncedVal = getDebouncedValue(elbowReading, oldElbow, 10);
      int elbowAngle = map(getValueWithinMinMax(elbowDebouncedVal, 10, 220), 10, 220, 0, 160);
      int baseAngle = map(getDebouncedValue(baseReading, oldBase, 30), 0, 1023, 15, 165);
      int wristAngle = map(getDebouncedValue(newGyroData.wrist, oldGyroData.wrist, 5), 0, 255, 0, 180);
      int rotationAngle = map(getDebouncedValue(newGyroData.rotation, newGyroData.rotation, 5), 0, 255, 180, 0);
      int clapsAngle = map(getDebouncedValue(gripperReading, oldClaps, 30), 0, 1023, 20, 90);
      
      sendHandServoAngles(baseAngle, elbowAngle, wristAngle, rotationAngle, clapsAngle);
      setOldReadings(baseReading, elbowReading, gyroData, gripperReading);
    }
}

void sendHandServoAngles(int baseAngle, int elbowAngle, int wristAngle, int rotationAngle, int clapsAngle) {
  communicationData.leftBaseAngle = baseAngle;
  communicationData.leftShoulderAngle = 75;
  communicationData.leftElbowAngle = elbowAngle;
  communicationData.leftWristAngle = wristAngle;
  communicationData.leftRotationAngle = rotationAngle;
  communicationData.leftClapsAngle = clapsAngle;
  communicationData.bluetoothOn = false;
  communicationData.id = 2;
  esp_now_send(broadcastAddress, (uint8_t *) &communicationData, sizeof(communicationData));
}

void setOldReadings(int base, int elbow, GyroData gyroData, int gripper) {
  oldElbow = elbow;
  oldClaps = gripper;
  oldBase = base;
  oldGyroData.wrist = gyroData.wrist;
  oldGyroData.rotation = gyroData.rotation;
}

GyroData getGyroData() {
  mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
  gyroData.rotation = map(ax, -17000, 17000, 0, 255);
  gyroData.wrist = map(ay, -17000, 17000, 0, 255); 

  return gyroData;
}
 
int getDebouncedValue(int newVal, int oldVal, int rangeVal) {
  return valueWithinRange(newVal, oldVal, rangeVal) ? newVal : oldVal;
}

bool valueWithinRange(int newVal, int oldVal, int rangeVal) {
  return newVal >= (oldVal + rangeVal) || newVal <= (oldVal - rangeVal);   
}

int getValueWithinMinMax(int value, int min, int max) {
  if (value > max) return max;

  if (value < min) return min;

  return value;
}

bool gyroDataChanged(GyroData gyroData) {
 return oldGyroData.wrist != gyroData.wrist || oldGyroData.rotation != gyroData.rotation;  
}

bool getButtonState(int buttonIndex) {
  int reading = digitalRead(buttonsPins[buttonIndex]);
  if (reading != lastButtonsStates[buttonIndex]) {
    lastDebounceTimes[buttonIndex] = millis();
  }
 
  if ((millis() - lastDebounceTimes[buttonIndex]) > debounceDelay) {
    if (reading != buttonsStates[buttonIndex]) {
      buttonsStates[buttonIndex] = reading;
    }
  }

  buttonsStates[buttonIndex] = reading;

  return buttonsStates[buttonIndex];
}

void changeReadingWithRespectToTime(int &reading, int delayTime, unsigned long &lastChangeTime, int increaseQuantity, int decreaseQuantity, bool state, int maxVal) {
  if (millis() - delayTime > lastChangeTime) {
    reading = state ? reading + increaseQuantity : reading - decreaseQuantity;
    reading = reading >= 0 ? reading : 0;
    reading = reading > maxVal ? maxVal : reading;
    lastChangeTime = millis();
  }
}
