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

#define OT_LENGTH 16

/*  DATA TYPES
  char  c;   // -> 8 bits, 1 byte
  short s;   // -> 16 bits, 2 bytes
  int   i;   // -> 32 bits, 4 bytes
  long  l;   // -> 32 bits, 4 bytes

  u_short us;  // unsigned 16 bits
  u_long  ul;  // unsigned 32 bits

  POLY_F3 *triangle;
  TILE    *tile;
  POLY_G4 *quad;
*/

typedef struct {
  DRAWENV draw[2];   // Draw Buffer is the back buffer which we draw to
  DISPENV disp[2];   // Display Buffer is the front buffer which we display
} DoubleBuff;

DoubleBuff screen;
short currentBuff;  // 0 or 1 which contains the curren buffer.  We swap the buffers on the backend

u_long ot[2][OT_LENGTH]; // ordering table
char primbuff[2][2048];  // the primitive buffer for the ordering table
char *nextprim;          // pointer to next primitive in the buffer

POLY_F3 *triangle;
TILE    *tile;

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
  SetDispMask(1);
}

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
  tile = (TILE*)nextprim;                        // Cast next primitive
  setTile(tile);                                 // Initialize the tile
  setXY0(tile, 82, 32);                          // Set (x, y) position
  setWH(tile, 64, 64);                           // Set width and height
  setRGB0(tile, 0, 255, 0);                      // Set color
  addPrim(ot[currentBuff], tile);                // Add the primitive to the ordering table
  nextprim += sizeof(TILE);                      // Advance nextprim pointer

  triangle = (POLY_F3 *)nextprim;                // Cast next primitive
  setPolyF3(triangle);                           // Initialize the triangle
  setXY3(triangle, 64, 100, 200, 150, 50, 220);  // Set triangle verticies (x0, y0), (x1, y1), (x2, y2)
  setRGB0(triangle, 255, 0, 255);                // Set color
  addPrim(ot[currentBuff], triangle);            // Add the primitive to the ordering table
  nextprim += sizeof(POLY_F3);                   // Advance nextprim pointer
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