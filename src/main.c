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
#define SCREEN_Z 320

#define OT_LENGTH 256
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

POLY_G3 *poly;

SVECTOR rotation    = {0, 0, 0};
VECTOR  translation = {0, 0, 900};
VECTOR  scale       = {ONE, ONE, ONE};

MATRIX world = {0};

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
  // otz is the ordering table z index
  long otz, p, flg;

  // Empty the ordering table
  ClearOTagR(ot[currentBuff], OT_LENGTH);

  RotMatrix(&rotation, &world);
  TransMatrix(&world, &translation);
  ScaleMatrix(&world, &scale);

  SetRotMatrix(&world);
  SetTransMatrix(&world);

  // Loop all triangle faces
  for (int i = 0; i < NUM_FACES * 3; i += 3) {
    poly = (POLY_G3 *)nextprim;
    setPolyG3(poly);
    setRGB0(poly, 255, 0, 255);
    setRGB1(poly, 255, 255, 0);
    setRGB2(poly, 0, 255, 255);

    otz = 0;
    otz += RotTransPers(&vertices[faces[i + 0]], (long *)&poly->x0, &p, &flg);
    otz += RotTransPers(&vertices[faces[i + 1]], (long *)&poly->x1, &p, &flg);
    otz += RotTransPers(&vertices[faces[i + 2]], (long *)&poly->x2, &p, &flg);
    otz /= 3;

    if ((otz > 0) && (otz < OT_LENGTH)) {
      addPrim(ot[currentBuff][otz], poly);
      nextprim += sizeof(POLY_G3);
    }
  }
  rotation.vx += 6;
  rotation.vy += 8;
  rotation.vz += 12;
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