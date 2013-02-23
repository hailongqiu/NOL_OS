    
    
    org 0xc200

    mov al, 0x13
    mov ah, 0x00
    int 0x10
   



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
