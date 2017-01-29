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

; game logic
gameLoop:
  call clearScreen

deleteBullets:
  cmp byte [bulletMoveCycle], 0x18
  jne deleteBuleltsFinish
  mov dx, deleteBulletsLoopFunction
  call cycleThroughBullets
deleteBuleltsFinish:


moveBullets:
  cmp byte [bulletMoveCycle], 0x18
  jge moveBulletsStart   ; move-cycle -> move all bullets
  inc byte [bulletMoveCycle]
  jmp moveBulletsFinish ; no move-cycle -> jump to end of loop
moveBulletsStart:
  mov byte [bulletMoveCycle], 0x00 ; reset the cycle counter
  mov dx, moveBulletLoopFunction
  call cycleThroughBullets
moveBulletsFinish:


movePlayer:
  mov dx, [playerPos]  ; copy the player position into BX

  mov	ah, 0x01
	int	0x16      	; check if key available
  jz finishPlayerMove     ; no key availabe -> ZF is set
  mov	ah, 0x00
	int	0x16        ; remove the key from the buffer

  cmp al, 'a'
  je left
  cmp al, 'd'
  je right
  cmp al, ' '
  je shoot
  jmp finishPlayerMove
shoot:
  mov al, 2
  call createBullet
  jmp finishPlayerMove
left:
  mov al, 3
  call move
  jmp savePlayerMove
right:
  mov al, 1
  call move
savePlayerMove:
  mov [playerPos], dx
finishPlayerMove:

moveInvaders:
  cmp byte [invaderMoveCycle], 0x30
  je moveInvadersStartLoop
  inc byte [invaderMoveCycle]
  jmp printGame
moveInvadersStartLoop:
  mov byte [invaderMoveCycle], 0x00 ; reset the cycle counter
  mov si, invaders
  mov cl, [numInvaders]
moveInvadersLoop:
  ; load position
  mov dx, [si]

  ; skip invader, if destroyed
  cmp dx, 0x0000
  je moveInvadersContinueLoop

  ; move invader
  mov al, [moveDirection]
  call move

  ; check collisions
  push si
  push cx
  mov ax, dx
  mov dx, checkCollisionLoopFunction
  call cycleThroughBullets
  pop cx
  pop si

  mov dx, ax  ; save new position
  mov [si], dx

  cmp dx, 0x0000
  je moveInvadersContinueLoop

  ; shoot, if necessary
  cmp byte [invaderShootCycle], 0x04
  jne moveInvadersContinueLoop
  mov al, 3
  call createBullet
moveInvadersContinueLoop:
  inc si
  inc si
  dec cl
  jnz moveInvadersLoop

updateShootCycle:
  cmp byte [invaderShootCycle], 4
  jne incShootCycle
  mov byte [invaderShootCycle], 0
  jmp updateMoveDirection
incShootCycle:
  inc byte [invaderShootCycle]

updateMoveDirection:
  mov al, [moveDirection]
  inc al
  cmp al, 4
  jl saveMoveDirection
resetMoveDirection:
  xor al, al
saveMoveDirection:
  mov [moveDirection], al
  
printGame:
  ; print arena
  mov al, '#'
  mov dh, 0
  mov cl, 25
printArenaLoop:
  mov dl, 0
  call print
  mov dl, [gameWidth]
  call print
  inc dh
  dec cl
  jnz printArenaLoop

  ;print bullets
  mov dx, renderBulletLoopFunction
  call cycleThroughBullets

  ; print player
  mov al, 'M'
  mov dx, [playerPos]
  call print  
  
  ; print invaders
  mov al, 'T'
  mov si, invaders
  mov cl, [numInvaders]
printInvadersLoop:
  mov dx, [si]
  cmp dx, 0x0000
  je printInvadersLoopContinue
  call print
printInvadersLoopContinue:
  inc si
  inc si
  dec cl
  jnz printInvadersLoop

finishLoop:
  mov	cx, 0x0000	; Sleep for 0,05 seconds (cx:dx)
	mov	dx, 0x1388	; 0x00001388 = 5000
	mov	ah, 0x86
	int	0x15		; Sleep
	jmp	gameLoop	; loop


; DX position to move
; AL direction
move:
  cmp al, 1
  je moveRight
  cmp al, 2
  je moveDown
  cmp al, 3
  je moveLeft
moveUp:
  cmp dh, 0
  jle moveDone
  sub	word dx, 0x0100
	jmp moveDone
moveDown:
  cmp dh, 24
  jge moveDone
  add	word dx, 0x0100
	jmp moveDone
