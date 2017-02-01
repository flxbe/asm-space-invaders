## ASM Space Invaders

This is a very simple clone of the popular arcade game Space Invaders.

The game is written in x86-assembly. The resulting program includes a bootloader and the game itself.
It leverages the existing BIOS functionality to receive keyboard input and print ASCII chars to the screen.

![Screenshot](https://cloud.githubusercontent.com/assets/9663231/22428356/03a23148-e707-11e6-9909-6ec9db57325a.png)
![Screenshot](https://cloud.githubusercontent.com/assets/9663231/22428754/85eb2488-e708-11e6-8377-adb2d4827a90.png)
![Screenshot](https://cloud.githubusercontent.com/assets/9663231/22428350/0041ae16-e707-11e6-9845-aa35266ca5c3.png)

#### Building the Project
In order to assemble the source of the project you have to install [NASM](http://www.nasm.us/).
You can then start the building process by executing

```bash
./scripts/create.sh
```

This should create the file `build/image.img`.

#### Execution
As far as I know the programm *should* be bootable from a floppy disk. I did not test this, though.

Alternatively, it is possible to run the image using [QEMU](http://wiki.qemu.org/Main_Page).
After the emulator is installed and the image is created, you can start the program using

```bash
./scripts/start.sh
```

## Project Structure
The bootloader is located in `bootloader.asm`. Its single purpose is to load the game's binary file
and then jump to its entrypoint. The main file of the game is `space-invaders.asm`.

Have a look at the [Wiki](https://github.com/flxbe/asm-space-invaders/wiki) for a more detailed documentation.

### Additional Notes

If you have any questions about this project please feel free to open an issue.
I really enjoyed working on it and I am happy to share the little I know.

A big **Thank You** to Peter Mikkelsen and his [ASM Snake Project](https://gitlab.com/pmikkelsen/asm_snake) as well as to 
[OSDev.org](http://wiki.osdev.org/Main_Page).
