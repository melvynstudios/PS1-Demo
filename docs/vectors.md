# Vectors and Vector Alignment

## Arrays

In C we would initialize an array this way
```c
short arr[6] = { 5, 4, 4, 9, 0, 1 };
```

The assembly would look like this
```asm
.org 0x80010000

arr: .hword 5, 4, 4, 9, 0, 1

Main:
	...

.close
```

### Reserve memory

In cases where we want to reserve memory but not initialize it with values we do the following:

```c
byte arr[256];
```

In assembly we can do that with this directive
```asm
.org 0x80010000

; the .space directive reserves n bytes of memory and initializes them to zero
arr: .space 256         ; This reservation is in bytes

; Need to take into account the size of the elements that we have in our array
ShortArr: .space 256 * 2    ; Multiply the value by 2 since short is 2 bytes
LongArr: .space 256 * 4     ; long is 4 bytes

Main:
...
.close
```

.space doesn't know what the type is, so we need to make sure that we multiply by the size of the type.

Another example of this memory allocation is the following:

```c
char char;
int arr0[500];
int arr1[5] = { 1, 2, 3, 4, 5 };
```

Assembly:
```asm
.org 0x80010000

char:   .byte 0

        .align 2            ; .align directive places the next data at an address that is a multiple of 2^n, needed for arrays
arr0:   .space   500 * 4

arr1:   .word 1, 2, 3, 4, 5

Main:
......
.close
```

**NOTE**: if using `.space`, we also need to use the `.align` directive so the assembly knows how to align the data.

### Accessing random array element

```c
int arr[256];

int main() {
	int v;
	v = arr[5];        // access a random array element
	return 0;
}

```asm
.org 0x80010000

     .align 2       ; align to a multiple of 4
arr: .space 256 * 4 ; int arr[256]

Main:
	la $t0, arr       ; $t0 = &arr
	lw $t1, 20($t0)   ; $t1 = arr + ( 5 * 4) which is 5 element of 4 bytes

.close
```

An array is a pointer to an initial position with an offset by a specific amount.

## Multiplication and Division

When we are multiplying or dividing numbers in Assembly, the output is stored in the $hi and $lo registers.

The reason for this is because if we are multiplying two numbers together there is a potential to overflow, so we store the return value in those two registers, that are joined together to form a 64 bit number.

When we are dividing, the $hi contains the remainder and the $lo contains the quotient.