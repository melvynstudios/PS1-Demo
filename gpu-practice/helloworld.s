.psx
.create "helloworld.bin", 0x80010000
.org 0x8001000

; Playstation has a boot process, but once that is completed it give us control
; We need to setup everything to start drawing things
; 1 Setup Display Control
; 2 Enable Display
; 3 Set display mode (resolution, color depth, PAL or NTSC)
; 4 Set Horizontal range
; 5 Set Vertical range

;; Next We need to setup the VRAM Access
; Set Drawing mode
; Set Drawing area Top-Left
; Set Drawing area Bottom-Right
; Set Drawing area offset X & Y

;; Next We need to clear the screen
; Fill the rectangle on the display area

;; Finally we can draw a flat-shaded triangle
; Send packets to the GP0 to draw a triangle

Main:

.close