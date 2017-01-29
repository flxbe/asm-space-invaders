
; ******************************************************
;  * move
;  *****************************************************
move_invaders:
  cmp byte [invaderMoveCycle], 0x30
  je .move
  inc byte [invaderMoveCycle]
  jmp .done
.move:
  push si
  push cx
  push dx
  push ax

  mov byte [invaderMoveCycle], 0x00 ; reset the cycle counter
  mov si, invaders
  mov cl, [numInvaders]
.loop:
  ; load position
  mov dx, [si]

  ; skip invader, if destroyed
  cmp dx, 0x0000
  je .continue

  ; move invader
  mov al, [moveDirection]
  call move

  ; check collisions
  push si
  push cx
  call check_bullet_collisions
  pop cx
  pop si

  mov [si], dx

  cmp dx, 0x0000
  je .continue

  ; shoot, if necessary
  cmp byte [invaderShootCycle], 0x04
  jne .continue
  call create_invader_bullet
.continue:
  add si, 2
  dec cl
  jnz .loop

  ; update the shoot cycle
  cmp byte [invaderShootCycle], 4
  jne .inc_shoot_cycle
  mov byte [invaderShootCycle], 0
  jmp .update_move_direction
.inc_shoot_cycle:
  inc byte [invaderShootCycle]

.update_move_direction:
  mov al, [moveDirection]
  inc al
  cmp al, 4
  jl .save_move_direction
  xor al, al  ; reset the move direction
.save_move_direction:
  mov [moveDirection], al

  ; restore registers
  pop ax
  pop dx
  pop cx
  pop si
.done:
  ret

; ******************************************************
;  * render
;  *****************************************************
render_invaders:
  push si
  push ax
  push cx

  mov al, 'T'
  mov si, invaders
  mov cl, [numInvaders]
.loop:
  mov dx, [si]
  cmp dx, 0x0000
  je .continue
  call print_object
.continue:
  add si, 2
  dec cl
  jnz .loop
.done:
  pop cx
  pop ax
  pop si
  ret