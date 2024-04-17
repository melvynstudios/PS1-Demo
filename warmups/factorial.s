.psx
.create "factorial.bin", 0x80010000
.org 0x8001000

Main:
	li $t0, 5                   ; num = 5
	li $t3, 1                   ; temp = 1
	li $t1, 1                   ; i = 1
	li $t4, 1                   ; sum =1

OuterLoop:
	bgt $t1, $t0, EndOuterLoop  ; break if (i > num)
	nop
	move $t4, $Zero             ; sum = 0
	move $t2, $Zero             ; j = 0

InnerLoop:
	bge $t2, $t1, EndInnerLoop  ; break if (j >= i)
	nop
	addiu $t4, $t4, $t3         ; sum += temp
	addi $t2, $t2, 1            ; j++
	j InnerLoop                 ; Jump back to the inner loop
	nop

EndInnerLoop:
	move $t2, $t4               ; temp = sum
	addi $t1, $t1, 1            ; i++
	j OuterLoop                 ; Jump back to the outer loop
	nop

EndOuterLoop:

End:
	; Save the result inside of $v0
	move $v0, $t4               ; Final result is moved to $v0
.close