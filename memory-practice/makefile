all: helloworld

helloworld: clean
	..\..\mips\armips.exe hello.s
	python ..\bin2exe.py hello.bin hello.ps-exe

clean:
	@del *.bin 2>nul
	@del *.ps-exe 2>nul