gcc -m32 -c print.c -o print.obj

gcc -shared -m32 -o print.dll print.obj

nasm -f win32 call.asm -o call.obj -l call.lst

GoLink.exe  /console /entry _start call.obj kernel32.dll print.dll

