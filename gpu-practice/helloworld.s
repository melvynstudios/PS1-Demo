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

	li $t1, 0xE403BD3F      ; E4 = Drawing aread BottomRight - %YYYYYYYYYYXXXXXXXXXX (10 bits for x and 10 bits for y)
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
	; Left Eye
  li $t1, 0x2000FFFF         ; 20 = Flat-shaded triangle (Parameter Color: 0xBBGGRR)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x00500064         ; Vertex 1: (Parameter 0xYyyyXxxx) (x=50,y=50)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x003C0078         ; Vertex 2: (Parameter 0xYyyyXxxx) (x=100,y=30)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x0050008C         ; Vertex 3: (Parameter 0xYyyyXxxx) (x=110,y=100)
  sw $t1, GP0($t0)           ; Write GP0 Command
; ---------------------------------------------------------------------------------
; Right Eye
  li $t1, 0x2000FFFF         ; 20 = Flat-shaded triangle (Parameter Color: 0xBBGGRR)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x005000B4         ; Vertex 1: (Parameter 0xYyyyXxxx) (x=50,y=50)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x003C00C8         ; Vertex 2: (Parameter 0xYyyyXxxx) (x=100,y=30)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x005000DC         ; Vertex 3: (Parameter 0xYyyyXxxx) (x=110,y=100)
  sw $t1, GP0($t0)           ; Write GP0 Command
; ---------------------------------------------------------------------------------
; Nose
  li $t1, 0x2000FFFF         ; 20 = Flat-shaded triangle (Parameter Color: 0xBBGGRR)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x007800A0         ; Vertex 1: (Parameter 0xYyyyXxxx) (x=160,y=120)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x008C0096         ; Vertex 2: (Parameter 0xYyyyXxxx) (x=150,y=140)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x008C00AA         ; Vertex 3: (Parameter 0xYyyyXxxx) (x=170,y=140)
  sw $t1, GP0($t0)           ; Write GP0 Command
; ---------------------------------------------------------------------------------
; mouth
  li $t1, 0x2000FFFF         ; 20 = Flat-shaded triangle (Parameter Color: 0xBBGGRR)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x00A00078         ; Vertex 1: (Parameter 0xYyyyXxxx) (x=120,y=160)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x00A000C8         ; Vertex 2: (Parameter 0xYyyyXxxx) (x=200,y=160)
  sw $t1, GP0($t0)           ; Write GP0 Command

  li $t1, 0x00B400A0         ; Vertex 3: (Parameter 0xYyyyXxxx) (x=160,y=180)
  sw $t1, GP0($t0)           ; Write GP0 Command
; ---------------------------------------------------------------------------------
; cigar
	li $t1, 0x30283C8B         ; 30 = Gourand-shaded triangle
	sw $t1, GP0($t0)
	li $t1, 0x00BA006E         ; Vertex 1: 0xYyyyXxxx (x=155,y=160)
	sw $t1, GP0($t0)

	li $t1, 0x0054382B         ; Color 2 0xBBGGRR
	sw $t1, GP0($t0)
	li $t1, 0x00BA0082         ; Vertex 2: x=165, y=160
	sw $t1, GP0($t0)

	li $t1, 0x00302A1E         ; Color 2 0xBBGGRR
	sw $t1, GP0($t0)
	li $t1, 0x00A60096         ; Vertex 3: x=175, y=150
	sw $t1, GP0($t0)

LoopForever:              ; Block execution so we can see our code running.  Basically a pause.
	j LoopForever
	nop

;-----------------------------------------------------
; Subroutine to draw a flat-shaded triangle
; We can call the function with decimal instead of hex
; Args:
; $a0 = IO_BASE_ADDR (IO Ports at 0x1F80)
; $s1 = x1
; $s2 = y1
; $s3 = x2
; $s4 = y2
; $s5 = x3
; $s6 = y3
;-----------------------------------------------------
DrawFlatTriangle:
	lui $t0, 0x2000        ; Load the command into $t1 register
	or $t1, $t0, $s0       ; Load Command and the color into $t1
	sw $t1, GP0($a0)       ; Command that we know from above
	; first Vertex
	; https://people.cs.pitt.edu/~childers/CS0447/lectures/shift-operations.pdf
	ssl $s2, $s2, 16       ; shift left instruction fills 16 zeros to the left of the word
	andi $s1, $s1, 0xFFFF  ; This code ensures that we have 2 bytes for the x Coordinate
	or $t1, $s1, $s2       ; This allows us to put $s1 (x) and $s2 (y) into the $t1 register
	sw $t1, GP0($a0)       ; Command that we know from above
	; second vertex
	ssl $s4, $s4, 16       ; y2 <<= 16 as same as vertex 1
	andi $s3, $s3, 0xFFFF  ; x2 &= 0xFFFF
	or $t1, $s3, $s4       ; x2 | y2
	sw $t1, GP0($a0)
	; third vertex
	ssl $s6, $s6, 16       ; y3 <<= 16 as same as vertex 1
	andi $s5, $s5, 0xFFFF  ; x3 &= 0xFFFF
	or $t1, $s5, $s6       ; x3 | y3
	sw $t1, GP0($a0)

	jr $ra                 ; Return address (stored in $ra)
	nop


.close