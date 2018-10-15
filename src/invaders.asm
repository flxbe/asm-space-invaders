; constants
%define INVADERS 'T'

; ******************************************************
;  * move
;  *****************************************************
move_invaders:
  cmp byte [invaders_move_cycle], INVADERS_MOVE_CYCLES
  je .move
  inc byte [invaders_move_cycle]
  jmp .done
.move:
  push si
  push cx
  push dx
  push ax

  mov byte [invaders_move_cycle], 0 ; reset the cycle counter
  mov si, invaders
  mov cl, NUM_INVADERS
.loop:
  ; load position
  mov dx, [si]

  ; skip invader, if destroyed
  cmp dx, INVALID_STATE
  je .continue

  ; move invader
  mov al, [invaders_move_direction]
  call move

  ; check collisions
  call check_bullet_collisions

  mov [si], dx

  cmp dx, INVALID_STATE
  jne .shoot

  ; dec invader counter
  dec byte [num_invaders_alive]
  jmp .continue

.shoot:
  ; shoot, if necessary
  cmp byte [invaders_shoot_cycle], INVADERS_SHOOT_CYCLES
  jne .continue
  call create_invader_bullet
.continue:
  add si, INVADERS_NEXT_OFFSET
  dec cl
  jnz .loop

  ; update the shoot cycle
  cmp byte [invaders_shoot_cycle], INVADERS_SHOOT_CYCLES
  jne .inc_shoot_cycle
  mov byte [invaders_shoot_cycle], 0
  jmp .update_move_direction
.inc_shoot_cycle:
  inc byte [invaders_shoot_cycle]

.update_move_direction:
  mov al, [invaders_move_direction]
  inc al
  cmp al, 4
  jl .save_move_direction
  xor al, al  ; reset the move direction
.save_move_direction:
  mov [invaders_move_direction], al

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

  mov al, INVADERS
  mov si, invaders
  mov cl, NUM_INVADERS
.loop:
  mov dx, [si]
  cmp dx, INVALID_STATE
  je .continue
  call print_object
.continue:
  add si, INVADERS_NEXT_OFFSET
  dec cl
  jnz .loop
.done:
  pop cx
  pop ax
  pop si
  ret
