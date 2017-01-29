
; ******************************************************
;  * move
;  *****************************************************
move_bullets:
  cmp byte [bulletMoveCycle], 0x18  ; only move the bullets every 24 frames
  je .move
  inc byte [bulletMoveCycle]  ; increase the counter
  jmp .done
.move:
  mov byte [bulletMoveCycle], 0x00  ; reset the counter

  ; delete bullets that are exploded or out of the screen
  mov dx, _check_and_delete_bullet
  call _iterate_bullets

  ; move all bullets
  mov dx, _move_bullet
  call _iterate_bullets
.done:
  ret

; move a single bullet
; CL status
; BX position
_move_bullet:
  cmp cl, 'p'
  je .player
  cmp cl, 'i'
  je .invader
  ret
.player:
  mov al, 0
  jmp .move
.invader:
  mov al, 2
.move:
  push dx
  mov dx, bx
  call move
  mov [si+1], dx
  pop dx
  ret

; delete bullets that are out of the frame or explosions
; CL status
; BX position
_check_and_delete_bullet:
  cmp cl, '#'
  je .remove
  cmp bh, 0
  je .remove
  cmp bh, 24
  je .remove
  jmp .done
.remove:
  call _remove_bullet ; remove the bullet
  sub si, 3           ; reset loop to former bullet -> next loop is the next
.done:
  ret


; ******************************************************
;  * render all bullets
;  *****************************************************

; render all bullets
render_bullets:
  push dx
  mov dx, _render_bullet
  call _iterate_bullets
  pop dx
  ret

; render a single bullet
; CL status
; BX position
_render_bullet:
  push dx
  mov dx, bx
  cmp cl, '#'
  je .explosion
.bullet:
  mov al, '|'
  jmp .print
.explosion:
  mov al, '#'
.print:
  call print_object
  pop dx
  ret


; ******************************************************
;  * check for collisions
;  *****************************************************

; check for collisions
; DX position of the object
check_bullet_collisions:
  push ax
  mov ax, dx
  mov dx, _check_bullet_collision
  call _iterate_bullets
.done:
  mov dx, ax
  pop ax
  ret

; check for a collision between a bullet and an object
; AX object position
; BX bullet position
_check_bullet_collision:
  cmp ax, bx
  jne .done
  mov ax, 0x0000  ; delete object
  mov byte [si], '#' ; set bullet status to explosion
.done
  ret


; ******************************************************
;  * create new bullets
;  *****************************************************

; let the player shoot a bullet
create_player_bullet:
  push ax
  mov al, 'p'
  call _create_bullet
  pop ax
  ret

; let an invader shoot a bullet
create_invader_bullet:
  push ax
  mov al, 'i'
  call _create_bullet
  pop ax
  ret

; create a new bullet
; DX position of creator
; AL status
_create_bullet:
  push dx
  push di
  cmp al, 'p'
  je .player
.invader:
  inc dh  ; adjust the creator position
  jmp .create
.player:
  dec dh  ; adjust the creator position
.create:
  mov di, [bulletListEnd]
  mov [di], al  ; save the status
  mov [di + 1], dx  ; save the position
  add di, 3
  mov byte [di], 0x00 ; set the end of the list
  mov [bulletListEnd], di ; save the list end
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
  cmp si, [bulletListEnd]
  je .done
  mov al, [si+3]  ; copy the status
  mov [si], al
  inc si
  mov ax, [si+3]  ; copy the position
  mov [si], ax
  add si, 2             ; set SI to the next bullet
  jmp .loop
.done:
  sub word [bulletListEnd], 3 ; adjust end of list
  pop si
  pop ax
  ret


; ******************************************************
;  * iterate bullets
;  *****************************************************

; cycle through bullets
; DX address of the loop functions
; calls the function in DX with:
; CL status of the current bullet
; BX postition of the current bullet
_iterate_bullets:
  push si
  push cx
  mov si, bulletListStart
.loop:
  mov cl, [si] ; load STATUS
  cmp cl, 0
  je .done
  mov bx, [si + 1] ; load POSITION
  call dx
  add si, 3
  jmp .loop
.done:
  pop cx
  pop si
  ret
