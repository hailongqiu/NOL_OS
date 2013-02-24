NASM = nasm


boot.bin : boot.asm 
	$(NASM) boot.asm -o boot.bin -l boot.lst

copy:
	cp nol.img ../bochs
dd:
	dd if=boot.bin of=nol.ima bs=512 count=1 conv=notrunc
clear:
	rm boot.bin
	rm boot.lst
