nasm -f win32 printf.asm -o printf.obj -l printf.lst

GoLink.exe  /dll /console printf.obj kernel32.dll  

gcc -m32 call.c printf.dll -o call
