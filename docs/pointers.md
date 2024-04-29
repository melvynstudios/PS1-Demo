# Pointers

C is a language that allows us to work with pointers which means we have low-level control of memory addresses.  A pointer can be used to store the memory address of other variables, functions, or even other pointers.
They are low level memory access, dynamic memory allocation, and other functionality in C.

In Playstation 1 programming there is no unsafe memory access.  We have access to the whole memory so we can do whatever we want.  We also have a strong link between pointers and dynamic memory allocation.

int *arr;

 |
 V
[ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ]

### Examples

```c
int num;   // value of num
int* pnum; // pointer to num

typedef struct VECTOR {
	long vx;
	long vy;
	long vz;
} VECTOR;

VECTOR vec;   // value of vec
VECTOR* pvec; // pointer to vec

int main(void) {
	num = 599;
	pnum = &num;

	printf("pnum  = %p\n", pnum);  // pnum = 0x404018
	printf("num   = %d\n", num);   // num = 599
	printf("*pnum = %d\n", *pnum); // *pnum = 599
}
```

This is the same as you would find in Go.  `*` is the value at the address of the pointer.  This is a dereference operator.  `&` is the address of the pointer.

Pointer size is based on the architecture of the computer.

## Arrow Operator

The arrow operator -> in C is used to accessing members (variables, methods) of a struct through a pointer.

```c
VECTOR vec;
VECTOR* pvec;

void ClearVector(VECTOR* pvec) {
	v->vx = 0;             // Since the paramter v was passed as a pointer
	v->vy = 0;             // the -> operator dereferences v and access
	v->vz = 0;             // the members of the struct pointed by v
};

int main(void) {
	vec.vx = 10;
	vec.vy = 5;
	vec.vz = -6;

	pvec = &vec;

	ClearVector(&vec);         // Similiar to Go, the function expects a pointer so we use the & operator
	ClearVector(pvec);         // Since pvec is a pointer, we don't need the & operator
}