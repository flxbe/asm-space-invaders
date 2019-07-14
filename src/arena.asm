; ******************************************************
;  * render
;  *****************************************************
render_arena:
  push ax
  push cx
  push dx

  mov al, ICON_WALL
  mov bl, FG_DARK_GRAY
  add bl, BG_BLACK
  mov dh, 0
  mov cl, GAME_HEIGHT
.loop:
  mov dl, 0
  call print_object
  mov dl, GAME_WIDTH
  call print_object
  inc dh
  dec cl
  jnz .loop
.done:
  pop dx
  pop cx
  pop ax
  ret
