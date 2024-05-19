#ifndef GLOBALS_H
#define GLOBALS_H

#include <sys/types.h>

#define OT_LENGTH 8192
#define PRIMBUFF_LENGTH 131072

// Empty Ordering Table, we have two buffers, 0 or 1
void EmptyOT(u_short cbuff);

// Set Ordering Table at the current buffer, the position of the ordering table, and the value
void SetOTAt(u_short cbuff, u_int i, u_long value);
// Get Ordering Table from the current buffer at a certain position
u_long *GetOTAt(u_short cbuff, u_int i);

// Set the next primitive in the current buffer, by the size of the primitive
void IncrementNextPrim(u_int size);
// Set Next Primitive pointer, set the value
void SetNextPrim(char *value);
// Reset Primitive Pointer, clears the buffer array
void ResetNextPrim(u_short cbuff);
// Get the next primitive in the current buffer
char *GetNextPrim(void);

#endif