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