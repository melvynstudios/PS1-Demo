.psx                                ; architecture that we are targeting
.create "fillmem.bin", 0x80010000   ; Origin of our code in memory, its where the linker will place our source code

.org 0x80010000                     ;  sets the origin point of the program to memory address 0x80010000

BASE_ADDR equ 0x0000

Main:
	li $t0, 0xA000      ; $t0 = 0xA000
	li $t1, 0xA0FF      ; $t1 = 0xA0FF
	li $t2, 0x11        ; $t2 = 0x11

Loop:
	sb   $t2, BASE_ADDR($t0)
	addi $t0, $t0, 1
	ble  $t0, $t1, Loop

End:

.close