#include <stdlib.h>
#include <sys/types.h>
#include <libgte.h>
#include <libetc.h>
#include <libgpu.h>

#define VIDEO_MODE 0
#define SCREEN_RES_X 320
#define SCREEN_RES_Y 240
#define SCREEN_CENTER_X (SCREEN_RES_X >> 1) // bit shifting for division, this is divided by 2
#define SCREEN_CENTER_Y (SCREEN_RES_Y >> 1)
#define SCREEN_Z 400

#define OT_LENGTH 512
#define NUM_VERTICES 8
#define NUM_FACES 12


///////////////////////////////////////////////////////////////////////////////////////////////////
// Cube vertices and face indices
///////////////////////////////////////////////////////////////////////////////////////////////////
SVECTOR vertices[] = {
	{ -128, -128, -128 },
	{  128, -128, -128 },
	{  128, -128,  128 },
	{ -128, -128,  128 },
	{ -128,  128, -128 },
	{  128,  128, -128 },
	{  128,  128,  128 },
	{ -128,  128,  128 }
};

// Triangle faces
short faces[] = {
	0, 3, 2,            // top
	0, 2, 1,            // top
	4, 0, 1,            // front
	4, 1, 5,          // front
	7, 4, 5,         // bottom
	7, 5, 6,         // bottom
	5, 1, 2,         // right
	5, 2, 6,         // right
	2, 3, 7,         // back
	2, 7, 6,         // back
	0, 4, 7,         // left
	0, 7, 3          // left
};

///////////////////////////////////////////////////////////////////////////////////////////////////
// Declarations and global variables
///////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct {
  DRAWENV draw[2];   // Draw Buffer is the back buffer which we draw to
  DISPENV disp[2];   // Display Buffer is the front buffer which we display
} DoubleBuff;

DoubleBuff screen;
short currentBuff;  // 0 or 1 which contains the curren buffer.  We swap the buffers on the backend

u_long ot[2][OT_LENGTH]; // ordering table
char primbuff[2][2048];  // the primitive buffer for the ordering table
char *nextprim;          // pointer to next primitive in the buffer

POLY_F3 *polyf3;
TILE *tile;
POLY_G4 *quadg4;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Initialize the display mode and setup double buffering
///////////////////////////////////////////////////////////////////////////////////////////////////
void ScreenInit(void) {
  // Reset GPU
  ResetGraph(0);

  // Set the display area of the first buffer
  SetDefDispEnv(&screen.disp[0], 0, 0, SCREEN_RES_X, SCREEN_RES_Y);
  SetDefDrawEnv(&screen.draw[0], 0, 240, SCREEN_RES_X, SCREEN_RES_Y);

  // Set the display area of the second buffer, the inverse of the first buffer
  SetDefDispEnv(&screen.disp[1], 0, 240, SCREEN_RES_X, SCREEN_RES_Y);
  SetDefDrawEnv(&screen.draw[1], 0, 0, SCREEN_RES_X, SCREEN_RES_Y);

  // Set the back/drawing buffer
  screen.draw[0].isbg = 1;
  screen.draw[1].isbg = 1;

  // Set the background clear color
  setRGB0(&screen.draw[0], 63, 0, 127); // dark purple
  setRGB0(&screen.draw[1], 63, 0, 127); // dark purple

  // Set the current buffer
  currentBuff = 0;
  PutDispEnv(&screen.disp[currentBuff]);
  PutDrawEnv(&screen.draw[currentBuff]);

  // Initialize and setup the GTE geometry offsets
  InitGeom();
  SetGeomOffset(SCREEN_CENTER_X, SCREEN_CENTER_Y);
  SetGeomScreen(SCREEN_CENTER_X);

  // Enable Display
  SetDispMask(SCREEN_Z);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// Draw the current frame using the ordering table
///////////////////////////////////////////////////////////////////////////////////////////////////
void DisplayFrame(void) {
  // Controls the vsync of the display
  DrawSync(0);
  VSync(0);

  PutDispEnv(&screen.disp[currentBuff]);
  PutDrawEnv(&screen.draw[currentBuff]);

  // Draw the ordering table for the current buffer
  DrawOTag(ot[currentBuff] + OT_LENGTH - 1);

  // Swaps the buffers
  currentBuff = !currentBuff;

  // Reset next primitive pointer to the start of the primitive buffer
  nextprim = primbuff[currentBuff];
}

void Setup(void) {
  ScreenInit();

  nextprim = primbuff[currentBuff];
}

void Update(void) {
  // Empty the ordering table
  ClearOTagR(ot[currentBuff], OT_LENGTH);

  // These commands are very similiar to the asm code that we wrote in the practice
  tile = (TILE*) nextprim;                              // Cast next primitive
  setTile(tile);                                       // Initialize the tile
  setXY0(tile, 82, 32);                                // Set (x, y) position
  setWH(tile, 64, 64);                                 // Set width and height
  setRGB0(tile, 0, 255, 0);                            // Set color
  addPrim(ot[currentBuff], tile);                      // Add the primitive to the ordering table
  nextprim += sizeof(TILE);                            // Advance nextprim pointer

  polyf3 = (POLY_F3*) nextprim;                      // Cast next primitive
  setPolyF3(polyf3);                                 // Initialize the triangle
  setXY3(polyf3, 64, 100, 200, 150, 50, 220);        // Set triangle verticies (x0, y0), (x1, y1), (x2, y2)
  setRGB0(polyf3, 255, 0, 255);                      // Set color
  addPrim(ot[currentBuff], polyf3);                  // Add the primitive to the ordering table
  nextprim += sizeof(POLY_F3);                         // Advance nextprim pointer

  quadg4 = (POLY_G4*) nextprim;                        // Cast next primitive
  setPolyG4(quadg4);                                   // Initialize the quad
  setXY4(quadg4, 140, 50, 200, 40, 170, 120, 220, 80); // Set quad verticies (x0, y0), (x1, y1), (x2, y2), (x3, y3)
  setRGB0(quadg4, 255, 0, 0);                          // Set color for vertex 1
  setRGB1(quadg4, 0, 255, 0);                          // Set color for vertex 2
  setRGB2(quadg4, 0, 0, 255);                          // Set color for vertex 3
  setRGB3(quadg4, 255, 255, 0);                        // Set color for vertex 4
  addPrim(ot[currentBuff], quadg4); // Add the primitive to the ordering table
  nextprim += sizeof(POLY_G4);
}

void Render(void) {
  DisplayFrame();
}

int main(void) {
  Setup();
  while (1) {
    Update();
    Render();
  }
  return 0;
}