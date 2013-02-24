# 保护模式 loader.bin
nasm -f bin loader.asm -o loader.bin
# 生成 kernel.bin
nasm -f elf kernel.asm -o kernel.asmo
nasm -f elf kernel_lib.asm -o kernel_lib.o
gcc -fpack-struct -std=c99 -c kernel.c -o kernel.o
ld -o kernel.ld -Ttext 0x90000 -e main kernel.asmo kernel.o kernel_lib.o
objcopy -R .note -R .comment -S -O binary kernel.ld kernel.bin

