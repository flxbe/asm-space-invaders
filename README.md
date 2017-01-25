### ASM Space Invaders

This is a very simple clone of the popular arcade game Space Invaders.

The game is written in x86-assembly. The resulting program includes a bootloader and the game itself.
It leverages the existing BIOS functionality to receive keyboard input and print ASCII chars to the screen.

#### Building the Project
In order to assemble the source of the project you have to install [NASM](http://www.nasm.us/).
You can than start the building process by executing

```bash
./scripts/create.sh
```

You should now find the file `build/image.img`.

#### Execution
As far as I know, the programm *should* be bootable from a floppy disk. I did not test this, though.

Alternatively, it is possible to run the image using [QEMU](http://wiki.qemu.org/Main_Page).
After the emulator is installed and the image is created, you can start the program using

```bash
./scripts/start.sh
```
