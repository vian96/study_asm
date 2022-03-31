gcc -m32 -c print.c -o print.obj -S -masm=intel -o print.lst 

nasm -f win32 call.asm -o call.obj -l call.lst

GoLink.exe  /console /entry _start call.obj kernel32.dll print.obj

