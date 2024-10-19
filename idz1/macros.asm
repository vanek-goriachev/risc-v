.data
.align 2
sep: .asciz " "

.global sep

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

.macro print_array(%array_pointer, %n)
    la t3, %array_pointer
    mv t4, %n
    
    li t1, 0 # t1 = i
    
    read_array_loop:
        bge t1, t4, read_array_loop_end
    
        
        # calculate a[i] address
        li t2, 4
        mul t2, t2, t1 # t2 = t1 * 4
        add t2, t2, t3 # t2 = array_pointer + (t1 * 4)
       
        lw a0, 0(t2) # a0 = a[i]
        print_int(a0)
        print_sep()
        
        addi t1, t1, 1 # i += 1
        
        j read_array_loop
    read_array_loop_end:
.end_macro

.macro read_array_multiple_strings(%array_pointer, %n)
    la t3, %array_pointer
    mv t4, %n

    li t1, 0 # t1 = i
    
    read_array_loop:
        bge t1, t4, read_array_loop_end
        
        # calculate a[i] address
        li t2, 4
        mul t2, t2, t1 # t2 = t1 * 4
        add t2, t2, t3 # t2 = array_pointer + (t1 * 4)
        
        read_int(a0)
        sw a0, 0(t2) # a[i] = a0 = input
        addi t1, t1, 1 # i += 1
        
        j read_array_loop
    read_array_loop_end:
.end_macro

.macro parse_array_from_single_string(%array_pointer, %n, %buffer)

.end_macro


.macro exit()
    li a7, 10
    ecall
.end_macro
