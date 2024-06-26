.psx
.create "image.bin", 0x80010000
.org 0x80010000

;-------------------------------------------
; Declare Variables
;-------------------------------------------
IO_BASE_ADDR equ 0x1F80   ; IO Ports Memory map base address
GP0 equ 0x1810            ; GP0 @ $1F801810: Render data & VRAM Access
GP1 equ 0x1814            ; GP1 @ $1F801814: Display Control and Env Setup

; Image Constants
IMG_WIDTH      equ 640
IMG_HEIGHT     equ 480
IMG_SIZE_BYTES equ 921600  ; 640 * 480 * 3 bytes per pixel (image is 24bpp)

Main:
	lui $a0, IO_BASE_ADDR        ; Different from above because that is using $t0 register

	;-------------------------------------------
	; Setup Display and VRAM
	;-------------------------------------------
	li $t1, 0x00000000      ; 00 = Reset GPU
	sw $t1, GP1($a0)        ; Writes the packet to the GP1 with the offset of $t0
	li $t1, 0x03000000      ; 03 = Display Enable, 03 is the command, everything else are the params
	sw $t1, GP1($a0)        ; send packet to GPU, the offset is whatever is in t0 + 1814 from GP1
	li $t1, 0x08000037      ; 08 = Display mode (320x240, 15-bit, NTSC)
	sw $t1, GP1($a0)
	li $t1, 0x06C60260      ; 06 = Horizontal Display range 0xXXXxxx (3168-608)
	sw $t1, GP1($a0)
	li $t1, 0x07042018      ; 07 = Vertical Display Range %yyyyyyyyyyYYYYYYYYYY (264-24)
	sw $t1, GP1($a0)
	li $t1, 0xE1000400      ; E1 = Draw Mode Settings
	sw $t1, GP0($a0)
	li $t1, 0xE3000000      ; E3 = Drawing Area TopLeft - %YYYYYYYYYYXXXXXXXXXX (10 bits for x and 10 bits for y)
	sw $t1, GP0($a0)        ; TopLeft set at x=0, y=0
	li $t1, 0xE403BD3F      ; E4 = Drawing aread BottomRight - %YYYYYYYYYYXXXXXXXXXX (10 bits for x and 10 bits for y)
	sw $t1, GP0($a0)        ; BottomRight set to x=319, y=239 (index starts at 0, so 320x240 is the real size)
	li $t1, 0xE5000000      ; E5 = Drawing offset - %YYYYYYYYYYXXXXXXXXXX
	sw $t1, GP0($a0)        ; Drawing offset x=0, y=0

	; ------------------------------
	; Clear Screen and Draw background
	; ------------------------------
	li $t1, 0x02FF2C2E      ; 02 = Fill Rectangle in VRAM (Color Parameter: 0xBBGGRR)
	sw $t1, GP0($a0)        ; r=46, g=44, b=255
	li $t1, 0x00000000      ; Fill Area, Parameter: 0xYYYYXXXX - Topleft (0,0)
	sw $t1, GP0($a0)
	li $t1, 0x00EF013F      ; Fill Area, 0xHHHHWWWW
	sw $t1, GP0($a0)

	;------------------------------------------------------------------------
	; Copy rect data from CPU to VRAM
	;------------------------------------------------------------------------
CopyImageToVRAM:
	li $t1, 0xA0000000      ; A0 = Command to copy Rect CPU to VRAM
	sw $t1, GP0($a0)        ; Write GP0 Command
	li $t1, 0x00000000      ; Location of Copy Area, TopLeft (x=0, y=0)
	sw $t1, GP0($a0)
	li $t1, 0x01E003C0      ; Size of Copy Area, 0xHHHHWWWW (Height=480, Width=640)
	sw $1, GP0($a0)

	; Send data to GPU
	li   $t0, IMG_SIZE_BYTES   ; Load the total bytes of the image
	srl $0, 2                  ; $t0 >> 2, which means $t0/4
	la $t2, Image              ; $t2 = image offset

LoopWords:
	lw    $t1, 0($t2)        ; t1 = word from the image array
	addiu $t2, 4             ; $t2 += 4, which gives us our next memory address (Delay Slot of the load above)
	sw    $t1, GP0($a0)
	bnez  $t0, LoopWords     ; if ($t0 != 0), keep looping
	; Due to the MIPS pipeline this instruction will happen before the jump, which is why we previously used nop
	addiu $t0, $t0, -1        ; t0-- (Delay Slot so we don't waste CPU Cycles with NoOp instructions)

LoopForever:              ; Block execution so we can see our code running.  Basically a pause.
	j LoopForever
	nop

Image:
	.incbin "logo.bin"      ; Includes a 640x480*3 (921600 bytes)

.close