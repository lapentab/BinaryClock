/* --------------------------------------------------------------------- */
/* -------------------------- A Binary Clock --------------------------- */
/* ------------------------- for the L3D Cube -------------------------- */
/* ------------------------ Written by lapentab ------------------------ */
/* --------------------------------------------------------------------- */
/* | This code works and is read like the binary clock sold by         | */
/* | ThinkGeek here: http://www.thinkgeek.com/product/59e0/            | */
/* | The clock will automatically scale to various sizes that are      | */
/* | divisble by 8. Values over 32 are untested, but should work       | */
/* | Colors are able to be set alongside cube width, and the program   | */
/* | will use the local system time.                                   | */
/* --------------------------------------------------------------------- */

// Side-note. This program was written while keeping in mind the number of draws.
// Measures have been taken to attempt to cut back on the number of draws made to the cube
// to make it more resource efficient.

import L3D.*;
L3D cube;

// Dimensions of the cube
int cw = 16;

// Color of the separating lines
int backgroundColor = color(70, 70, 70);

// Colors of the hour boxes
int hourTensColor = color(0, 205, 102);
int hourOnesColor = color(0, 255, 127);

// Colors of the minute boxes
int minuteTensColor = color(99, 184, 255);
int minuteOnesColor = color(79, 148, 205);

// Colors of the second boxes.
int secondTensColor = color(255, 48, 48);
int secondOnesColor = color(205, 0, 0);

// This is for padding, it is set automatically later.
int jitter;


void setup()
{
  if (cw == 8) jitter = 1;
  else jitter = 0;
  size(displayWidth, displayHeight, P3D);
  cube=new L3D(this, cw);
  cube.enableDrawing(); 
  cube.enableMulticastStreaming();  
  cube.enablePoseCube();
  drawInitial();
}

// To draw the first pass of the cube, used to cut back number of draws to hours/min.
void drawInitial() {

  background(0);

  // draws lines
  drawCube(cw, cw/8, cw-1, new PVector(0, jitter, 0), backgroundColor); //0
  drawCube(cw, cw/8, cw-1, new PVector(0, cw/8*2+jitter, 0), backgroundColor); //2
  drawCube(cw, cw/8, cw-1, new PVector(0, cw/8*4+jitter, 0), backgroundColor); //4
  drawCube(cw, cw/8, cw-1, new PVector(0, cw/8*6+jitter, 0), backgroundColor); // 6
  drawCube(cw, cw/8, cw-1, new PVector(0, cw+jitter, 0), backgroundColor); // 6

  // draws initial time
  drawLightsFromBinary(hour()/10, 0, hourTensColor);
  drawLightsFromBinary(hour()%10, 1, hourOnesColor);
  drawLightsFromBinary(minute()/10, 2, minuteTensColor);
  drawLightsFromBinary(minute()%10, 3, minuteOnesColor);
  drawLightsFromBinary(second()/10, 4, secondTensColor);
  drawLightsFromBinary(second()%10, 5, secondOnesColor);
}


// Corner is the bottom left corner. Depth is depth towards cw (increases)
void drawCube(int w, int h, int d, PVector corner, int voxelColor) {
  for (int i = 0; i < w; i++) {
    for (int j = 0; j < h; j++) {
      cube.line(new PVector(i+corner.x, corner.y-j, corner.z), new PVector(i+corner.x, corner.y-j, corner.z+d), voxelColor);
    }
  }
}

// This function will draw lights from a number. The number is converted
// into a binary string, then the string is parsed to see where to draw
// the appropriate 'on' boxes, and turn off boxes that should be off.
// segment is the x-'slot' to place the box in. For the clock, it is a
// grid of 6 x-slots, with segment 0 being the leftmost slot.
void drawLightsFromBinary(int number, int segment, int voxelColor) {
  String binary = Integer.toBinaryString(number);
  // pad the string so it is always 4 digits
  binary = String.format("%4s", binary).replace(' ', '0');
  for (int i=0; i<binary.length (); i++) {
    if (binary.charAt(binary.length()-i-1) == '1') { // If the digit is one, draw it
      drawCube(cw/8, cw/8, cw-1, new PVector((cw/8)*segment+(cw/8), cw/4*(4-i)-(cw/8)-jitter, 0), voxelColor);
    } else { // if not, darken the area
      drawCube(cw/8, cw/8, cw-1, new PVector((cw/8)*segment+(cw/8), cw/4*(4-i)-(cw/8)-jitter, 0), 0);
    }
  }
}

void draw()
{
  background(0);
  int hour = hour();
  int minute = minute();
  int second = second();
  if (second == 0) { // if the second is zero, there is a new minute, so redraw minutes.
    drawLightsFromBinary(minute/10, 2, minuteTensColor);
    drawLightsFromBinary(minute%10, 3, minuteOnesColor); 
    if (minute == 0) { // if the minute is zero, there is a new hour, so redraw hours.
      drawLightsFromBinary(hour/10, 0, hourTensColor);
      drawLightsFromBinary(hour%10, 1, hourOnesColor);
    }
  }
  drawLightsFromBinary(second/10, 4, secondTensColor);
  drawLightsFromBinary(second%10, 5, secondOnesColor);
}