moveLeft:
  cmp dl, 1
  jle moveDone
  sub	word dx, 0x0001
	jmp moveDone
moveRight:
  cmp dl, [moveWidth]
  jge moveDone
  add	word dx, 0x0001
moveDone:
  ret


; ################################################
; bullet utility functions

; DX position of creator
; AL status
createBullet:
  cmp al, 2
  je createPlayerBullet
createInvaderBullet:
  inc dh  ; adjust the creator position
  jmp createBulletFinish
createPlayerBullet:
  dec dh  ; adjust the creator position
createBulletFinish:
  mov di, [bulletListEnd]
  mov [di], al  ; save the status
  inc di
  mov [di], dx  ; save the position
  inc di
  inc di
  mov byte [di], 0x00 ; set the end of the list
  mov [bulletListEnd], di ; save the list end
  ret

; delete the bullet at SI
removeBullet:
  push ax
  push si
removeBulletStartLoop:
  cmp si, [bulletListEnd]
  je removeBulletFinish

  mov al, [si+3]  ; copy the status
  mov [si], al
  inc si
  mov ax, [si+3]  ; copy the position
  mov [si], ax
  add si, 2             ; set SI to the next bullet
  jmp removeBulletStartLoop
removeBulletFinish:
  sub word [bulletListEnd], 3 ; adjust end of list
  pop si
  pop ax
  ret

; delete bullets that are out of the frame or explosions
; CL status
; BX position
deleteBulletsLoopFunction:
  cmp cl, 1
  je deleteBulletLoopRemove
  cmp bh, 0
  je deleteBulletLoopRemove
  cmp bh, 24
  je deleteBulletLoopRemove
  jmp deleteBulletLoopFinish
deleteBulletLoopRemove:
  call removeBullet ; remove the bullet
  sub si, 3         ; reset loop to former bullet -> next loop is the next
deleteBulletLoopFinish:
  ret



; move a single bullet
; CL status
; BX position
moveBulletLoopFunction:
  cmp cl, 2
  je movePlayerBullet
  cmp cl, 3
  je moveInvaderBullet
  ret
movePlayerBullet:
  mov al, 0
  jmp moveBullet
moveInvaderBullet:
  mov al, 2
moveBullet:
  push dx
  mov dx, bx
  call move
  mov [si+1], dx
  pop dx
  ret

; render bullet
; CL status
; BX position
renderBulletLoopFunction:
  push dx
  mov dx, bx
  cmp cl, 1
  je setExplosionChar
setBulletChar:
  mov al, '|'
  jmp printBullet
setExplosionChar:
  mov al, '#'
printBullet:
  call print
  pop dx
  ret


; check for collisions
; AX object position
; BX bullet position
checkCollisionLoopFunction:
  cmp ax, bx
  jne checkCollisionDone
  mov ax, 0x0000  ; delete object
  mov byte [si], 1 ; set bullet status to explosion
checkCollisionDone:
  ret


; cycle through bullets
; DX address of the loop functions
; calls the function in DX with:
; CL status of the current bullet
; BX postition of the current bullet
cycleThroughBullets:
  push si
  push cx
  mov si, bulletListStart
cycleThroughBulletsLoopStart:
  mov cl, [si] ; load STATUS
  cmp cl, 0
  je moveBulletsFinishLoop
  mov bx, [si + 1] ; load POSITION
  call dx
  add si, 3
  jmp cycleThroughBulletsLoopStart
moveBulletsFinishLoop:
  pop cx
  pop si
  ret


; ################################################
; screen functions

clearScreen:
  mov ax, 0x0700
  mov bh, 0x0f
  xor cx, cx
  mov dx, 0x1950
  int 0x10
  ret

; DX position of char
; AL character
print:
  add byte dl, [displayOffset]
  call moveCursor
  sub byte dl, [displayOffset]
  call printChar
  ret

; DX cursor position
moveCursor:
  mov ah, 0x02
  xor bh, bh
  int 0x10
  ret

; AL character
printChar:
  mov ah, 0x0E	;Tell BIOS that we need to print one charater on screen.
  mov bh, 0x00	;Page no.
  mov bl, 0x07	;Text attribute 0x07 is lightgrey font on black background
  int 0x10
  ret

; utility
done:
  ret



; ################################################
; variables

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
; STATUS == 1: explosion
; STATUS == 2: player bullet
; STATUS == 3: invader bullet
bulletMoveCycle db 0
bulletListEnd dw 0
bulletListStart db 0x00



; ################################################
; spacing
times 1014 - ($ - $$) db 0
