nasm -f win64 win64.asm -o win64.obj -l win64.lst

GoLink /entry _start /console win64.obj kernel32.dll user32.dll

