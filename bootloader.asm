; initialize the environment
mov ax, 0x07c0
mov ds, ax

; the segment of the game
mov ax, 0x07e0

; setup the file-source
mov ch, 0x00    ; cylinder 0
mov cl, 0x02    ; sector 2 (skip first sector, which is the bootloader)
mov dh, 0x00    ; head 0
mov dl, 0x00    ; drive 0 (floppy disk)

; setup the destination
mov es, ax      ; segment starts directly after the bootloader (7c00 - 7dff)
mov bx, 0x0000

; copy data into RAM
read:
  mov al, 0x04    ; read four sectors
  mov ah, 0x02    ; int 13h subfunction 2 -> read sectors (512 bytes) from disk
  int 0x13        ; copy sectors to ES:BX
  jc read         ; carry-flag is set -> there was a read-error, retry

; rebase segments for game execution
mov ax, 0x07e0
mov ds, ax  ; data segment
mov es, ax  ; additional segments
mov fs, ax
mov gs, ax
mov ss, ax  ; stack segment

; reset stack pointer
; mov sp, 0x0000

; enter the game code -> set CS:IP
jmp 0x07e0:0x0000

; spacing and signature
times 510 - ($ - $$) db 0
dw 0xaa55