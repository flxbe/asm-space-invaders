; ******************************************************
;  * check whether the game is finished
;  *****************************************************
; AL 0: continue
;    1: player lost
;    2: player won
check_game_state:
  push dx
  ; check whether the player is destroyed
  mov dx, [playerPos]
  cmp dx, 0x0000
  je .player

  ; check whether the player has won

  ; continue
  mov al, 0
  jmp .done
.player:
  mov al, 1
  jmp .done
.invader:
  mov al, 2
.done:
  pop dx
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
  cmp dl, [moveWidth]
  jge .done
  add	word dx, 0x0001
.done:
  ret
