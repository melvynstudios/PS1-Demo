all: ex1 ex2 ex3 ex4

ex1: clean
	..\..\mips\armips.exe exercise1.s
	python ..\bin2exe.py exercise1.bin exercise1.ps-exe

ex2: clean
	..\..\mips\armips.exe exercise2.s
	python ..\bin2exe.py exercise2.bin exercise2.ps-exe

ex3: clean
	..\..\mips\armips.exe exercise3.s
	python ..\bin2exe.py exercise3.bin exercise3.ps-exe

ex4: clean
	..\..\mips\armips.exe factorial.s
	python ..\bin2exe.py factorial.bin factorial.ps-exe

clean:
	@del *.bin 2>nul
	@del *.ps-exe 2>nul