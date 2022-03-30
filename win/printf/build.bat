nasm -f win32 printf.asm -o printf.obj -l printf.lst

GoLink.exe  /console /entry _start printf.obj kernel32.dll  
