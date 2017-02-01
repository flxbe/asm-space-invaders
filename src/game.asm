; ******************************************************
;  * initialize the game state
;  *****************************************************
init_game:
  ; initialize the player
  mov word [player_pos], 0x1401

  ; initialize the invaders
  mov byte [invaders_move_direction], 1
  mov byte [invaders_move_cycle], 0
  mov byte [invaders_shoot_cycle], 0
  mov byte [num_invaders_alive], NUM_INVADERS
  mov word [invaders +  0], 0x0102
  mov word [invaders +  2], 0x0304
  mov word [invaders +  4], 0x0106
  mov word [invaders +  6], 0x0308
  mov word [invaders +  8], 0x010A
  mov word [invaders + 10], 0x030C
  mov word [invaders + 12], 0x010E
  mov word [invaders + 14], 0x0310
  mov word [invaders + 16], 0x0112
  mov word [invaders + 18], 0x0314
  mov word [invaders + 20], 0x0116
  mov word [invaders + 22], 0x0318

  ; initialize the bullets
  mov byte [bullets_move_cycle], 0
  mov byte [bullet_list], 0
  mov word [bullet_list_end], bullet_list
  
  ret


; ******************************************************
;  * check whether the game is finished
;  *****************************************************
; AL 0: continue
;    1: invaders win
;    2: player wins
check_game_state:
  ; check whether the player is destroyed
  cmp word [player_pos], 0x0000
  je .invaders

  ; check whether the player wins
  cmp byte [num_invaders_alive], 0
  je .player

  ; continue
  mov al, 0
  jmp .done
.invaders:
  mov al, 1
  jmp .done
.player:
  mov al, 2
.done:
  ret


; sleep
; DX Duration in micro-seconds
sleep:
  push ax

  mov	cx, 0x0000	; Sleep for 0,05 seconds (cx:dx)
  mov	dx, 0x1388	; 0x00001388 = 5000
  mov	ah, 0x86
  int	0x15		; Sleep

  pop ax
  ret


; ******************************************************
;  * move an object
;  *****************************************************
; DX position to move
; AL direction
move:
  cmp al, 1
  je .right
  cmp al, 2
  je .down
  cmp al, 3
  je .left
.up:
  cmp dh, 0
  jle .done
  sub	word dx, 0x0100
	jmp .done
.down:
  cmp dh, 24
  jge .done
  add	word dx, 0x0100
	jmp .done
.left:
  cmp dl, 1
  jle .done
  sub	word dx, 0x0001
	jmp .done
.right:
  cmp dl, GAME_WIDTH - 1
  jge .done
  add	word dx, 0x0001
.done:
  ret
