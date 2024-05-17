#include "globals.h"
#include "libgpu.h"
static u_long ot[2][OT_LENGTH];                // Ordering table holding pointers to sorted primitives
static char primbuff[2][PRIMBUF_LENGTH];       // Primitive buffer that holds the actual data for each primitive
static char *nextprim; // Pointer to the next primitive buffer

void EmptyOT(short cbuff) { ClearOTagR(ot[cbuff], OT_LENGTH); }

void SetOTAt(short cbuff, u_int i, u_long value) { ot[cbuff][i] = value; }

u_long *GetOTAt(short cbuff, u_int i) { return &ot[cbuff][i]; }

void IncrementNextPrim(u_int size) { nextprim += size; }
void SetNextPrim(char *value) { nextprim = value; }
void ResetNextPrim(short cbuff) { nextprim = primbuff[cbuff]; }

char *GetNextPrim(void) { return nextprim; }