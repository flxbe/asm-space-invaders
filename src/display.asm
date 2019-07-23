clear_screen:
  mov ax, 0x0700
  mov bh, 0x0f
  xor cx, cx
  mov dx, 0x1950
  int 0x10
  ret

; print the window
; AX: title
; BX: options
print_window:
  push si
  push dx
  push bx
  push ax
  mov bl, FG_LIGHT_GRAY
  add bl, BG_BLACK
  mov dl, [display_offset]
  add dl, 3
  ; top
  mov dh, 0x05
  mov si, window_bar
  call print_string
  ; space 1
  inc dh
  mov si, window_space
  call print_string
  ; title
  inc dh
  pop si
  call print_string
  ; space 2
  inc dh
  mov si, window_space
  call print_string
  ; options
  inc dh
  pop si
  call print_string
  ; space 3
  inc dh
  mov si, window_space
  call print_string
  ; bottom
  inc dh
  mov si, window_bar
  call print_string
  ; return
  pop dx
  pop si
  ret

; DX position of char
; AL character
; BL attribute
print_object:
  add byte dl, [display_offset]
  call move_cursor
  sub byte dl, [display_offset]
  call print_char
  ret

; DX cursor position
move_cursor:
  mov ah, 0x02
  xor bh, bh
  int 0x10
  ret

get_cursor_position:
  push cx
  mov ah, 0x03 ; read cursor position
  xor bh, bh
  int 0x10
  pop cx
  ret

; DX cursor position
move_cursor_next:
  push dx
  call get_cursor_position
  inc dl
  cmp dl, 0x50 ; right edge of screen
  jle .done
  inc dh       ; move cursor to new line
  mov dl, 0x00
  cmp dh, 0x19 ; end of screen
  jle .done
  call clear_screen
.done:
  call move_cursor
  pop dx
  ret

; AL character
; BL attribute
print_char:
  push cx
  mov ah, 0x09 ; indicating the write Char/Attr pair function
  mov bh, 0x00 ; page number
  mov cx, 0x01 ; repeat count
  int 0x10
  call move_cursor_next
  pop cx
  ret

; BL attribute
; DX position
; SI string pointer
print_string:
  push ax
  call move_cursor
.loop:
  mov al, [si]
  cmp al, 0x00
  je .done
  call print_char
  inc si
  jmp .loop
.done:
  pop ax
  ret

render_controlls:
  push si
  push dx
  mov bl, FG_LIGHT_GRAY
  add bl, BG_BLACK
  mov dx, 0x0000
  mov si, left_string
  call print_string
  inc dh
  mov si, right_string
  call print_string
  inc dh
  mov si, shoot_string
  call print_string
  pop dx
  pop si
  ret

print_select_difficulty_level:
  push si
  push dx
  mov bl, FG_LIGHT_GRAY
  add bl, BG_BLACK
  mov dl, [display_offset]
  add dl, 3
  ; top
  mov dh, 0x05
  mov si, window_bar
  call print_string
  inc dh
  mov si, window_space
  call print_string
  inc dh
  mov si, select_difficulty_string
  call print_string
  inc dh
  mov si, window_space
  call print_string
  inc dh,
  mov si, easy_level_string
  call print_string
  inc dh
  mov si, medium_level_string
  call print_string
  inc dh
  mov si, hard_level_string
  call print_string
  inc dh
  mov si, window_space
  call print_string
  inc dh
  mov si, window_bar
  call print_string
  pop dx
  pop si
  ret
