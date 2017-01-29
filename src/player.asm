
; ******************************************************
;  * move
;  *****************************************************
move_player:
  push dx

  mov dx, [playerPos]  ; copy the player position into BX

  mov	ah, 0x01
	int	0x16      	; check if key available
  jz .done     ; no key availabe -> ZF is set
  mov	ah, 0x00
	int	0x16        ; remove the key from the buffer

  cmp al, 'a'
  je .left
  cmp al, 'd'
  je .right
  cmp al, ' '
  je .shoot
  jmp .done
.shoot:
  call create_player_bullet
  jmp .done
.left:
  mov al, 3
  call move
  jmp .save
.right:
  mov al, 1
  call move
.save:
  mov [playerPos], dx
.done:
  pop dx
  ret


; ******************************************************
;  * render
;  *****************************************************
render_player:
  push ax
  push dx
  mov al, 'M'
  mov dx, [playerPos]
  call print_object 
  pop dx
  pop ax 
  ret