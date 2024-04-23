.psx
.create "hello.bin", 0x80010000
.org 0x80010000

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

	; ------------------------------------------------------------------------------------
	; Set IO_BASE_ADDR to $a0 which is used for a global parameter
	; ------------------------------------------------------------------------------------
	lui $a0, IO_BASE_ADDR        ; Different from above because that is using $t0 register
	; ------------------------------------------------------------------------------------
	; Use Memory on the stack to call function
	la $sp, 0x00103CF0      ; Initialize stack pointer to 0x00103CF0
	; ----------------------------------------------------------------------------------
	; Invoke Subroutine
	; ----------------------------------------------------------------------------------
	addiu $sp, -(4 * 7)     ; Subtract from stack pointer, since we need to push 7 words/params into memory

	li $t0, 0xFF4472        ; Param: Color (0xBBGGRR)
	sw $t0, 0($sp)          ; push argument to $sp+0

	li $t0, 200             ; Param: x1
	sw $t0, 4($sp)          ; push argument to $sp+4
	li $t0, 40              ; Param: y1
	sw $t0, 8($sp)           ; push argument into $sp+8,

	li $t0, 288             ; Param: x2
	sw $t0, 12($sp)         ; push argument into $sp+12
	li $t0, 56              ; Param: y2
	sw $t0, 16($sp)         ; push argument into $sp+16

	li $t0, 224             ; Param: x3
	sw $t0, 20($sp)         ; push argument into $sp+20
	li $t0, 200             ; Param: y3
	sw $t0, 24($sp)         ; push argument into $sp+24

	jal DrawFlatTriangle    ; Invoke Draw Triangle subroutine
	nop

LoopForever:              ; Block execution so we can see our code running.  Basically a pause.
	j LoopForever
	nop

;-----------------------------------------------------
; Subroutine to draw a flat-shaded triangle
; We can call the function with decimal instead of hex
; Arguments:
; $a0 = IO_BASE_ADDR (IO Ports at 0x1F80)
; $s0+0 = Color (for example: 0xBBGGRR)
; $sp+4  = x1
; $sp+8  = y1
; $sp+12 = x2
; $sp+16 = y2
; $sp+20 = x3
; $sp+24 = y3
;-----------------------------------------------------
DrawFlatTriangle:
	lui $t0, 0x2000        ; Load the command into $t1 register
	lw $t1, 0($sp)         ; Fetch value from the stack using offset, $sp
	nop
	or $t8, $t0, $t1       ; Command | Color
	sw $t8, GP0($a0)       ; Command that we know from above
	; first Vertex
	lw $t1, 4($sp)         ; fetch x1 from the stack
	lw $t2, 8($sp)         ; fetch y1 from stack
	nop
	sll $t2, $t2, 16       ; y1 <<= 16
	andi $t1, $t1, 0xFFFF  ; x1 &= 0xFFFF
	or $t8, $t1, $t2       ; x1 | y1
	sw $t8, GP0($a0)       ; Command that we know from above
	; second vertex
	lw $t1, 12($sp)         ; fetch x2 from the stack
	lw $t2, 16($sp)         ; fetch y2 from stack
	nop
	sll $t2, $t2, 16       ; y2 <<= 16
	andi $t1, $t1, 0xFFFF  ; x2 &= 0xFFFF
	or $t8, $t1, $t2       ; x2 | y2
	sw $t8, GP0($a0)       ; Command that we know from above
	; third vertex
	lw $t1, 20($sp)         ; fetch x3 from the stack
	lw $t2, 24($sp)         ; fetch y3 from stack
	nop
	sll $t2, $t2, 16       ; y3 <<= 16
	andi $t1, $t1, 0xFFFF  ; x3 &= 0xFFFF
	or $t8, $t1, $t2       ; x3 | y3
	sw $t8, GP0($a0)       ; Command that we know from above

	addiu $sp, $sp, (4 * 7) ; Rest Stack pointer...Move stack pointer up 7 words to shrink it after pulling the 7 params from memory

	jr $ra                 ; Return address (stored in $ra)
	nop

.close