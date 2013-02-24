
[BITS 32]
[GLOBAL main]
[EXTERN kernel_main]

jmp main

main:
    call kernel_main
    jmp $
