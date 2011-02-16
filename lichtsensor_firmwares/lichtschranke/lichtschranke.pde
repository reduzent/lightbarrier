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
int state_byte = 0;
int prev_byte = 0;
int delta;

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
  // reset state_byte
  state_byte = 0;
  
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
    state_byte = state_byte + (interrupted[instance] << instance);
  }
  
  // compare current state to previous
  if (state_byte != prev_byte)
  {
    Serial.print(state_byte, BYTE);
  }
  
  // remember state_byte for next cycle
  prev_byte = state_byte;
}
