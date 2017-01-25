### ASM Space Invaders

This is a very simple clone of the popular arcade game Space Invaders.

The game is written in x86-assembly. The resulting program includes a bootloader and the game itself.
It leverages the existing BIOS functionality to receive keyboard input and print ASCII chars to the screen.

![Screenshot](https://cloud.githubusercontent.com/assets/9663231/22274367/6e2b71ce-e2a6-11e6-96c5-b7132fab0af5.png)

#### Building the Project
In order to assemble the source of the project you have to install [NASM](http://www.nasm.us/).
You can then start the building process by executing

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

#### Additional Notes
A big thank you to Peter Mikkelsen and his [ASM Snake Project](https://gitlab.com/pmikkelsen/asm_snake).
