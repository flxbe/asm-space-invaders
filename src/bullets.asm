; ******************************************************
;  * move
;  *****************************************************
move_bullets:
  cmp byte [bullets_move_cycle], BULLETS_MOVE_CYCLE  ; only move the bullets every 28 frames
  je .move
  inc byte [bullets_move_cycle]  ; increase the counter
  jmp .ret
.move:
  push di

  mov byte [bullets_move_cycle], 0  ; reset the counter

  ; delete bullets that are exploded or out of the screen
  mov di, _check_and_delete_bullet
  call _iterate_bullets

  ; move all bullets
  mov di, _move_bullet
  call _iterate_bullets

  pop di
.ret:
  ret

; move a single bullet
; SI bullet pointer
_move_bullet:
  push ax
  push dx
  mov al, [si]      ; load status
  mov dx, [si + BULLET_POSITION_OFFSET]  ; load position
  cmp al, BULLET_STATUS_PLAYER
  je .player
  cmp al, BULLET_STATUS_INVADER
  je .invader
  jmp .done
.player:
  mov al, MOVE_UP
  jmp .move
.invader:
  mov al, MOVE_DOWN
.move:
  call move
  mov [si + BULLET_POSITION_OFFSET], dx  ; save new position
.done:
  pop dx
  pop ax
  ret

; delete bullets that are out of the screen or exploded
; SI bullet pointer
_check_and_delete_bullet:
  push ax
  push dx
  mov al, [si]      ; load status
  cmp al, ICON_EXPLOSION_BULLET
  je .remove
  mov dx, [si + BULLET_POSITION_OFFSET]  ; load position
  cmp dh, 0
  je .remove
  cmp dh, GAME_HEIGHT - 1
  je .remove
  jmp .done
.remove:
  call _remove_bullet ; remove the bullet
  sub si, BULLET_SIZE           ; reset loop to former bullet -> next loop is the next
.done:
  pop dx
  pop ax
  ret


; ******************************************************
;  * render all bullets
;  *****************************************************

; render all bullets
render_bullets:
  push di
  mov di, _render_bullet
  call _iterate_bullets
  pop di
  ret

; render a single bullet
; SI bullet pointer
_render_bullet:
  push ax
  push dx
  mov al, [si]      ; load status
  mov dx, [si + BULLET_POSITION_OFFSET]  ; load position
  cmp al, ICON_EXPLOSION_BULLET
  jne .set_bullet
  mov bl, FG_GREEN
  add bl, BG_BLACK
  jmp .print
.set_bullet:
  mov al, ICON_BULLET  ; set bullet
  mov bl, FG_RED
  add bl, BG_BLACK
.print:
  call print_object
  pop dx
  pop ax
  ret


; ******************************************************
;  * check for collisions
;  *****************************************************

; check for collisions
; DX position of the object
check_bullet_collisions:
  mov di, _check_bullet_collision
  call _iterate_bullets
.done:
  ret

; check for a collision between a bullet and an object
; DX object position
; SI bullet pointer
_check_bullet_collision:
  push ax
  mov ax, [si + BULLET_POSITION_OFFSET]  ; load position
  cmp ax, dx
  jne .done
  mov dx, INVALID_STATE      ; set position to invalid state
  mov byte [si], ICON_EXPLOSION_BULLET  ; set bullet status to explosion
.done:
  pop ax
  ret


; ******************************************************
;  * create new bullets
;  *****************************************************

; let the player shoot a bullet
create_player_bullet:
  push ax
  mov al, BULLET_STATUS_PLAYER
  call _create_bullet
  pop ax
  ret

; let an invader shoot a bullet
create_invader_bullet:
  push ax
  mov al, BULLET_STATUS_INVADER
  call _create_bullet
  pop ax
  ret

; create a new bullet
; DX position of creator
; AL status
_create_bullet:
  push dx
  push di
  cmp al, BULLET_STATUS_PLAYER
  je .player
.invader:
  inc dh  ; adjust the creator position
  jmp .create
.player:
  dec dh  ; adjust the creator position
.create:
  mov di, [bullet_list_end]
  mov [di], al  ; save the status
  mov [di + BULLET_POSITION_OFFSET], dx  ; save the position
  add di, BULLET_SIZE
  mov byte [di], 0x00 ; set the end of the list
  mov [bullet_list_end], di ; save the list end
.done:
  pop di
  pop dx
  ret


; ******************************************************
;  * remove a bullet
;  *****************************************************

; delete the bullet at SI
_remove_bullet:
  push ax
  push si
.loop:
  cmp si, [bullet_list_end]
  je .done
  mov al, [si + BULLET_SIZE]  ; copy the status
  mov [si], al
  mov ax, [si + BULLET_SIZE + BULLET_POSITION_OFFSET]  ; copy the position
  mov [si + BULLET_POSITION_OFFSET], ax
  add si, BULLET_SIZE             ; set SI to the next bullet
  jmp .loop
.done:
  sub word [bullet_list_end], BULLET_SIZE ; adjust end of list
  pop si
  pop ax
  ret


; ******************************************************
;  * iterate bullets
;  *****************************************************

; cycle through bullets
; DI address of the loop functions
; calls the function in DX with:
; SI bullet pointer
_iterate_bullets:
  push si
  mov si, bullet_list
.loop:
  cmp si, [bullet_list_end]
  je .done
  call di
  add si, 3
  jmp .loop
.done:
  pop si
  ret
