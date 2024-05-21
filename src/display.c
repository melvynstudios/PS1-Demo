#include "display.h"
#include "globals.h"
#include "libgpu.h"
#include <libetc.h>


static DoubleBuffer screen;
static u_short currentBuffer;

u_short GetCurrentBuffer() { return currentBuffer; }
void ScreenInit(void) {
  // Reset GPU
  ResetGraph(0);

  // Set the digital display area of the first buffer
  SetDefDispEnv(&screen.disp[0], 0, 0, SCREEN_RES_X, SCREEN_RES_Y);
  SetDefDrawEnv(&screen.draw[0], 0, 240, SCREEN_RES_X, SCREEN_RES_Y);

  // Set the digital display area of the second buffer
  SetDefDispEnv(&screen.disp[1], 0, 240, SCREEN_RES_X, SCREEN_RES_Y);
  SetDefDrawEnv(&screen.draw[1], 0, 0, SCREEN_RES_X, SCREEN_RES_Y);

  // Set the back/drawing buffer
  screen.draw[0].isbg = 1;
  screen.draw[1].isbg = 1;

  // Set the background clear color
  setRGB0(&screen.draw[0], 63, 0, 127); // dark purple
  setRGB0(&screen.draw[1], 63, 0, 127); // dark purple

  // Set the current buffer
  currentBuffer = 0;
  PutDispEnv(&screen.disp[currentBuffer]);
  PutDrawEnv(&screen.draw[currentBuffer]);

  // Initialize and setup the GTE geometry offsets
  InitGeom();
  SetGeomOffset(SCREEN_CENTER_X, SCREEN_CENTER_Y);
  SetGeomScreen(SCREEN_CENTER_X);

  // Enable Display
  SetDispMask(1);
};

////////////////////////////////////////////////////////////
// Draw the current frame primitives in the ordering table
////////////////////////////////////////////////////////////
void DisplayFrame(void) {
  // Sync and wait for vertical blank
  DrawSync(0);
  VSync(0);

  // Set the current display and draw buffers
  PutDispEnv(&screen.disp[currentBuffer]);
  PutDrawEnv(&screen.draw[currentBuffer]);

  // Draw the ordering table for the current buffer
  DrawOTag(GetOTAt(currentBuffer, OT_LENGTH - 1));

  // swap the current buffer
  currentBuffer = !currentBuffer;

  // Reset next primitive pointer to the start of the primitive buffer
  ResetNextPrim(currentBuffer);
};