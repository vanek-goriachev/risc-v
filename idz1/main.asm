.include "macros.asm"
# .include "array_functions.asm"
.data

.align 2 
A: .space 64
B: .space 64



.text
main:
    li a0, 100
    print_int(a0)
    
    addi sp, sp, -4
    # 0(sp) = n

    read_int(a0)
    sw a0, 0(sp) # 0(sp) = n

    la a0, A     # a0 = array pointer
    lw a1, 0(sp) # a1 = n
    jal ra, read_array

    la a0, A     # a0 = array pointer
    lw a1, 0(sp) # a1 = n
    jal ra, print_array
    
    addi sp, sp, 4
    exit()
    

print_array:
    # a0 = array_pointer
    # a1 = n
    mv t3, a0
    mv t4, a1
    
    li t1, 0 # t1 = i
    
    print_array_loop:
        bge t1, t4, print_array_loop_end
    
        
        # calculate a[i] address
        li t2, 4
        mul t2, t2, t1 # t2 = t1 * 4
        add t2, t2, t3 # t2 = array_pointer + (t1 * 4)
       
        lw a0, 0(t2) # a0 = a[i]
        print_int(a0)
        print_sep()
        
        addi t1, t1, 1 # i += 1
        
        j print_array_loop
    print_array_loop_end:
    jalr zero, 0(ra)
    
read_array:
    mv t3, a0 # a0 = array_pointer
    mv t4, a1 # a1 = n

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
    jalr zero, 0(ra)


