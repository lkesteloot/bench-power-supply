
// To change PWM_PIN, you have to also change a bunch of the PWM code below.
static const int PWM_PIN = 3;
static const int DEBUG_PIN = 4;
static const int FB_V_PIN = A5;

static const int DEBUG_HZ = 10;
static const int DEBUG_V1 = 5;
static const int DEBUG_V2 = 15;
static const int ADC_VALUES = 1024;
static const int ADC_REF_V = 5;
static const int FB_R1 = 47;
static const int FB_R2 = 10;

void setup() {
  Serial.begin(9600);
  pinMode(PWM_PIN, OUTPUT);
  pinMode(DEBUG_PIN, OUTPUT);
  pinMode(A5, INPUT);
  
  // ~60 kHz
  TCCR2A = _BV(COM2A1) | _BV(COM2B1) | _BV(WGM21) | _BV(WGM20);
  TCCR2B = /*_BV(CS22) | _BV(CS21) | */_BV(CS20);
  OCR2B = 50;
}

int pwm = 0;
int count = 0;

void loop() {
  // Test square wave.
  int squareWave = (millis() * DEBUG_HZ / 500) % 2 == 0;

  // PID.
  int volt = ADC_VALUES/ADC_REF_V*FB_R2/(FB_R1 + FB_R2);
  int targetVoltage = (squareWave ? DEBUG_V1 : DEBUG_V2) * volt;
  //targetVoltage = (millis() / 10) % 21 * volt;
  //targetVoltage = 0*volt;
  int actualVoltage = analogRead(FB_V_PIN);
  int error = targetVoltage - actualVoltage;
  pwm += error/50;

  // pwm = (millis() * 10) % 256;

  // PWM 0 to 255:
  pwm = constrain(pwm, 0, 255);
  OCR2B = pwm;

  // Figure out sampling frequency.
  digitalWrite(DEBUG_PIN, count % 2 == 0);
  count++;
}
