/*---------------------------------------------------------------------------

-------------
light barrier
-------------

this program tries to turn the arduino with attached
IR receiver and IR LEDs into one or up to six light barriers. 

the concept is quite simple: the senders are turned on
and off quickly, while each cycle the receivers measure
the delta value. if the delta is slow, the light beam
might be interrupted.


-----------------------------------------------------------------------------
*/

// configurable variables
int wait_time = 2;          
int threshold = 60;          
int num_of_instances = 4;    

// initialize variables
int rec_pre;
int rec_post;
int interrupted[6];
int ls_state = 0;
int delta;
int pressure;
int pressure_pin = 5;
int byte1;
int byte2;
int byte1_prev;
int byte2_prev;

// prepare serial and set necessary digital pins to output
void setup()
{
  Serial.begin(57600);
  for (int instance=0; instance < num_of_instances; instance++)
  {
    int led_pin = instance + 2; 
    pinMode(led_pin, OUTPUT);
  }
}

// start the actual program
void loop()
{
  // reset ls_state
  ls_state = 0;
  
  // we cycle through each instance of a light barrier
  for (int instance=0; instance < num_of_instances; instance++)
  { 
  
    //read analog before we turn LED on
    rec_pre = analogRead(instance);
    
    //we set the correct shift for the digital pins  
    int led_pin = instance + 2;
  
    // turn LED on 
    digitalWrite(led_pin, HIGH);
    
    // wait 
    delay(wait_time);
       
    // then read out analog value from receiver
    rec_post = analogRead(instance);
    delta = rec_post - rec_pre;
    delta = abs(delta);
       
    // convert delta to state
    if (delta < threshold)
    {
      interrupted[instance] = 1;
    }
    else
    {
      interrupted[instance] = 0;
    }
    
    // turn LED off after cycle
    digitalWrite(led_pin, LOW);
    
    // put all states into one byte
    ls_state = ls_state + (interrupted[instance] << instance);
  }
  
  // compare current state to previous
  if ( (analogRead(pressure_pin) > (pressure + 3)) || (analogRead(pressure_pin) < (pressure - 3)) )
  {
      pressure = analogRead(pressure_pin);
  }
  byte2 = pressure & 127;
  byte1 = pressure >> 7;
  byte1 += ( ls_state << 3 );
  byte1 += 128;
  
  if (byte1 != byte1_prev)
  {
    Serial.print(byte1, BYTE);
  }
  if (byte2 != byte2_prev)
  {
    Serial.print(byte2, BYTE);
  }
}
