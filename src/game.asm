; ******************************************************
;  * initialize the game state
;  *****************************************************
init_game:
  ; initialize the player
  mov word [player_pos], 0x1401

  ; initialize the invaders
  mov byte [invaders_move_direction], MOVE_RIGHT
  mov byte [invaders_move_cycle], 0
  mov byte [invaders_shoot_cycle], 0
  mov byte [num_invaders_alive], NUM_INVADERS
  mov word [invaders + INVADERS_SIZE *  0], 0x0102
  mov word [invaders + INVADERS_SIZE *  1], 0x0304
  mov word [invaders + INVADERS_SIZE *  2], 0x0106
  mov word [invaders + INVADERS_SIZE *  3], 0x0308
  mov word [invaders + INVADERS_SIZE *  4], 0x010A
  mov word [invaders + INVADERS_SIZE *  5], 0x030C
  mov word [invaders + INVADERS_SIZE *  6], 0x010E
  mov word [invaders + INVADERS_SIZE *  7], 0x0310
  mov word [invaders + INVADERS_SIZE *  8], 0x0112
  mov word [invaders + INVADERS_SIZE *  9], 0x0314
  mov word [invaders + INVADERS_SIZE * 10], 0x0116
  mov word [invaders + INVADERS_SIZE * 11], 0x0318

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
  cmp word [player_pos], INVALID_STATE
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
  cmp al, MOVE_RIGHT
  je .right
  cmp al, MOVE_DOWN
  je .down
  cmp al, MOVE_LEFT
  je .left
.up:
  cmp dh, 0
  jle .done
  sub	word dx, 0x0100
	jmp .done
.down:
  cmp dh, GAME_HEIGHT - 1
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
