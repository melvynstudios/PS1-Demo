all: helloworld

helloworld: clean
	..\..\mips\armips.exe helloworld.s
	python ..\bin2exe.py helloworld.bin helloworld.ps-exe

clean:
	@del *.bin 2>nul
	@del *.ps-exe 2>nul