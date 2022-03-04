//---------------------------------------------------------------------------------------------------------------------
// Filename: Arduino_Ultrasonic Measure
// Description: Contains running code for arduino uno up to 4 attached attached sensors.
// Authors: Dakotah Makortoff
//---------------------------------------------------------------------------------------------------------------------

#define TRIG1 8 // Trigger Pin of Ultrasonic Sensor 1
#define TRIG2 9 // Trigger Pin of Ultrasonic Sensor 2
#define TRIG3 10 // Trigger Pin of Ultrasonic Sensor 3
#define TRIG4 11 // Trigger Pin of Ultrasonic Sensor 4

#define ECHO1 4 // Echo Pin of Ultrasonic Sensor 1
#define ECHO2 5 // Echo Pin of Ultrasonic Sensor 2
#define ECHO3 6 // Echo Pin of Ultrasonic Sensor 3
#define ECHO4 7 // Echo Pin of Ultrasonic Sensor 4


const int LEDPin = 13;
const int arduinoNum = 1;

class Sensor{
  private:
    int pinEcho;// pin that reads IO
    int pinTrig;// Trigger device
    char* HWID;// Hardware ID for API
    int thresh;// base distance 
  public:
    Sensor(int pinEcho, int pinTrig, char* HWID){
      this->pinEcho = pinEcho;//set pin properties
      this->pinTrig = pinTrig;
      this->HWID = HWID;
      pinMode(pinEcho, INPUT);
      pinMode(pinTrig, OUTPUT);
      }
         
   long microsecondsToCentimeters(long microseconds) {
    return microseconds / 29 / 2; //Microseconds divided by cm/microseconds (also /2 for back and forth)
   }
   int distanceCalc(){
     long duration;
     int cm;
     digitalWrite(pinTrig, LOW); // ensure trigger is off
     delayMicroseconds(2);
     digitalWrite(pinTrig, HIGH);//trigger all
     delayMicroseconds(10);
     digitalWrite(pinTrig , LOW);
     duration = pulseIn(pinEcho, HIGH); //check specified pin  
     cm = microsecondsToCentimeters(duration);
     return(cm);
  }
  
  void setThresh(){
     int cycles = 9;
     int overall;
     for(int i=0; i<cycles; i++){
      int current = distanceCalc();
      overall += current; 
      }
     overall=overall/cycles;
     this->thresh = overall;
    }
    
  void checkThresh(){
    int distance = distanceCalc();
    int threshError = (thresh * 0.70);
    if(threshError>distance){
      Serial.print(HWID);
      Serial.println();
      delay(1000);
      }
  }
};
 

Sensor sens1 = Sensor(ECHO1, TRIG1, "A1S1"); // sensor1 has pins 4 as echo and 8 as trig
Sensor sens2 = Sensor(ECHO2, TRIG2, "A1S2");// sensor2 has pins 5 as echo and 9 as trig
Sensor sens3 = Sensor(ECHO3, TRIG3, "A1S3");// sensor3 has pins 6 as echo and 10 as trig
Sensor sens4 = Sensor(ECHO4, TRIG4, "A1S4");// sensor4 has pins 7 as echo and 11 as trig

void setup() {
   pinMode(13, OUTPUT);
   digitalWrite(13, LOW);
   Serial.begin(9600); // Starting Serial Terminal
   //setup sensor threshholds
   
   sens1.setThresh();
   sens2.setThresh();
   sens3.setThresh();
   sens4.setThresh();
   
}

void loop() {
  sens1.checkThresh();
  sens2.checkThresh();
  sens3.checkThresh();
  sens4.checkThresh();
}
