#include <WiFi.h>
#include <esp_now.h>
#include <Wire.h>
#include <ESP32Servo.h>
#include <Adafruit_PWMServoDriver.h>
String success;


TwoWire DriverI2C = TwoWire(0);
Adafruit_PWMServoDriver servoDriver = Adafruit_PWMServoDriver(0x40, DriverI2C);
#define USMIN  565
#define USMAX  2350



long lastServosChangeTime = 0;
long servoAngleChangeTimeDelay = 100;
int currentServoReading[12] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
int oldWantedAngles[] = {90, 90, 90, 180, 0, 90, 90, 90, 90, 180, 0, 90};



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

CommunicationData incomingLeftReadings;
CommunicationData incomingRightReadings;
CommunicationData tempData;

void OnDataSent(const uint8_t *mac_addr, esp_now_send_status_t status) {
  Serial.print("\r\nLast Packet Send Status:\t");
  Serial.println(status == ESP_NOW_SEND_SUCCESS ? "Delivery Success" : "Delivery Fail");
  if (status ==0){
    success = "Delivery Success :)";
  }
  else{
    success = "Delivery Fail :(";
  }
}

void OnDataRecv(const uint8_t * mac, const uint8_t *incomingData, int len) {
  memcpy(&tempData, incomingData, sizeof(tempData));
  if (tempData.id == 1) {
    memcpy(&incomingLeftReadings, incomingData, sizeof(incomingLeftReadings));
  } else {
    memcpy(&incomingRightReadings, incomingData, sizeof(incomingRightReadings));
  }
  Serial.print("Bytes received: ");
  Serial.println(len);
  Serial.print("shoulder received: ");
  Serial.println(incomingLeftReadings.leftShoulderAngle);
  Serial.print("elbow received: ");
  Serial.println(incomingLeftReadings.leftElbowAngle);

}

void setInitialAngles() {
  incomingLeftReadings.shoulderAngle = 90;
  incomingLeftReadings.elbowAngle = 90;
  incomingLeftReadings.wristAngle = 180;
  incomingLeftReadings.clapsAngle = 50;
  incomingLeftReadings.rotationAngle = 90;
  incomingLeftReadings.baseAngle = 90;
  incomingLeftReadings.leftShoulderAngle = 90;
  incomingLeftReadings.leftElbowAngle = 90;
  incomingLeftReadings.leftWristAngle = 180;
  incomingLeftReadings.leftClapsAngle = 0;
  incomingLeftReadings.leftRotationAngle = 90;
  incomingLeftReadings.leftBaseAngle = 90;
  incomingLeftReadings.leftClapsAngle = 20;
  incomingLeftReadings.servoSpeed = 10;

  incomingRightReadings.shoulderAngle = 90;
  incomingRightReadings.elbowAngle = 90;
  incomingRightReadings.wristAngle = 180;
  incomingRightReadings.clapsAngle = 50;
  incomingRightReadings.rotationAngle = 90;
  incomingRightReadings.baseAngle = 90;
}

void setupServoDriver() {
  DriverI2C.setPins(14, 15);
  DriverI2C.begin();
  servoDriver.begin();
  servoDriver.setOscillatorFrequency(27000000);
  servoDriver.setPWMFreq(50);
}

bool setupEspNow() {
  WiFi.mode(WIFI_STA);

  if (esp_now_init() != ESP_OK) {
    return false;
  }

  esp_now_register_recv_cb(OnDataRecv);
}

void setup() {

  setupServoDriver();
  Serial.begin(115200);
  Serial.setDebugOutput(true);
  Serial.println();

  if (!setupEspNow()) {
    Serial.println("Error initializing ESP-NOW");
    return;
  }

  Serial.println("parking");
  setInitialAngles();
  applyServoAngles();
  Serial.println("parked");
  delay(3000);
  

}

void loop() {
  writeServoAngle(5, incomingLeftReadings.bluetoothOn ? incomingLeftReadings.clapsAngle : incomingRightReadings.clapsAngle);
  writeServoAngle(11, incomingLeftReadings.leftClapsAngle);
  if (millis() - servoAngleChangeTimeDelay > lastServosChangeTime) {
      moveAllServosWithSpeed(incomingLeftReadings.servoSpeed);
     lastServosChangeTime = millis();
  }
}

void writeServoAngle(int servoNum, int angle) {
  int microSeconds = map(angle, 0, 180, USMIN, USMAX);
  servoDriver.writeMicroseconds(servoNum, microSeconds);
}

