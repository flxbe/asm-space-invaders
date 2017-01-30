; check whether a key has is pressed
; if yes, load it into the buffer
check_key:
  push ax

  ; check whether there is a key available
  mov	ah, 0x01
	int	0x16
  jz .reset ; no key in the buffer

  ; get key from the buffer
  mov	ah, 0x00
	int	0x16
  mov [key_pressed], al
  jmp .done
.reset:
  mov byte [key_pressed], 0
.done:
  pop ax
  ret

; wait for a key to be pressed
get_key:
  push ax
  mov	ah, 0x00
	int	0x16
  mov [key_pressed], al
  pop ax
  ret