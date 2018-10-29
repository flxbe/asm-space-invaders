; constants

; GAME WINDOW PARAMETERS
%define GAME_WIDTH 27
%define GAME_HEIGHT 25

; GAME PARAMETERES
%define NUM_INVADERS 12
%define INVADERS_MOVE_CYCLES 40
%define BULLETS_MOVE_CYCLE 28

; SPECIAL CONSTANT
%define INVALID_STATE 0x0000

; ICONS
%define ICON_PLAYER 'M'
%define ICON_INVADER 'T'
%define ICON_BULLET '|'
%define ICON_EXPLOSION_BULLET '#'
%define ICON_WALL '#'

; GAME DIFFICULTY LEVEL KEYS
%define GAME_EASY_LEVEL_KEY '1'
%define GAME_MEDIUM_LEVEL_KEY '2'
%define GAME_HARD_LEVEL_KEY '3'

; INVADERS DIFFICULTY LEVEL (invaders shoot cycles)
%define INVADERS_EASY_LEVEL 6
%define INVADERS_MEDIUM_LEVEL 4
%define INVADERS_HARD_LEVEL 2

; GAME STATES
%define GAME_STATE_PLAYING 0
%define GAME_STATE_PLAYER_WIN 1
%define GAME_STATE_INVADERS_WIN 2

; PLAY KEYS
%define START_KEY ' '
%define RETRY_KEY 'r'
%define MOVE_LEFT_KEY 'a'
%define MOVE_RIGHT_KEY 'd'
%define SHOOT_KEY ' '

; MOVE DIRECTIONS
%define MOVE_UP 0
%define MOVE_RIGHT 1
%define MOVE_DOWN 2
%define MOVE_LEFT 3
%define MOVE_RESET 4

; BULLET
%define BULLET_STATUS_END_OF_LIST 0
%define BULLET_STATUS_EXPLOSION '#'
%define BULLET_STATUS_PLAYER 'p'
%define BULLET_STATUS_INVADER 'i'

%define BULLET_STATUS_OFFSET 0
%define BULLET_STATUS_SIZE 1
%define BULLET_POSITION_OFFSET BULLET_STATUS_OFFSET + BULLET_STATUS_SIZE
%define BULLET_POSITION_SIZE 2
%define BULLET_SIZE BULLET_POSITION_OFFSET + BULLET_POSITION_SIZE

; INVADER
%define INVADER_POSITION_OFFSET 0
%define INVADER_POSITION_SIZE 2
%define INVADER_SIZE INVADER_POSITION_OFFSET + INVADER_POSITION_SIZE

; clear the cursor blinking
mov	ah, 0x01
mov	cx, 0x2000
int 	0x10

; calculate game screen position
mov	ah, 0x0F
int	0x10 ; load the number of columns
sub byte ah, 1
sub ah, GAME_WIDTH
sar ah, 1
mov [display_offset], ah


jmp main

; include dependencies
%include "./src/keyboard.asm"
%include "./src/display.asm"
%include "./src/game.asm"

%include "./src/bullets.asm"
%include "./src/invaders.asm"
%include "./src/player.asm"
%include "./src/arena.asm"


; main loop
main:
  call intro
.game:
  call select_difficulty_level
  call game
  call end
  jmp .game


; intro screen
intro:
  call clear_screen

  mov ax, intro_string_t
  mov bx, intro_string_o
  call print_window
.wait:
  call get_key
  mov al, [key_pressed]
  cmp al, START_KEY
  je .done
  jmp .wait
.done:
  ret

; select difficulty level
select_difficulty_level:
  call clear_screen
  call print_select_difficulty_level
.wait:
  call get_key
  mov al, [key_pressed]
  cmp al, GAME_EASY_LEVEL_KEY
  je .easy_level
  cmp al, GAME_MEDIUM_LEVEL_KEY
  je .medium_level
  cmp al, GAME_HARD_LEVEL_KEY
  je .hard_level
  jmp .wait
.easy_level:
  mov byte [invaders_shoot_cycles], INVADERS_EASY_LEVEL
  jmp .done
.medium_level:
  mov byte [invaders_shoot_cycles], INVADERS_MEDIUM_LEVEL
  jmp .done
.hard_level:
  mov byte [invaders_shoot_cycles], INVADERS_HARD_LEVEL
.done:
  ret


; game loop
game:
  call init_game
.loop:

  ; get key if available
  call check_key

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
  call render_controlls

  ; update to game state
  call update_game_state
  cmp byte [game_state], GAME_STATE_PLAYING
  jne .done

  mov cx, 0x0000  ; 0.05 seconds (cx:dx)
  mov dx, 0x1388  ; 0x00001388 = 5000
  call sleep
  jmp	.loop
.done:
  ret


; end screen
end:
  cmp byte [game_state], GAME_STATE_PLAYER_WIN
  je .player_win
  mov ax, end_string_l
  jmp .print_game_result
.player_win:
  mov ax, end_string_w
.print_game_result:
  mov bx, end_string_o
  call print_window
.wait:
  call get_key
  mov al, [key_pressed]
  cmp al, RETRY_KEY
  je .done
  jmp .wait
.done:
  ret


; window
window_bar db "######################", 0
window_space db "#                    #", 0

; intro
intro_string_t db "#   SPACE INVADERS   #", 0
intro_string_o db "#   SPACE to start   #", 0

; select difficulty level
select_difficulty_string db "#  Select difficulty #", 0
easy_level_string        db "#  1     Easy        #", 0
medium_level_string      db "#  2    Medium       #", 0
hard_level_string        db "#  3     Hard        #", 0

; end
end_string_w db "#    PLAYER  wins    #", 0
end_string_l db "#    INVADERS win    #", 0
end_string_o db "# Press R to restart #", 0

; controls
left_string db "A = move left", 0
right_string db "D = move right", 0
shoot_string db "SPACE = shoot", 0


segment .bss
  ; display properties
  display_offset resb 1

  ; keyboard
  key_pressed resb 1

  ; game state
  ; 0: still playing
  ; 1: player wins
  ; 2: invaders win
  game_state resb 1

  ; player
  player_pos resw 1
  ; invaders
  invaders resw NUM_INVADERS
  num_invaders_alive resb 1
  invaders_move_direction resb 1
  invaders_move_cycle resb 1
  invaders_shoot_cycle resb 1
  invaders_shoot_cycles resb 1
  ; bullets:  0x STATUS PY PX
  ; STATUS == 0: end of list
  ; STATUS == #: explosion
  ; STATUS == p: player bullet
  ; STATUS == i: invader bullet
  bullets_move_cycle resb 1
  bullet_list_end resw 1
  bullet_list resb 1
