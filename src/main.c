#include <sys/types.h>
#include <libgte.h>
#include <libetc.h>
#include <libgpu.h>
#include "inline_n.h"
#include "globals.h"
#include "joypad.h"

#define VIDEO_MODE 0
#define SCREEN_RES_X 320
#define SCREEN_RES_Y 240
#define SCREEN_CENTER_X (SCREEN_RES_X >> 1) // bit shifting for division, this is divided by 2
#define SCREEN_CENTER_Y (SCREEN_RES_Y >> 1)
#define SCREEN_Z 320

///////////////////////////////////////////////////////////////////////////////////////////////////
// Vertices and faces
///////////////////////////////////////////////////////////////////////////////////////////////////
// Quad faces
///////////////////////////////////////////////////////////////////////////////////////////////////
//     v0    v1
//     +-----+
//     |     |
//     |     |
//     +-----+
//     v2    v3
///////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct Cube {
  SVECTOR rotation;
  VECTOR position;
  VECTOR scale;
  VECTOR velocity;
  VECTOR accel;
  SVECTOR vertices[8];
  short faces[24];
} Cube;

typedef struct FLOOR {
  SVECTOR rotation;
  VECTOR position;
  VECTOR scale;
  SVECTOR vertices[4];
  short faces[6];
} Floor;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Declarations and global variables
///////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct {
  DRAWENV draw[2];   // Draw Buffer is the back buffer which we draw to
  DISPENV disp[2];   // Display Buffer is the front buffer which we display
} DoubleBuff;

DoubleBuff screen;
u_short currentBuff;  // 0 or 1 which contains the curren buffer.  We swap the buffers on the backend

POLY_G4 *polyg4;
POLY_F3 *polyf3;

SVECTOR rotation    = {0, 0, 0};
VECTOR  translation = {0, 0, 900};
VECTOR  scale       = {ONE, ONE, ONE};

MATRIX world = {0};

Cube cube = {{0, 0, 0},
             {0, -400, 1800},
             {ONE, ONE, ONE},
             {0, 0, 0},
             {0, 1, 0},
             {{-128, -128, -128},
              {128, -128, -128},
              {128, -128, 128},
              {-128, -128, 128},
              {-128, 128, -128},
              {128, 128, -128},
              {128, 128, 128},
              {-128, 128, 128}},
             {
            3, 2, 0, 1,
            0, 1, 4, 5,
            4, 5, 7, 6,
           1, 2, 5, 6,
           2, 3, 6, 7,
           3, 0, 7, 4,}
};

Floor fl = {{0, 0, 0},
               {0, 450, 1800},
               {ONE, ONE, ONE},
               {{-900, 0, -900}, {-900, 0, 900}, {900, 0, -900}, {900, 0, 900}},
               {
                   0, 1, 2,
                   1, 3, 2,
               }
};

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
  DrawOTag(GetOTAt(currentBuff, OT_LENGTH - 1));

  // Swaps the buffers
  currentBuff = !currentBuff;

  // Reset next primitive pointer to the start of the primitive buffer
  ResetNextPrim(currentBuff);
}

void Setup(void) {
  ScreenInit();

  // Initialize the joypad
  JoyPadInit();

  // Reset next primitive pointer to the start of the primitive buffer
  ResetNextPrim(currentBuff);
}

void Update(void) {
  // otz is the ordering table z index
  long otz, p, flg;

  // Empty the ordering table
  EmptyOT(currentBuff);

  JoyPadUpdate();
  if (JoyPadCheck(PAD1_LEFT)) {
    cube.rotation.vy += 20;
  }
  if (JoyPadCheck(PAD1_RIGHT)) {
    cube.rotation.vy -= 20;
  }
  if (JoyPadCheck(PAD1_UP)) {
    cube.rotation.vz += 20;
  }
  if (JoyPadCheck(PAD1_DOWN)) {
    cube.rotation.vz -= 20;
  }

  // Update the velocity based on the acceleration
  cube.velocity.vx += cube.accel.vx;
  cube.velocity.vy += cube.accel.vy;
  cube.velocity.vz += cube.accel.vz;

  // Update the position based on the velocity
  cube.position.vx += cube.velocity.vx >> 1;
  cube.position.vy += cube.velocity.vy >> 1;
  cube.position.vz += cube.velocity.vz >> 1;

  // Handle collision with the floor
  if (cube.position.vy + 150 > fl.position.vy) {
    cube.velocity.vy *= -1;
  }

  RotMatrix(&cube.rotation, &world);   // Populate the world maxtrix with the current rotation values
  TransMatrix(&world, &cube.position);      // Populate the world matrix with the current translation or position
  ScaleMatrix(&world, &cube.scale);    // Populate the world matrix with the current scale

  SetRotMatrix(&world);             // Sets the rotation matrix to be used ty the GTE
  SetTransMatrix(&world);           // Sets the translation matrix to be used by the GTE

  // Draw the objects, start with the cube
  for (int i = 0; i < (6 * 4); i += 4) {
    int nclip;
    polyg4 = (POLY_G4 *) GetNextPrim();
    setPolyG4(polyg4);
    setRGB0(polyg4, 255, 0, 255);
    setRGB1(polyg4, 255, 255, 0);
    setRGB2(polyg4, 0, 255, 255);
    setRGB3(polyg4, 0, 255, 0);

    // Load the first three vertices of the face into the GTE
    gte_ldv0(&cube.vertices[cube.faces[i + 0]]);
    gte_ldv1(&cube.vertices[cube.faces[i + 1]]);
    gte_ldv2(&cube.vertices[cube.faces[i + 2]]);
    // GTE can only handle 3 vertices at a time
    gte_rtpt();
    gte_nclip();
    gte_stopz(&nclip);

    // Check nclip, since quad vertices are coplanar
    if (nclip >= 0) {
      // Store first 3 vertex of the transformed face
      gte_stsxy0(&polyg4->x0);
      // Load the 4th vertex of the face into the GTE
      gte_ldv0(&cube.vertices[cube.faces[i + 3]]);
      // Transform the last vertex
      gte_rtps();
      // Store the the last vertex of the transformed face
      gte_stsxy3(&polyg4->x1, &polyg4->x2, &polyg4->x3);
      gte_avsz4();
      gte_stotz(&otz);

    // backface culling or normal clipping is a technique where we only render faces that are towards the camera.
    // we will discard rendering triangles that are not facing the camera
      if ((otz > 0) && (otz < OT_LENGTH)) {
        addPrim(GetOTAt(currentBuff, otz), polyg4);
        IncrementNextPrim(sizeof(POLY_G4));
      }
    }
  }

  // Add the floor
  RotMatrix(&fl.rotation, &world);
  TransMatrix(&world, &fl.position);
  ScaleMatrix(&world, &fl.scale);
  SetRotMatrix(&world);
  SetTransMatrix(&world);

  for (int i = 0; i < (2 * 3); i += 3) {
    polyf3 = (POLY_F3 *) GetNextPrim();
    setPolyF3(polyf3);
    setRGB0(polyf3, 255, 255, 255);
    int nclip = RotAverageNclip3(
        &fl.vertices[fl.faces[i + 0]], &fl.vertices[fl.faces[i + 1]],
        &fl.vertices[fl.faces[i + 2]], (long *)&polyf3->x0, (long *)&polyf3->x1,
        (long *)&polyf3->x2, &p, &otz, &flg);

    if (nclip <= 0)
      continue;
    if ((otz > 0) && (otz < OT_LENGTH)) {
      addPrim(GetOTAt(currentBuff, otz), polyf3);
      IncrementNextPrim(sizeof(POLY_F3));
    }
  };
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