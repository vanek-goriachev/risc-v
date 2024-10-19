.include "macros.asm"
.data

.align 2 
A: .space 64
B: .space 64

.text
main: 
    addi sp, sp, -4
    # 0(sp) is for n

    read_int(a0)
    sw a0, 0(sp) # 0(sp) = n

    # check if n is even 
    # (my idz variant is 24 - if n is odd the task is... idk undefined i think)
    li t2, 2
    rem t1, a0, t2 # t1 = a0 % 2 = n % 2
    bnez t1, n_must_be_even

    lw a0, 0(sp) # a0 = n
    la a1, A     # a1 = A array pointer
    jal ra, read_array

    lw a0, 0(sp) # a0 = n
    la a1, A # a1 = A array pointer
    la a2, B # a2 = B array pointer
    jal ra, process_array
    
    lw a0, 0(sp) # a0 = n
    la a1, B     # a1 = array pointer
    jal ra, print_array
    j main_end
n_must_be_even:
    print_str("N must be a even number")
main_end:
    addi sp, sp, 4
    exit()
    

print_array:
    mv t4, a0 # a0 = n
    mv t3, a1 # a1 = array_pointer
    
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
    mv t4, a0 # a0 = n
    mv t3, a1 # a1 = array_pointer

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

process_array:
    push(s0)
    mv s0, a0
    push(s1)
    mv s1, a1
    push(s2)
    mv s2, a2
    
    # s0 = n
    # s1 = source array pointer
    # s2 = target_array_pointer
    
    li t1, 0 # t1 = i
    
    process_array_loop:
        bge t1, s0, process_array_loop_end
        
        # calculate a[i] address
        li t2, 4
        mul t2, t2, t1 # t2 = t1 * 4
        add t2, t2, s1 # t2 = A_array_pointer + (t1 * 4)
        
        lw t2, 0(t2) # t2 = a[i]
        
        # calculate b[i]
        li t3, 4
        mul t3, t3, t1 # t2 = t1 * 4
        add t3, t3, s2 # t2 = array_pointer + (t1 * 4)
        
        li t4, 2
        rem t4, t1, t4 # t4 = i % 2
        bnez t4, move_item_bacward
        
        move_item_forward:
            # calculate b[i+1] address
            sw t2, 4(t3)
            j end_forward_or_backward_branch
        move_item_bacward:
            # calculate b[i-1] address
            sw t2, -4(t3)
        end_forward_or_backward_branch:
        
        addi t1, t1, 1 # i += 1
        
        j process_array_loop
    process_array_loop_end:
    
    pop(s2)
    pop(s1)
    pop(s0)
    
    jalr zero, 0(ra)
    

are_arrays_equal:
    push(s0)
    mv s0, a0
    push(s1)
    mv s1, a1
    push(s2)
    mv s2, a2
    
    # s0 = n
    # s1 = array1_pointer
    # s2 = array2_pointer
    
    li t1, 0 # t1 = i
    
    are_arrays_equal_loop:
        bge t1, s0, print_arrays_equal
        
        # calculate a[i] address
        li t2, 4
        mul t2, t2, t1 # t2 = t1 * 4
        add t2, t2, s1 # t2 = A_array_pointer + (t1 * 4)
        
        lw t2, 0(t2) # t2 = a[i]
        
        # calculate b[i]
        li t3, 4
        mul t3, t3, t1 # t2 = t1 * 4
        add t3, t3, s2 # t2 = array_pointer + (t1 * 4)
        
        lw t3, 0(t3) # t3 = b[i]
        
        bne t2, t3, print_arrays_not_equal
        
        addi t1, t1, 1 # i += 1
        
        j are_arrays_equal_loop
    print_arrays_equal:
    	print_str("Arrays are equal\n")
    	j are_arrays_equal_exit
    print_arrays_not_equal:
    	print_str("Arrays are not equal\n")
    
    are_arrays_equal_exit:
    
    pop(s2)
    pop(s1)
    pop(s0)
    
    jalr zero, 0(ra)
    

