.data
.align 2
sep: .asciz " "

.macro print_sep()
    li a7, 4
    la a0, sep
    ecall
.end_macro

.macro read_int(%x)
    li a7, 5
    mv %x, a0
    ecall # a0 = input
.end_macro

.macro print_int(%x)
    mv a0, %x
    li a7, 1
    ecall
.end_macro

.macro calculate_ai_address(%i, %array_start_address, %ai_address)
    li t6, 4
    mul t6, t6, %i # t6 = i * 4
    add %ai_address, %array_start_address, %ai_address # a[i]_address = array_pointer + (i * 4)
.end_macro

.macro exit()
    li a7, 10
    ecall
.end_macro


