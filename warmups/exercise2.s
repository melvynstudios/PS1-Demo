; Goal is to start with $t0 with 1 and loop 10 times, incrementing $t0.
; As the end we should have accumulated sum of all values (1+2+3...) inside $t1

.psx
.create "exercise2.bin", 0x80010000
.org 0x80010000

Main:
	; Start $t0 with the value of 1 and $t1 with the value of 0
	li $t0, 1
	li $t1, 0

	; Loop, incrementing $t0 until it reaches the value 10
Loop:
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	;Keep adding and accumulating all values of $t0 inside of $t1
	ble $t0, 10, Loop
End:
.close