# Ordering Table notes

```c
TILE      *tile;   // 2D tile
POLY_F3   *triA;   // Flat-shaded triangle
POLY_G3   *triB;   // Gouraud-shaded triangle
POLY_F4   *quadA;  // Flat-shaded quadrilateral
POLY_G4   *quadB;  // Gouraud-shaded quadrilateral

#define OT_LENGTH 8

u_long ot[2][OT_LENGTH];  // Ordering table

char primbuff[2]92048;    // Buffer for primitive
char *nextprim;           // Pointer to next primitive

void Update(void) {
	nextprim = primbuff[currentbuff];                 // Reset next primitive pointer

	ClearOTagR(ot[currentbuff], OT_LENGTH);           // Clear the ordering table reverse

	tile = (TILE *) nextprim;                         // Cast next primitive
	setTile(tile);                                    // Initialize the primitive
	setXY0(tile, 82, 32);                            // Set the tile position
	setWH(tile, 64, 64);                             // Set the tile size
	setRGB0(tile, 0, 255, 0);                        // Set the tile color
	addPrim(ot[currentbuff], tile);                  // Add & sort the tile to the ordering table
	nextprim += sizeof(TILE);                        // Advance the next primitive pointer
}

void Render(void) {
	DrawOTag(ot[currentbuff] + OT_LENGTH-1);         // Draw the ordering table
}

```