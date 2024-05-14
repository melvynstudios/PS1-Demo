#include "joypad.h"

int JoyPadCheck(int p) { return padstate & p; }

void JoyPadInit() { PadInit(0); }
void JoyPadReset(void) { padstate = 0; }

void JoyPadUpdate(void) {
  u_long pad = PadRead(0);
  padstate = pad;
}