void applyServoAngles() {
    if (incomingLeftReadings.bluetoothOn) {

      currentServoReading[0] = incomingLeftReadings.baseAngle;
      currentServoReading[1] = incomingLeftReadings.shoulderAngle;
      currentServoReading[2] = incomingLeftReadings.elbowAngle;
      currentServoReading[3] = incomingLeftReadings.wristAngle;
      currentServoReading[4] = incomingLeftReadings.rotationAngle;
      currentServoReading[5] = incomingLeftReadings.clapsAngle;

      writeServoAngle(0, incomingLeftReadings.baseAngle);
      writeServoAngle(1, incomingLeftReadings.shoulderAngle);
      writeServoAngle(2, incomingLeftReadings.elbowAngle);
      writeServoAngle(3, incomingLeftReadings.wristAngle);
      writeServoAngle(4, incomingLeftReadings.rotationAngle);
      writeServoAngle(5, incomingLeftReadings.clapsAngle);
    } else {
      currentServoReading[0] = incomingRightReadings.baseAngle;
      currentServoReading[1] = incomingRightReadings.shoulderAngle;
      currentServoReading[2] = incomingRightReadings.elbowAngle;
      currentServoReading[3] = incomingRightReadings.wristAngle;
      currentServoReading[4] = incomingRightReadings.rotationAngle;
      currentServoReading[5] = incomingRightReadings.clapsAngle;

      writeServoAngle(0, incomingRightReadings.baseAngle);
      writeServoAngle(1, incomingRightReadings.shoulderAngle);
      writeServoAngle(2, incomingRightReadings.elbowAngle);
      writeServoAngle(3, incomingRightReadings.wristAngle);
      writeServoAngle(4, incomingRightReadings.rotationAngle);
      writeServoAngle(5, incomingRightReadings.clapsAngle);
    }


  currentServoReading[6] = incomingLeftReadings.leftBaseAngle;
  currentServoReading[7] = incomingLeftReadings.leftShoulderAngle;
  currentServoReading[8] = incomingLeftReadings.leftElbowAngle;
  currentServoReading[9] = incomingLeftReadings.leftWristAngle;
  currentServoReading[10] = incomingLeftReadings.leftRotationAngle;
  currentServoReading[11] = incomingLeftReadings.leftClapsAngle;

  writeServoAngle(6, incomingLeftReadings.leftBaseAngle);
  writeServoAngle(7, incomingLeftReadings.leftShoulderAngle);
  writeServoAngle(8, incomingLeftReadings.leftElbowAngle);
  writeServoAngle(9, incomingLeftReadings.leftWristAngle);
  writeServoAngle(10, incomingLeftReadings.leftRotationAngle);
  writeServoAngle(11, incomingLeftReadings.leftClapsAngle);
}

void moveAllServosWithSpeed(int movementSpeed) {
    if (incomingLeftReadings.bluetoothOn) {
      moveServoWithSpeed(0, incomingLeftReadings.baseAngle, movementSpeed);
      moveServoWithSpeed(1, incomingLeftReadings.shoulderAngle, movementSpeed);
      moveServoWithSpeed(2, incomingLeftReadings.elbowAngle, movementSpeed);
      moveServoWithSpeed(3, incomingLeftReadings.wristAngle, movementSpeed);
      moveServoWithSpeed(4, incomingLeftReadings.rotationAngle, movementSpeed);
    } else {
      moveServoWithSpeed(0, incomingRightReadings.baseAngle, movementSpeed);
      moveServoWithSpeed(1, incomingRightReadings.shoulderAngle, movementSpeed);
      moveServoWithSpeed(2, incomingRightReadings.elbowAngle, movementSpeed);
      moveServoWithSpeed(3, incomingRightReadings.wristAngle, movementSpeed);
      moveServoWithSpeed(4, incomingRightReadings.rotationAngle, movementSpeed);
    }
    
    moveServoWithSpeed(6, incomingLeftReadings.leftBaseAngle, movementSpeed);
    moveServoWithSpeed(7, incomingLeftReadings.leftShoulderAngle, movementSpeed);
    moveServoWithSpeed(8, incomingLeftReadings.leftElbowAngle, movementSpeed);
    moveServoWithSpeed(9, incomingLeftReadings.leftWristAngle, movementSpeed);
    moveServoWithSpeed(10, incomingLeftReadings.leftRotationAngle, movementSpeed);
}

void moveServoWithSpeed(int servoIndex, int wantedAngle, int movementSpeed) {
  int currentServoAngle = currentServoReading[servoIndex];
  int oldWantedAngle = oldWantedAngles[servoIndex];
  int wantedAngleDiff = wantedAngle - oldWantedAngle;
  if (wantedAngleDiff <= 4 && wantedAngleDiff >= -4) {
      wantedAngle = oldWantedAngle;
  }
  if (currentServoAngle == wantedAngle) return;
  oldWantedAngles[servoIndex] = wantedAngle;

  
  int newServoAngle = currentServoAngle >= wantedAngle + movementSpeed ? currentServoAngle - movementSpeed : currentServoAngle + movementSpeed;
  int angleDiff = wantedAngle - newServoAngle;
  if (angleDiff < 0 && angleDiff > - movementSpeed) {
    newServoAngle = wantedAngle ; 
  }

  if (angleDiff > 0 && angleDiff < movementSpeed) {
    newServoAngle = wantedAngle;  
  }
  
  currentServoReading[servoIndex] = newServoAngle;
  writeServoAngle(servoIndex, newServoAngle);
}