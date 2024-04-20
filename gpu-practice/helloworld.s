.psx
.create "helloworld.bin", 0x80010000
.org 0x80010000

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

	;-------------------------------------------
	; Setup Display and VRAM
	;-------------------------------------------
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

	li $t1, 0xE1000400      ; E1 = Draw Mode Settings
	sw $t1, GP0($t0)

	li $t1, 0xE3000000      ; E3 = Drawing Area TopLeft - %YYYYYYYYYYXXXXXXXXXX (10 bits for x and 10 bits for y)
	sw $t1, GP0($t0)        ; TopLeft set at x=0, y=0

	li $t1, 0xE43BD3F       ; E4 = Drawing aread BottomRight - %YYYYYYYYYYXXXXXXXXXX (10 bits for x and 10 bits for y)
	sw $t1, GP0($t0)        ; BottomRight set to x=319, y=239 (index starts at 0, so 320x240 is the real size)

	li $t1, 0xE5000000      ; E5 = Drawing offset - %YYYYYYYYYYXXXXXXXXXX
	sw $t1, GP0($t0)        ; Drawing offset x=0, y=0

	; ------------------------------
	; Clear Screen and Draw background
	; ------------------------------
	li $t1, 0x02FF2C2E      ; 02 = Fill Rectangle in VRAM (Color Parameter: 0xBBGGRR)
	sw $t1, GP0($t0)        ; r=46, g=44, b=255

	li $t1, 0x00000000      ; Fill Area, Parameter: 0xYYYYXXXX - Topleft (0,0)
	sw $t1, GP0($t0)

	li $t1, 0x00EF013F      ; Fill Area, 0xHHHHWWWW
	sw $t1, GP0($t0)

	; ------------------------------
	; Draw flat-shaded triangle
	; https://psx-spx.consoledev.net/graphicsprocessingunitgpu/#gpu-render-polygon-commands
	; ------------------------------
  li $t1, 0x2000FFFF         ; 20 = Flat-shaded triangle (Parameter Color: 0xBBGGRR)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x00320032         ; Vertex 1: (Parameter 0xYyyyXxxx) (x=50,y=50)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x001E0064         ; Vertex 2: (Parameter 0xYyyyXxxx) (x=100,y=30)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x0064006E         ; Vertex 3: (Parameter 0xYyyyXxxx) (x=110,y=100)
  sw $t1, GP0($t0)           ; Write GP0 Command

LoopForever:              ; Block execution so we can see our code running.  Basically a pause.
	j LoopForever
	nop

.close