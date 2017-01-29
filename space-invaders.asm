; clear the cursor blinking
mov	ah, 0x01
mov	cx, 0x2000
int 	0x10

; calculate game screen position
mov	ah, 0x0F
int	0x10 ; load the number of columns
sub byte ah, 1
sub ah, [gameWidth]
sar ah, 1
mov [displayOffset], ah

; initialize the bullet list by setting  the end-pointer to the list-start
mov word [bulletListEnd], bulletListStart


jmp main

; include dependencies
%include "./src/print_util.asm"
%include "./src/game_util.asm"

%include "./src/bullets.asm"
%include "./src/invaders.asm"
%include "./src/player.asm"
%include "./src/arena.asm"


main:
  call game

  mov	cx, 0x0000	; Sleep for 0,05 seconds (cx:dx)
	mov	dx, 0x1388	; 0x00001388 = 5000
	mov	ah, 0x86
	int	0x15		; Sleep

	jmp	main	; loop


game:
  call check_game_state

  ; move
  call move_bullets
  call move_player
  call move_invaders

  ; render
  call clear_screen
  call render_arena
  call render_bullets
  call render_player
  call render_invaders

  mov dx, 0x0000
  call move_cursor
  mov si, title
  call print_string
  ret

; variables

; strings
title db "SPACE INVADERS", 0

; display
screenWidth db 0
gameWidth db 27
moveWidth db 26
displayOffset db 0

; player
playerPos dw 0x1401

; invaders
moveDirection db 1
invaders dw 0x0102, 0x0304, 0x0106, 0x0308, 0x010A, 0x030C, 0x010E, 0x0310, 0x0112, 0x0314, 0x0116, 0x0318  ; 0xPYPX
numInvaders db 12
invaderMoveCycle db 0
invaderShootCycle db 0

; bullets:  0x PY PX STATUS
; STATUS == 0: end of list
; STATUS == #: explosion
; STATUS == p: player bullet
; STATUS == i: invader bullet
bulletMoveCycle db 0
bulletListEnd dw 0
bulletListStart db 0x00


; spacing
times 1014 - ($ - $$) db 0
