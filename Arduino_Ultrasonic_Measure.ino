const int trigPin = 8; // Trigger Pin of Ultrasonic Sensor
const int echoS1 = 7; // Echo Pin of Ultrasonic Sensor 1
const int echoS2 = 6; // Echo Pin of Ultrasonic Sensor 2
const int echoS3 = 5; // Echo Pin of Ultrasonic Sensor 3
const int echoS4 = 4; // Echo Pin of Ultrasonic Sensor 4

void setup() {
   Serial.begin(9600); // Starting Serial Terminal
}

void loop() {
  long currentDistance;
   pinMode(trigPin, OUTPUT);   pinMode(echoS1, INPUT); 
   pinMode(echoS2, INPUT); 
   pinMode(echoS3, INPUT); 
   pinMode(echoS4, INPUT); 

   currentDistance = distanceCalc(echoS1);
   Serial.print(currentDistance);
   Serial.print("cm - Arduino 1, Sensor 1");
   Serial.println();

   currentDistance =  distanceCalc(echoS2);
   Serial.print(currentDistance);
   Serial.print("cm - Arduino 1, Sensor 2");
   Serial.println();

   currentDistance = distanceCalc(echoS3);
   Serial.print(currentDistance);
   Serial.print("cm - Arduino 1, Sensor 3");
   Serial.println();

   currentDistance = distanceCalc(echoS4);
   Serial.print(currentDistance);
   Serial.print("cm - Arduino 1, Sensor 4");
   Serial.println();

   delay(1000);
}

long microsecondsToCentimeters(long microseconds) {
   return microseconds / 29 / 2; //Microseconds divided by cm/microseconds (also /2 for back and forth)
}

long distanceCalc(int echoPin){
   long cm, duration;
   digitalWrite(trigPin, LOW); // ensure trigger is off
   delayMicroseconds(2);
   digitalWrite(trigPin, HIGH);//trigger all
   delayMicroseconds(10);
   digitalWrite(trigPin , LOW);
   duration = pulseIn(echoPin, HIGH); //check specified pin  
   cm = microsecondsToCentimeters(duration);
   return(cm);
  }
