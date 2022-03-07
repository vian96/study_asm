.model tiny
.code
org 100h

locals @@

;------------------------------------------------
; CONSTANTS
;------------------------------------------------
start_y     equ 10
start_x     equ 30

size_x      equ 20
size_y      equ 10

color       equ 070h    ; black on white

line_len    equ 80      ; length of cmd line 
;------------------------------------------------

start:
jmp main

;------------------------------------------------
; DRAW A LINE
; Draws a line in console with args:
;   ah - color
;   cx - len
;   si - addr of 3 byte array
;   di - start of line
;   es = 0b800h
;
; CHANGED: ax, cx, si, di, es
;------------------------------------------------
draw_line proc
    ; evil string instructions manipulation 
    lodsb
    stosw
    lodsb
    rep stosw
    lodsb
    stosw
    ret
draw_line endp
;------------------------------------------------

;------------------------------------------------
; DRAW A FRAME
; Draws a frame in console with args:
;   ah - color
;   cx - len
;   si - addr of 9 byte array
;   di - start of line
;   es = 0b800h
;
; CHANGED: ax, cx, si, di, es
;------------------------------------------------
draw_frame proc
    ; placed first so it doesn't affect ax reg
    ; because es can only be changed by ax
    mov ax, 0b800h
    mov es, ax

    mov ah, color
    mov cx, size_x
    mov di, 2*((start_y * line_len) + start_x) ; this formula is coord of frame
    call draw_line

    @@line_offset = 2*line_len - 2 * size_x - 4

    mov cx, size_y
    @@lines:
        ; TODO is it good to manipulate cx and stk like this?
        push cx
        add di, @@line_offset
        mov cx, size_x
        call draw_line
        add si, -3
        pop cx
        loop @@lines

    ; print bottom line
    add si, 3
    add di, @@line_offset
    mov cx, size_x
    call draw_line

    ret
draw_frame endp

; TODO array of ofsset of styles 

main:
    ; if no args go to default
    mov al, ds:[80h]
    cmp al, 0h
    je @@default_frame
    
    mov al, ds:[82h]
    cmp al, '0' 
    je @@default_frame

    ; TODO add check for size of the second arg

    mov si, 84h
    call draw_frame
    jmp @@ret

@@default_frame:
    mov si, offset frame_borders
    call draw_frame

@@ret:  ; exit 0
    mov ax, 4c00h
    int 21h

    frame_borders db "+-+| |+-+"

end start

; strlen strchr strncpy strncmp atoi itoa (2, 8, 10, 16)


