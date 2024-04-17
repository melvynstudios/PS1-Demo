; Goal is to load registers $t0, $t1, and $t2
; Try using hexadecimal literals instead of decimals whenever possible

.psx
.create "exercise1.bin", 0x80010000
.org 0x80010000

Main:
	; Load $t0 with the immediate decimal value of 1
	li $t0, 0x1
	; Load $t1 with the immediate decimal value of 256
	li $t1, 0x100
	; Load $t2 with the immediate value of 17
	li $t2, 0x11
End:
.close