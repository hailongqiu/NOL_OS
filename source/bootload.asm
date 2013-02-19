; hailongqiu
; 356752238@qq.com
;
;
;
; 

    BITS 16 ; 实模式

    jmp short bootloader_start
    nop
; FAT12 文件格式头, 暂不支持NTFS. 
; 引导扇区需要bpb等头信息才能被识别.
; 才能够根据FAT12文件格式来扫描移动设备加载我们的内核名.

volume_id     db 0x00000000
volume_label  db "NOLOS     " ; 
file_system   db "FAT12   "   ; 文件系统类型
;
bootloader_start:
    mov ax, 0x7c0
    cli
    ;
    sti
    ; 数据段设置. 
    mov ax, 0x7c0
    mov ds, ax
;
; 需要加载的内核文件名.
    kernel_filename db KERNEL_FILENAME

;
    times 510 - ($ - $$) db 0
    dw 0xAA55

buffer:
