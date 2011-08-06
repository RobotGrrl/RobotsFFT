/*
FFT of the Input Mic Woopwoop
-----------------------------
RobotGrrl.com
*/

import ddf.minim.analysis.*;
import ddf.minim.*;

// Audio
Minim minim;
FFT fftLog;
AudioInput input;

// Variables for the canvas & ellipses
int canvasW = 1024;
int canvasH = 600;
int sizew = 20;
int sizeh = 15;

float[][] section_t = new float[5][6];
float[][] section_t0 = new float[5][6];

float[] average_t = new float[5];
float[] average_t0 = new float[5];

float[] values_t = new float[30];
float[] values_t0 = new float[30];

float avg_t = 0.0;
float avg_t0 = 0.0;

int beatNum = 0;

int column = 0;
int row = 0;

int recordedMillis = 0;//100;

void setup() {
  
  // Woo!
  size(canvasW, canvasH);
  background(0);
  
  // Start the audio
  minim = new Minim(this);
  input = minim.getLineIn(Minim.STEREO, 2048);
  
  // Start the FFT
  fftLog = new FFT(input.bufferSize(), input.sampleRate());
  fftLog.logAverages(22, 3);
  fftLog.window(FFT.HAMMING);
  
  // Settings for drawing
  colorMode(HSB, 100);
  ellipseMode(CENTER);
  smooth();
  noStroke();
  
}

void draw() {

  // Calculate the FFT from the input
  fftLog.forward(input.mix);
        
  column = 0; 
  row = 0;  
  avg_t0 = avg_t;
         
  // Iterate through each of the FFT "points"
  for(int i = 0; i < fftLog.avgSize(); i++) {         
    
    if(i%6 == 0 && i!= 0) {
      column++;
      row = 0;
    }
    
    //println("i: " + i + " [" + column + "][" + row + "]");
    
    section_t0[column][row] = section_t[column][row];
    section_t[column][row] = sqrt(sqrt(fftLog.getAvg(i)))*150;
    
    average_t0[column] += section_t0[column][row];
    average_t[column] += section_t[column][row];
    
    values_t0[i] = values_t[i];
    values_t[i] = sqrt(sqrt(fftLog.getAvg(i)))*150;
    
    avg_t += values_t[i];
    
    // If i is < the average size - 29, clean the
    // screen and draw a black rectangle
    if(i < fftLog.avgSize() - 29) {
      fill(color(0,0,0,20));
      rect(0,0,canvasW,canvasH);
    }
          
    // Get the data from the FFT and colour it
    float amp = sqrt(sqrt(fftLog.getAvg(i)))*150;
    float h = i * 100/fftLog.avgSize();
    h -= 10;
    h = 100 - h;
    float s = 70;
    float b = amp/3 * 100;
    float a = 100;
    fill(color(h,s,b,a));
       
    // Calculate the x&y, draw the ellipse
    float x = i*24 + 150;
    float y = canvasH - amp-50;
    ellipse(x, y, sizew, sizeh);
    
    row++;
    
  }
  
  for(int i=0; i<5; i++) {
    average_t0[i] /= 5;
    average_t[i] /= 5;
  }
  
  /*
  for(int i=0; i<5; i++) {
    //println(average_t0[i] + " vs " + average_t[i]);
    float diff = average_t0[i]-average_t[i];
    if(i == 4) {
      //println(diff);
      if(abs(diff) > 50) println("beat");
    } 
  }
  */
  
  float diff = avg_t0-avg_t;
  //println(diff);
    
  if(abs(diff) > 6000 && millisElapsed() >= 100) {
    //println("beat");
    //println(diff);
    
    if(beatNum%4 == 0) {
      // turn
      println("turn");
      
    } else {
      println("action");
    }
    
    recordedMillis = millis();
    beatNum++;
  }
  
  //println("pause");
  
}

int millisElapsed() {
 return abs(recordedMillis-millis()); 
}

void stop() {
  // Make sure to close everything!
  input.close();
  super.stop();
}

