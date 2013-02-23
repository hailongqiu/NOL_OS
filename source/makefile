NASM = nasm


boot.bin : bootload.asm 
	$(NASM) bootload.asm -o boot.bin -l boot.lst

test_kernel.sys : test_kernel.asm 
	$(NASM) -f bin test_kernel.asm -o test_kernel.sys -l test_kernel.lst

copy:
	cp nol.img ../bochs
dd:
	dd if=boot.bin of=nol.ima bs=512 count=1 conv=notrunc
clear:
	rm boot.bin
	rm boot.lst
