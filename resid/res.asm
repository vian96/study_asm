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
; NEW09
; 
; Function to replace int09
; Prints a table with registers and calls old int09
;------------------------------------------------
new09       proc
            pushf
            push ax cx si di es ds

            in al, 60h  ; get pressed button from keyboard
            cmp al, 2   ; if key is not 1 then do nothing
            jne @@old_int

            mov ax, cs
            mov ds, ax  ; needed for using fuctions, since they use ds inside

            mov ax, 0b800h
            mov es, ax
            mov al, 0FFh
            mov es:[(80*6+30)*2], al

@@old_int:
            pop ds es di si cx ax
            popf
            db 0eah     ; opcode of jmp far
old09       dd 0        ; place for ptr to prev int

            frame_borders db "+-+| |+-+"

new09       endp

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


main:
        xor bx, bx
        mov es, bx      ; es = 0
        mov bx, 09h*4   ; *4 is needed because every int ptr is 4 bytes

        ; saves 4 bytes of ptr to int func
        mov ax, es:[bx]
        mov word ptr cs:[old09], ax
        mov ax, es:[bx+2]
        mov word ptr cs:[old09+2], ax

        mov ax, offset new09
        mov es:[bx], ax
        mov es:[bx+2], cs

        mov dx, offset main     ; leaving as resident, offset main is enough since interruption is before
        shl dx, 4
        inc dx
        mov ax, 3100h
        int 21h

end start
