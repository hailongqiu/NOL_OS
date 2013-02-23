    
CYLS equ 0x0ff0 ;设定启动区.
LEDS equ 0x0ff1 ;
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
    je fin ; 
    mov ah, 0x0e
    mov bx, 15
    int 0x10
    jmp loop_str
fin:
    hlt 
    jmp fin
msg:
    db 0x0a, 0x0a
    db "kernel load..."
    db 0x0a
    db 0

; GDT0 .
GDT0: 
    dw 0x0000, 0x0000, 0x0000, 0x0000 ; gdt 空白 这是规定.
GDT0_KERNEL_DATA: ; 非一致性-数据段描述符, 可读/写.
    dw 0xffff ; 段限长公式: 段界限 = limit(0xFFFFF) * 4k + 0FFFFh
    dw 0x0000 ; 基地址 ( Base addres : 00 )
    dw 0x9200 ; p(1) DPL(00) S(1) TYPE(O[0], E[0], W[1], A[0]), 基地址为(00) 
    dw 0x00cf ; 基地址为(00), G(1) D(1) 0 AVL(0), 段限长(F)
GDT0_KERNEL_CODE: ; 代码段描述符, 执行/可读.
    dw 0xffff ; 段限长公式: 段界限 = limit(0x7FFFF) * 4k + 0FFFFh
    dw 0x0000 ; 基地址 (00)
    dw 0x9a28 ; P(1) DPL(00) S(1) TYPE(1, 0, 1, 0), 基地址(28) 非一致代码段
    dw 0x0047 ; 基地址(00), G(0) D(1) 0 AVL(0), 段限长(7)
GDTR0:
    dw 8 * 3 - 1 ; GDTR表长度 ; GDT0_KERNEL_CODE
    dd GDT0  ; 32位线性地址.


