build: clean
	..\..\mips\armips.exe fillmem.s
	python ..\bin2exe.py fillmem.bin fillmem.ps-exe

image: clean
	..\..\mips\armips.exe image.s
	python ..\bin2exe.py image.bin image.ps-exe

clean:
	@del fillmem.bin 2>nul
	@del fillmem.ps-exe 2>nul