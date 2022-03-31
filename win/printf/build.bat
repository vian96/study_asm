nasm -f win32 printf.asm -o printf.obj -l printf.lst

GoLink.exe  /dll /console printf.obj kernel32.dll  

GoLink.exe  /console /entry main printf.obj kernel32.dll call.o 

gcc -m32 call.c -c -S -masm=intel

