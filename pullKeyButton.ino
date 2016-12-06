#include <Servo.h>

Servo M1;
enum MotorState {
  keyIdle,
  keydown,
  keydownEStop,
  keyUpWithButton,
  keyDownStop,
  keyUp
};
MotorState motorState = keyIdle;

int motorPin = 3;
int buttonSensor = 4;
int buttonSensor2 = 5;
int vcc = 13;

static unsigned long processTime;
static unsigned long lastPressTime;
#define keyDownTime 16000
#define keyDownStopTime 20000
#define keyUpTime 17000
#define debounceTime 200


void setup() {

  pinMode(buttonSensor, INPUT);
  pinMode(buttonSensor2, INPUT);
  pinMode(vcc, OUTPUT);
  digitalWrite(vcc, HIGH);
  Serial.begin(9600);

  Serial.println("Start Listening");
}

void loop() {

  if (motorState == keyIdle) {
    Serial.println("keyIdle");
    if (digitalRead(buttonSensor) == LOW) {
      Serial.println("keyIdle: BUtton pressed");
      lastPressTime = millis();
      motorState = keydown;
      M1.attach(motorPin);
      M1.write(180);
      processTime = millis();
    }
  } else if (motorState == keydown) {
    Serial.println("keydown");
    unsigned long currentTime = millis();
    if (digitalRead(buttonSensor) == LOW && (currentTime - lastPressTime) > debounceTime ) {
      motorState = keydownEStop;
      M1.write(90);
      M1.detach();
    } else if ((currentTime - processTime) > keyDownTime) {
      M1.write(90);
      M1.detach();
      motorState = keyDownStop;
      processTime = millis();
    }
  } else if (motorState == keyDownStop) {
    Serial.println("keyDownStop");
    unsigned long currentTime = millis();
    if (currentTime - processTime > keyDownStopTime) {
      M1.attach(motorPin);
      M1.write(0);
      motorState = keyUp;
      processTime = millis();
    }
  } else if (motorState == keyUp) {
    Serial.println("keyUp");
    unsigned long currentTime = millis();
    if (digitalRead(buttonSensor) == LOW) {
      motorState = keydownEStop;
      M1.write(90);
      M1.detach();
    } else if (currentTime - processTime > keyUpTime) {
      M1.write(90);
      M1.detach();
      motorState = keyIdle;
    }
  } else if (motorState == keydownEStop) {
    Serial.println("keydownEStop");
    if (digitalRead(buttonSensor2) == HIGH) {
      motorState = keyUpWithButton;
      M1.attach(motorPin);
      M1.write(0);
    }
  } else if (motorState == keyUpWithButton) {
    Serial.println("keyUpWithBUtton");
    if (digitalRead(buttonSensor2) == LOW) {
      M1.write(90);
      M1.detach();
      motorState = keyIdle;
    }
  }
}
