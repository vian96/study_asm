nasm -f win32 hw.asm -o hw.obj

GoLink.exe  /console /entry _start hw.obj kernel32.dll  
