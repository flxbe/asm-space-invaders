clear_screen:
  mov ax, 0x0700
  mov bh, 0x0f
  xor cx, cx
  mov dx, 0x1950
  int 0x10
  ret

; DX position of char
; AL character
print_object:
  add byte dl, [displayOffset]
  call move_cursor
  sub byte dl, [displayOffset]
  call print_char
  ret

; DX cursor position
move_cursor:
  mov ah, 0x02
  xor bh, bh
  int 0x10
  ret

; AL character
print_char:
  mov ah, 0x0E	;Tell BIOS that we need to print one charater on screen.
  mov bh, 0x00	;Page no.
  mov bl, 0x07	;Text attribute 0x07 is lightgrey font on black background
  int 0x10
  ret

; SI string pointer
print_string:
  mov al, [si]
  cmp al, 0x00
  je .done
  call print_char
  inc si
  jmp print_string
.done:
  ret
