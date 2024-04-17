; Goal of this exercise is to perform integer division between two numbers
; We need a numerator, denominator, and result.  These will be stored into $t0, $t1, and $t2

/*
main() {
	int num;
	int den;
	int res;
	num = 27;
	den = 3;
	res = 0;
	while (num >= den) {
		num -= den;
		res++;
	}
}
*/
.psx
.create "exercise3.bin", 0x80010000
.org 0x80010000

Main:
	li $t0, 27
	li $t1, 3
	li $t2, 0 ; this represents result

Loop:
	sub $t0, $t0, $t1
	addi $t2, $t2, 1
	blt $t0, $t1, Loop


End:
.close