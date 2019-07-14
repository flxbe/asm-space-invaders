; ******************************************************
;  * move
;  *****************************************************
move_player:
  push ax
  push dx

  ; load data
  mov dx, [player_pos]
  mov al, [key_pressed]

  cmp al, MOVE_LEFT_KEY
  je .left
  cmp al, MOVE_RIGHT_KEY
  je .right
  cmp al, SHOOT_KEY
  je .shoot
  jmp .check
.shoot:
  call create_player_bullet
  jmp .check
.left:
  mov al, MOVE_LEFT
  call move
  jmp .check
.right:
  mov al, MOVE_RIGHT
  call move
.check:
  call check_bullet_collisions
  mov [player_pos], dx
.done:
  pop dx
  pop ax
  ret


; ******************************************************
;  * render
;  *****************************************************
render_player:
  push ax
  push dx
  mov dx, [player_pos]
  cmp dx, INVALID_STATE
  je .done
  mov al, ICON_PLAYER
  mov bl, FG_CYAN
  add bl, BG_BLACK
  call print_object
.done:
  pop dx
  pop ax
  ret
