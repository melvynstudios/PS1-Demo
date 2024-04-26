# Assembly Notes

Assembly happens at the register level, so we are coding what goes into the registers.  This guide is just a reference which I am using to help me learn hardware and undersand how things work.

## x86 assembly notes

Registers have a purpose these are the common ones on x86 processors.

General Purpose registers similiar to the $t registers found on the MIPS processor
eax
ebx
ecx
edx

Memory access registers
esp  points to the top of the stack
ebp  points to the base of the stack
cip  points to the next instruction

### System Call Tables

**NOTE** there is a 64 bit version as well if we are programming for modern pcs in assembly.

We can find out what registers do which functions by looking at the system call table.  In the case of this readme, its the x86 system call table.
[system call table 32 bit](https://chromium.googlesource.com/chromiumos/docs/+/master/constants/syscalls.md#x86-32_bit)

If you look at the table you will see `exit` which uses the instruction `0x01` with %eax to exit the program, and %ebx is the exit code.

### Multiplication and Division bit shifts

The quickest way to do math if we are multipling or dividing by a power of two is to use bit shifting.  This has more to do with programming in the 1990s where the advanced multiply and divide instructions were not available for the time period.

for example:

#### Bit Shift Left
n * 2 = n << 1
n * 4 = n << 2
n * 8 = n << 3
n * 16 = n << 4
n * 32 = n << 5

#### Bit Shift Right
n / 2 = n >> 1
n / 4 = n >> 2
n / 8 = n >> 3
n / 16 = n >> 4
n / 32 = n >> 5

Division is expecially time consuming in older processors.