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
    ecall 
    mv %x, a0 # %x = input
.end_macro

.macro print_int(%x)
    mv a0, %x
    li a7, 1
    ecall
.end_macro

.macro print_str (%x)
    .data
        str: .asciz %x
   .text
       push (a0)
       li a7, 4
       la a0, str
       ecall
       pop (a0)
.end_macro

.macro print_char(%x)
    li a7, 11
    li a0, %x
    ecall
.end_macro

.macro newline
    print_char('\n')
.end_macro

.macro exit()
    li a7, 10
    ecall
.end_macro

.macro push(%x)
    addi sp, sp, -4
    sw %x, (sp)
.end_macro

# Выталкивание значения с вершины стека в регистр
.macro pop(%x)
    lw %x, (sp)
    addi sp, sp, 4
.end_macro

