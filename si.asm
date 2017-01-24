; initialize the environment
mov ax, 0x07c0
mov ds, ax      ; set the DS to the start of the programm
                ; this has to be indirectly, since all segement-registers can not directly be written to.



; game logic
gameloop:
  call clearScreen


call clearScreen
call printInvaders
jmp $



; screen functions
clearScreen:
  mov ax, 0x0700
  mov bh, 0x0f
  xor cx, cx
  mov dx, 0x1950
  int 0x10
  ret

moveCursor:
  mov ah, 0x02
  xor bh, bh
  int 0x10
  ret

printInvaders:
  mov si, invaders
  call printInvader
  inc si
  inc si
  call printInvader
  inc si
  inc si
  call printInvader
  inc si
  inc si
  call printInvader
  inc si
  inc si
  ret

printInvader:
  mov dx, [si]
  call moveCursor
  mov al, 'T'
  call printChar
  ret

printChar:
  mov ah, 0x0E	;Tell BIOS that we need to print one charater on screen.
  mov bh, 0x00	;Page no.
  mov bl, 0x07	;Text attribute 0x07 is lightgrey font on black background
  int 0x10
  ret

printString:
  mov al, [si]
  or al, al
  jz done
  call printChar
  inc si
  jmp printString


; utility
done:
  ret



; variables
player_pos dw 0x0000
invaders dw 0x0101, 0x0303, 0x0105, 0x0307
;invaders db 1, 1, 3, 3, 5, 1, 7, 3



; ################################################
; spacing and signature
times 510 - ($ - $$) db 0
dw 0xaa55
