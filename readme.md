# PS1 Demo

This is a project for learning low level programming on the PS1.
The use of this repo is for educational purposes only.

Best of the PS1 games, which makes this project so special. [Games](https://racketboy.com/retro/games-that-pushed-the-limits-of-the-sony-playstation-ps1)

## Tools being used

- PS1 Emulator [PCSX-Redux](https://pcsx-redux.consoledev.net/)
- Assembler [armips](https://github.com/Kingcom/armips)
- Editor [VSCode](https://code.visualstudio.com/)
- Decimal/Hexadecimal [converter](https://www.rapidtables.com/convert/number/decimal-to-hex.html)
- Wiki [psx-psx](https://psx-spx.consoledev.net/graphicsprocessingunitgpu/)


### Graphics

3d Primatives
- Lines
- Flat-shaded polygons
- Gouraud-shaded polygons
- Textured polygons

2d Primatives
- Sprites
- Tiles

GPU Registers
- GP0 is used to send packages for rendering and accessing VRAM
	- So if we want to runder something like a polygon we send packets to GP0
- GP1 is used to setup our display control
	- So we set the resoultion of the display
	- Reset the GPU
	- Setting NTSC or PAL

#### GP0

Examples of commands, but is not a complete list.

command|Primitive
---|---
0x20|flat-shaded triangle (opaque)
0x22|flat-shaded triangle (semi-transparent)
0x28|flat shaded quag (opaque)
0x2A|flat-shaded quad (semi-transparent)

[Complete list of commands can be found here](https://problemkaputt.de/psxspx-gpu-render-polygon-commands.htm)

*PACKETS*

1. Command + Color      CCBBGGRR  (CC=command, BB=blue, GG=green, RR=red)
2. Vertex 1             YYYYXXXX  (Y=Y-Coordinate, X=X-Coordinate)
3. Vertex 2             YYYYXXXX
4. Vertex 3             YYYYXXXX
5. Vertex 4 (if quad)   YYYYXXXX

Packets are a combination of commands and parameters.

#### GP1

Control Packets

command|Primitive
---|---
0x00|Reset GPU
0x03|Display enable
0x08|Display mode (320x240, 15-bit mode, NTSC)
0x06|Horizontal display range
0x07|Vertical display range

*PACKETS*

Command + Params CCPPPPPP (CC=command, PP=param)
