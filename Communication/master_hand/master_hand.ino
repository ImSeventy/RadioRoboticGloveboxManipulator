#include <ESP8266WiFi.h>
#include <espnow.h>
#include <SoftwareSerial.h>
#include "Wire.h"       
#include "I2Cdev.h"     
#include "MPU6050.h"      

uint8_t broadcastAddress[] = {0xF0, 0x08, 0xD1, 0xD2, 0xED, 0x38};

enum MessageType {PAIRING, DATA,};
MessageType messageType;

int16_t ax, ay, az;
int16_t gx, gy, gz;


MPU6050 mpu;

struct GyroData {
  byte rotation;
  byte wrist;
};

GyroData gyroData;
GyroData oldGyroData;

SoftwareSerial sUART(D3, D4);
SoftwareSerial Bluetooth(D7, D8);

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


int oldShoulder, oldElbow, oldWrist, oldClaps, oldBase;

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



bool appIsRunning = false;
long lastAppReadingTime = 0;
long appTimeOut = 30000;
String bluetoothData;
int servoAngles[] = {90, 90, 90, 180, 90, 20, 90, 90, 90, 180, 90, 20};
int stepIndex = 0;
int steps[12][50];

int32_t getWiFiChannel(const char *ssid) {
  if (int32_t n = WiFi.scanNetworks()) {
      for (uint8_t i=0; i<n; i++) {
          if (!strcmp(ssid, WiFi.SSID(i).c_str())) {
              return WiFi.channel(i);
          }
      }
  }
  return 0;
}


void OnDataSent(uint8_t *mac_addr, uint8_t sendStatus) {
  Serial.print("Last Packet Send Status: ");
  if (sendStatus == 0){
    Serial.println("Delivery success");
  }
  else{
    Serial.println("Delivery fail");
  }
}

void setInitialPositions() {
  communicationData.id = 1;
  communicationData.bluetoothOn = false;
  communicationData.shoulderAngle = 90;
  communicationData.elbowAngle = 90;
  communicationData.wristAngle = 180;
  communicationData.clapsAngle = 50;
  communicationData.rotationAngle = 90;
  communicationData.baseAngle = 90;
  communicationData.leftShoulderAngle = 90;
  communicationData.leftElbowAngle = 97;
  communicationData.leftWristAngle = 180;
  communicationData.leftClapsAngle = 0;
  communicationData.leftRotationAngle = 90;
  communicationData.leftBaseAngle = 90;
  communicationData.leftClapsAngle = 20;
  communicationData.servoSpeed = 10;
 
}

