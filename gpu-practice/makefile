all: helloworld

helloworld: clean
	..\..\mips\armips.exe helloworld.s
	python ..\bin2exe.py helloworld.bin helloworld.ps-exe

demo: clean
	..\..\mips\armips.exe instructor.s
	python ..\bin2exe.py hellogpu.bin hellogpu.ps-exe

clean:
	@del *.bin 2>nul
	@del *.ps-exe 2>nul