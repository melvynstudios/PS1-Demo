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

;-------------------------------------------
; Declare Variables
;-------------------------------------------
IO_BASE_ADDR equ 0x1F80   ; IO Ports Memory map base address
GP0 equ 0x1810            ; GP0 @ $1F801810: Render data & VRAM Access
GP1 equ 0x1814            ; GP1 @ $1F801814: Display Control and Env Setup

Main:
	lui $t0, IO_BASE_ADDR   ; t0 = I/O Port Base Address (mapped at 0x1F80)
	li $t1, 0x00000000      ; 00 = Reset GPU
	sw $t1, GP1($t0)        ; Writes the packet to the GP1 with the offset of $t0

	li $t1, 0x03000000      ; 03 = Display Enable, 03 is the command, everything else are the params
	sw $t1, GP1($t0)        ; send packet to GPU, the offset is whatever is in t0 + 1814 from GP1

	li $t1, 0x08000001      ; 08 = Display mode (320x240, 15-bit, NTSC)
	sw $t1, GP1($t0)

	li $t1, 0x06C60260      ; 06 = Horizontal Display range 0xXXXxxx (3168-608)
	sw $t1, GP1($t0)

	li $t1, 0x07042018      ; 07 = Vertical Display Range %yyyyyyyyyyYYYYYYYYYY (264-24)
	sw $t1, GP1($t0)

.close