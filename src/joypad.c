#include "joypad.h"
#include <sys/types.h>
#include <libetc.h>

static u_long padstate;

int JoyPadCheck(int p) { return padstate & p; }

void JoyPadInit() { PadInit(0); }
void JoyPadReset(void) { padstate = 0; }

void JoyPadUpdate(void) {
  u_long pad = PadRead(0);
  padstate = pad;
}