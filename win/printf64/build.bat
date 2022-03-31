nasm -f win64 printf.asm -o printf.obj -l printf.lst

GoLink.exe  /entry _main /console kernel32.dll user32.dll printf.obj call.o
