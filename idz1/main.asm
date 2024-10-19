.include "macros.asm"
.data
.align 2 
A: .space 64
B: .space 64

.text
main:
    addi sp, sp, -4
    # 0(sp) = n

    read_int(a0)
    sw a0, 0(sp) # 0(sp) = n
    # lw a0, 0(sp) # unneded operation, a0 is already = 0(sp)
    read_array_multiple_strings(A, a0)

    lw a0, 0(sp)
    print_array(A, a0)
    
    addi sp, sp, 4
    exit()
