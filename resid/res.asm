.model tiny

.code 
org 100h
locals @@

;------------------------------------------------
; CONSTANTS
;------------------------------------------------
start_y     equ 10
start_x     equ 30

size_x      equ 10
size_y      equ 4

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
            push bp si di es ds dx cx bx ax

            in al, 60h      ; get pressed button from keyboard
            cmp al, 2       ; if key is not 1 then do nothing
            je @@start_table
            
            cmp al, 3
            je @@jmp_repair
            
            jmp @@old_int   ; needed because this label is too far

@@jmp_repair:
            jmp @@start_repair

@@start_table:
            ; for stosw and lodsw
            mov ax, cs
            mov es, ax  
            mov ax, 0b800h
            mov ds, ax

;------------------------------------------------
; Saving old data
;------------------------------------------------
            @@line_offset = 2*line_len - 2 * size_x - 4

            mov si, 2*((start_y * line_len) + start_x) ; start of frame
            mov di, offset old_screen

            mov cx, size_y + 2
@@copy_frame:
            push cx
            mov cx, size_x + 2
@@copy_line:
            lodsw
            stosw
            loop @@copy_line

            add si, @@line_offset
            pop cx
            loop @@copy_frame

            ; needed for using fuctions, since they use ds inside
            mov ax, cs
            mov ds, ax  
            mov ax, 0b800h
            mov es, ax

;------------------------------------------------
; Drawing table itself
;------------------------------------------------
@@draw_table:
            mov si, offset frame_borders
            call draw_frame

            mov bp, sp  ; needed for addressing since sp doesn't work ¯\_(ツ)_/¯

            ; TODO is it okay to have copy-paste like this?
            ; TODO maybe strcpy?
            mov al, 'a'
            mov es:[2 * ((start_y + 1) * line_len + start_x + 2)], al
            mov al, 'x'
            mov es:[2 * ((start_y + 1) * line_len + start_x + 3)], al
            mov al, ':'
            mov es:[2 * ((start_y + 1) * line_len + start_x + 4)], al
            mov di, 2 * ((start_y + 1) * line_len + start_x + 6)
            mov ax, ss:[bp]
            call itoa16_resid

            mov al, 'b'
            mov es:[2 * ((start_y + 2) * line_len + start_x + 2)], al
            mov al, 'x'
            mov es:[2 * ((start_y + 2) * line_len + start_x + 3)], al
            mov al, ':'
            mov es:[2 * ((start_y + 2) * line_len + start_x + 4)], al
            mov di, 2 * ((start_y + 2) * line_len + start_x + 6)
            mov ax, ss:[bp + 2]
            call itoa16_resid

            mov al, 'c'
            mov es:[2 * ((start_y + 3) * line_len + start_x + 2)], al
            mov al, 'x'
            mov es:[2 * ((start_y + 3) * line_len + start_x + 3)], al
            mov al, ':'
            mov es:[2 * ((start_y + 3) * line_len + start_x + 4)], al
            mov di, 2 * ((start_y + 3) * line_len + start_x + 6)
            mov ax, ss:[bp + 4]
            call itoa16_resid

            mov al, 'd'
            mov es:[2 * ((start_y + 4) * line_len + start_x + 2)], al
            mov al, 'x'
            mov es:[2 * ((start_y + 4) * line_len + start_x + 3)], al
            mov al, ':'
            mov es:[2 * ((start_y + 4) * line_len + start_x + 4)], al
            mov di, 2 * ((start_y + 4) * line_len + start_x + 6)
            mov ax, ss:[bp + 6]
            call itoa16_resid

            jmp @@old_int

;------------------------------------------------
; Puts old data from screen instead of table
;------------------------------------------------
@@start_repair:
            mov ax, cs
            mov ds, ax
            mov ax, 0b800h
            mov es, ax

            mov di, 2*((start_y * line_len) + start_x) ; start of frame
            mov si, offset old_screen

            mov cx, size_y + 2
@@copy_screen:
            push cx
            mov cx, size_x + 2
@@copy_sc_line:
            lodsw
            stosw
            loop @@copy_sc_line

            add di, @@line_offset
            pop cx
            loop @@copy_screen

@@old_int:
            pop ax bx cx dx ds es di si bp
            popf

            db 0eah     ; opcode of jmp far
old09       dd 0        ; place for ptr to prev int

            frame_borders db "+-+| |+-+"
            old_screen  db 2*(size_x+2)*(size_y+2) + 2 dup(0)  ; places size_of_table zeroes (becasue borders are not included in size_x/y and 2* for color) 

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
;   ah - color          - using a constant
;   cx - len            - using a constant
;   si - addr of 9 byte array
;   di - start of line  - using a constant
;   es = 0b800h         - using a constant
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
        add si, -3      ; to return to begin of table
        pop cx
        loop @@lines

    ; print bottom line
    add si, 3
    add di, @@line_offset
    mov cx, size_x
    call draw_line

    ret
draw_frame endp

;------------------------------------------------
; ITOA16_RESID
; Translates unsigned bx number to str pointed by di with base 2^cl for resident purposes
; It doesn't place \0 or $ at the end
; TODO make program always fill four symbols
;   di - ptr of str to be written
;   ax - number to be translated
;   es - segment of memory to write
; CHANGED: bx, dx, di, si
;------------------------------------------------
itoa16_resid proc
    mov bx, ax
    shr bx, 12
    mov bl, cs:[bx + offset XlatTable]
    mov es:[di], bl
    add di, 2

    mov bx, ax
    and bx, 0F00h
    shr bx, 8
    mov bl, cs:[bx + offset XlatTable]
    mov es:[di], bl
    add di, 2

    mov bx, ax
    and bx, 0F0h
    shr bx, 4
    mov bl, cs:[bx + offset XlatTable]
    mov es:[di], bl
    add di, 2

    mov bx, ax
    and bx, 0Fh
    mov bl, cs:[bx + offset XlatTable]
    mov es:[di], bl
    add di, 2

@@ret:
    ret

    XlatTable db "0123456789ABCDEF"

itoa16_resid endp

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

        ; jmp new09

        mov dx, offset main     ; leaving as resident, offset main is enough since interruption is before
        shl dx, 4
        inc dx
        mov ax, 3100h
        int 21h

end start
