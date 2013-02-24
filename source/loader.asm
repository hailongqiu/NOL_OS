
BOTRAK  equ  0x00280000    
DSKCAC  equ  0x00100000
DSKCACO equ  0x00008000

CYLS  equ 0x0ff0 ;设定启动区.
LEDS  equ 0x0ff1 ;
VMODE equ 0x0ff2 ;
SCRNX equ 0x0ff4 ;
SCRNY equ 0x0ff6 ;
VRAM  equ 0x0ff8    

    org 0xc200
    mov al, 0x13
    mov ah, 0x00
    int 0x10

    mov byte [VMODE], 8 ; 记录画面模式
    mov word [SCRNX], 320
    mov word [SCRNY], 200
    mov dword [VRAM], 0x000a0000

    mov ah, 0x02
    int 0x16
    mov [LEDS], al

    mov si, msg
loop_str:
    mov al, [si]
    add si, 1
    cmp al, 0
    je fin; 
    mov ah, 0x0e
    mov bx, 15
    int 0x10
    jmp loop_str

init_kernel:
    ; 屏蔽所有中断请求.
    mov al, 0xff
    out 0x21, al
    nop
    out 0xa1, al
    cli ; 关中断.
    ;
    call waitkdout 
    mov al, 0xd1
    out 0x64, al
    call waitkdout
    mov al, 0xdf ; 开启A20地址线.
    out 0x60, al
    call waitkdout
    ;
    lgdt [GDTR0] ; 夹在 gdtr
    ; 设置cr0
    mov eax, cr0
    and eax, 0x7fffffff ; 与操作.
    or  eax, 0x00000001 ; 或操作.
    mov cr0, eax
    jmp pipelineflush
pipelineflush:
    mov ax, 1 * 8
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    ; 从源拷贝到目地, 每次拷贝4.
    ;mov esi, bootpack ; 源
    ;mov edi, BOTRAK   ; 目地->0x00280000.
   ; mov ecx, 512 * 1024 / 4
   ; call memcpy

   ; mov esi, 0x7c00
   ; mov edi, DSKCAC
   ; mov ecx, 512 / 4
   ; call memcpy

   ; mov esi, DSKCACO + 512 ; 0x00008000 + 512(0x200)
   ; mov edi, DSKCAC + 512  ; 0x00010000 + 512(0x200)
   ; mov ecx, 0
   ; mov cl, byte [CYLS]
    ; 512 一个扇区的大小. 18 最大扇区数. 2 磁头. 
   ; imul ecx, 512*18*2/4 ; ecx = ecx * (512 * 18 * 2 / 4)
   ; sub ecx, 512/4
   ; call memcpy

   ; mov ebx, BOTRAK
   ; mov ecx, [ebx + 16]
   ; add ecx, 3
   ; shr ecx, 2
   ; jz skip
   ; mov esi, [ebx + 20]
   ; add esi, ebx
   ; mov edi, [ebx + 12]
skip:
    ; 进入保护模式.
    mov esp, [ebx + 12]
    jmp dword 1*8:0x90000  

memcpy:
    mov eax, [esi]
    add esi, 4
    mov [edi], eax
    add esi, 4
    sub ecx, 1
    jnz memcpy
    ret
fin:
    hlt 
    jmp fin

waitkdout:
    in al, 0x64
    test al, 0x02
    jnz waitkdout
    ret
msg:
    db 0x0a, 0x0a
    db "kernel load..."
    db 0x0a
    db 0

; GDT0 .
GDT0: 
    GDTK_NULL:
        dw 0x0000, 0x0000, 0x0000, 0x0000 ; gdt 第0项空白 这是规定.
    GDT0_KERNEL_DATA: ; 非一致性-数据段描述符, 可读/写.
        dw 0xffff ; 段限长公式: 段界限(4G) = limit(0xFFFFF) * 4k + 0FFFFh ; 4k=1000H
        dw 0x0000 ; 基地址 ( Base addres : 00 )
        dw 0x9200 ; p(1) DPL(00) S(1) TYPE(O[0], E[0], W[1], A[0]), 基地址为(00) 
        dw 0x00cf ; 基地址为(00), G(1) D(1) 0 AVL(0), 段限长(F)
    GDT0_KERNEL_CODE: ; 代码段描述符, 执行/可读.
        dw 0xffff ; 段限长公式: 段界限(2G) = limit(0x7FFFF) * 4k + 0FFFFh
        dw 0x0000 ; 基地址 (00)
        dw 0x9a00 ; P(1) DPL(00) S(1) TYPE(1, 0, 1, 0), 基地址(00) 非一致代码段
        dw 0x00cf ; 基地址(00), G(0) D(1) 0 AVL(0), 段限长(7)
GDTR0:
    dw $ - GDT0 ; GDTR表长度 ; GDT0_KERNEL_CODE
    dd GDT0  ; 32位线性地址.



    
