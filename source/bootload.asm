; hailongqiu
; 356752238@qq.com
;
;
;

    BITS 16 ; 实模式
    org 0x7c00
    jmp bootloader_start
    nop
; FAT-12 bpb等头信息才能被识别. 
oem_name     db "DEEPIN" ; 厂商名
byte_per_sec dw 0x200 ; 每扇区字节数 512 (必须为 512)
sec_per_clus db 0x1   ; 每簇扇区数 (必须为1扇区)
rsvd_sec_cnt dw 0x1   ; Boot记录占用多少扇区 FAT的起始位置 （一般从第一个扇区开始) 
num_fats     db 0x2   ; 共有多少FAT表 (必须为2)
root_ent_cnt dw 0xE0  ; 224 根目录大小 (一般是224)
tot_sec16    dw 0xB40 ; 2880 扇区总数 (必须是2880扇区)
media_type   db 0xF0  ; 介质描述符 (磁盘的种类, 必须是 0xf0)
fat_sz16     dw 0x9   ; FAT的长度 每FAT扇区数 (必须是9扇区)
sec_per_trk  dw 0x12  ; 18 每磁道扇区数 (一个磁道有几个扇区, 必须是18)
num_heads    dw 0x2   ; 磁头数(面数) (必须是2)
hidd_sec     dd 0x0   ; 隐藏扇区数 (不是用分区,必须为0）
tot_sec32    dd 0xB40 ; 如果BPB_TotSec16是0，由这个值记录扇区数 (重写一次磁盘大小)
drv_num      db 0x0   ; 中断13的驱动器号
reservedl    db 0x0   ; 未使用
boot_sig     db 0x29  ; 扩展引导标记 (29h) 
vol_id       dd 0x0   ; 卷序列号
vol_label    db "NOLOS     " ;  卷标, 必须 11 个字节, 磁盘名称 
file_system_type    db "FAT12   " ; 文件系统类型
; 引导代码.
bootloader_start:
    ; 初始化 ss 栈段寄存器.
    mov ax, 0
    mov ss, ax
    mov sp, 0x7c00 ; 栈的生长方向, 从高地址向低地址.
    mov ds, ax
    ; 读取盘.
    mov ax, 0x0820
    mov es, ax
    mov ch, 0 ; 柱面 0
    mov dh, 0 ; 磁头 0 
    mov cl, 2 ; 扇区 2
readloop:
    mov si, 0
retry:
    mov ah, 0x2 ; 读盘
    mov al, 1 ; 处理的扇区数
    mov bx, 0
    mov dl, 0x00 ; 驱动号
    int 0x13
    jnc next

    add si, 1
    cmp si, 5
    jae error ; si >= 5
    mov ah, 0x00
    mov dl, 0x00
    int 0x13
    jmp retry

next:
    mov ax, es 
    add ax, 0x0020
    mov es, ax
    add cl, 1
    cmp cl, 18
    jbe readloop
    mov cl, 1
    add dh, 1
    cmp dh, 2
    jb readloop
    mov dh, 0
    add ch, 1
    cmp ch, CYLS
    jb readloop
fin:
    hlt
    jmp fin
error:
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

msg:
    db 0x0a, 0x0a
    db "load error..."
    db 0x0a
    db 0
CYLS equ  10 ; 常量
    ;
    times 510 - ($ - $$) db 0
    dw 0xAA55

