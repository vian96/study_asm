nasm -f win32 hw.asm -o hw.obj -l hw.lst

GoLink.exe  /console /entry _start hw.obj kernel32.dll  