void setupButtonsPins() {
  for (int i; i < 3; i++) {
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
 
void setup() {
  setInitialPositions();
  Serial.begin(4800);
  sUART.begin(1200);
  Bluetooth.begin(9600);
  Wire.begin();
  mpu.initialize();
  setupButtonsPins();

  if (!setupEspNow()) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

}
 
void loop() {
  handleAppReadings();
  handleHandReadings();
}

void handleAppReadings() {
    if (Bluetooth.available() <= 0) {
      
      if ( (millis() - appTimeOut) > lastAppReadingTime ) {
          appIsRunning = false;
      }

      return;
    }
    lastAppReadingTime = millis();
    appIsRunning = true;
    bluetoothData = Bluetooth.readStringUntil('\n');

    handleAppLiveData(bluetoothData);
    handleAutomationStepsData(bluetoothData);

    if (bluetoothData.startsWith("ss")) {
      int servoSpeed = bluetoothData.substring(2, bluetoothData.length()).toInt();
      communicationData.servoSpeed = servoSpeed;
    }

    sendAppServoAngles();

    if (bluetoothData.startsWith("end-step")) {
      stepIndex++;
    }

    if (bluetoothData.startsWith("start")) {
      startAutomation();
    }

    if ( bluetoothData.startsWith("clear-steps")) {
      clearSteps();
    }

    if (bluetoothData.startsWith("go-live")) {
          appIsRunning = false;
    }
}

void handleAppLiveData(String data) {
    for (int i = 12; i > 0; i--) {
      String servoName = String(i) + "s";
      if(data.startsWith(servoName)) {
        int servoReading = data.substring(servoName.length(), data.length()).toInt();
        servoAngles[i - 1] = servoReading;
        break;
      }
    }
}

void handleAutomationStepsData(String data) {
    for (int i = 12; i > 0; i--) {
      String servoName = "auto" + String(i) + "s";
      if(data.startsWith(servoName)) {
        int servoReading = data.substring(servoName.length(), data.length()).toInt();
        steps[i - 1][stepIndex] = servoReading;
        break;
      }
    }
}

void sendAppServoAngles() {
  communicationData.baseAngle = servoAngles[0];
  communicationData.shoulderAngle = servoAngles[1];
  communicationData.elbowAngle = servoAngles[2];
  communicationData.wristAngle = servoAngles[3];
  communicationData.rotationAngle = servoAngles[4];
  communicationData.clapsAngle = servoAngles[5];

  communicationData.leftBaseAngle = servoAngles[6];
  communicationData.leftShoulderAngle = servoAngles[7];
  communicationData.leftElbowAngle = servoAngles[8];
  communicationData.leftWristAngle = servoAngles[9];
  communicationData.leftRotationAngle = servoAngles[10];
  communicationData.leftClapsAngle = servoAngles[11];
  communicationData.bluetoothOn = true;
  esp_now_send(broadcastAddress, (uint8_t *) &communicationData, sizeof(communicationData));
}

void clearSteps() {
  memset(steps, 0, sizeof(steps));
  stepIndex = 0;
}

void handleHandReadings() {
    if (appIsRunning) return;
      
    bool gripperButtonState = getButtonState(0);
    bool baseLeftButtonState = getButtonState(1);
    bool baseRightButtonState = getButtonState(2);

    changeReadingWithRespectToTime(gripperReading, GripperChangeDelay, lastGripperChangeTime, 100, 100, gripperButtonState, 1023);
    changeReadingWithRespectToTime(baseReading, baseChangeDelay, lastBaseIncreaseTime, 50, 0, baseRightButtonState, 1023);
    changeReadingWithRespectToTime(baseReading, baseChangeDelay, lastBaseDecreaseTime, -50, 0, baseLeftButtonState, 1023);

    GyroData newGyroData = getGyroData();
    int elbowReading = analogRead(A0);
    
    if (
        valueWithinRange(elbowReading, oldElbow, 5) ||
        valueWithinRange(gripperReading, oldClaps, 30) ||
        valueWithinRange(baseReading, oldBase, 30) ||
        valueWithinRange(newGyroData.rotation, oldGyroData.rotation, 5) ||
        valueWithinRange(newGyroData.wrist, oldGyroData.wrist, 5)
      ) {
        int elbowDebouncedVal = getDebouncedValue(elbowReading, oldElbow, 5);
        int elbowAngle = map(getValueWithinMinMax(elbowDebouncedVal, 10, 450), 10, 210, 0, 160);
        int wristAngle = map(getDebouncedValue(newGyroData.wrist, oldGyroData.wrist, 5), 0, 255, 0, 180);
        int rotationAngle = map(getDebouncedValue(newGyroData.rotation, oldGyroData.rotation, 5), 0, 255, 180, 0);
        int clapsAngle = map(getDebouncedValue(gripperReading, oldClaps, 30), 0, 1023, 50, 120);
        int baseAngle = map(getDebouncedValue(baseReading, oldBase, 30), 0, 1023, 15, 165);

        sendHandServoAngles(baseAngle, elbowAngle, wristAngle, rotationAngle, clapsAngle);
        setOldReadings(baseReading, elbowReading, gyroData, gripperReading);
    }
}

void sendHandServoAngles(int baseAngle, int elbowAngle, int wristAngle, int rotationAngle, int clapsAngle) {
  Serial.print(elbowAngle);
  communicationData.leftBaseAngle = baseAngle;
  communicationData.leftShoulderAngle = 97;
  communicationData.leftElbowAngle = elbowAngle;
  communicationData.leftWristAngle = wristAngle;
  communicationData.leftRotationAngle = rotationAngle;
  communicationData.leftClapsAngle = clapsAngle;
  communicationData.bluetoothOn = false;
  communicationData.id = 1;
  esp_now_send(broadcastAddress, (uint8_t *) &communicationData, sizeof(communicationData));
}

void setOldReadings(int base, int elbow, GyroData gyroData, int gripper) {
  oldElbow = elbow;
  oldClaps = gripper;
  oldBase = base;
  oldGyroData.wrist = gyroData.wrist;
  oldGyroData.rotation = gyroData.rotation;
}

int getDebouncedValue(int newVal, int oldVal, int rangeVal) {
  return valueWithinRange(newVal, oldVal, rangeVal) ? newVal : oldVal;
}

bool valueWithinRange(int newVal, int oldVal, int rangeVal) {
  return newVal >= (oldVal + rangeVal) || newVal <= (oldVal - rangeVal);   
}

bool gyroDataChanged(GyroData gyroData) {
 return oldGyroData.wrist != gyroData.wrist || oldGyroData.rotation != gyroData.rotation;  
}

int getValueWithinMinMax(int value, int min, int max) {
  if (value > max) return max;

  if (value < min) return min;

  return value;
}

GyroData getGyroData() {
  mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
  gyroData.rotation = map(ax, -17000, 17000, 0, 255);
  gyroData.wrist = map(ay, -17000, 17000, 0, 255); 

  return gyroData;
}


void startAutomation() {
  while (bluetoothData != "stop") { 
    for (int i = 0; i <= stepIndex - 1; i++) {
      if (Bluetooth.available() > 0) {
        bluetoothData = Bluetooth.readStringUntil('\n');
        if ( bluetoothData == "pause") {
          while (bluetoothData != "resume") {
            if (Bluetooth.available() > 0) {
              bluetoothData = Bluetooth.readStringUntil('\n');
              if ( bluetoothData == "stop") {     
                break;
              }
            }
          delay(1000);
          }
        }
      }
      sendStepAngle(i);
      }
  }
}

void sendStepAngle(int currentStepIndex) {
  communicationData.baseAngle = steps[0][currentStepIndex];
  communicationData.shoulderAngle = steps[1][currentStepIndex];
  communicationData.elbowAngle = steps[2][currentStepIndex];
  communicationData.wristAngle = steps[3][currentStepIndex];
  communicationData.rotationAngle = steps[4][currentStepIndex];

  communicationData.leftBaseAngle = steps[6][currentStepIndex];
  communicationData.leftShoulderAngle = steps[7][currentStepIndex];
  communicationData.leftElbowAngle = steps[8][currentStepIndex];
  communicationData.leftWristAngle = steps[9][currentStepIndex];
  communicationData.leftRotationAngle = steps[10][currentStepIndex];
  communicationData.bluetoothOn = true;

  esp_now_send(broadcastAddress, (uint8_t *) &communicationData, sizeof(communicationData));
  delay(2000);
  communicationData.clapsAngle = steps[5][currentStepIndex];
  communicationData.leftClapsAngle = steps[11][currentStepIndex];
  communicationData.bluetoothOn = true;
  esp_now_send(broadcastAddress, (uint8_t *) &communicationData, sizeof(communicationData));
  delay(1500);
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
