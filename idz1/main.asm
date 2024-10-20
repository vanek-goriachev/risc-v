.include "macros.asm"
.data

.align 2
A: .space 64
B: .space 64
buffer: .space 1024

.text
main: 
    addi sp, sp, -4
    # 0(sp) is for n

    print_str("Input N - array length. N must be even. Input 0 to run tests:\n")

    read_int(a0)
    sw a0, 0(sp) # 0(sp) = n
    
    beqz a0, tests_run # if n == 0 -> tests
                       
    # check if n is even 
    # (my idz variant is 24 - if n is odd the task is... idk undefined i think)
    li t1, 2
    rem t1, a0, t1
    beqz t1, manual_run         # if n % 2 == 0 -> manual run             
    j   n_must_be_even          # else -> error

tests_run:
    print_str("aboba abeba")
    j main_end
    
manual_run:
    lw a0, 0(sp) # a0 = n
    la a1, A     # a1 = A array pointer
    jal ra, read_array_from_space_separated_string

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
    j main_end
    
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
    
read_array_from_multiple_strings:
    mv t4, a0 # a0 = n
    mv t3, a1 # a1 = array_pointer

    li t1, 0 # t1 = i
    
    read_array_from_multiple_strings_loop:
        bge t1, t4, read_array_from_multiple_strings_loop_end
        
        # calculate a[i] address
        li t2, 4
        mul t2, t2, t1 # t2 = t1 * 4
        add t2, t2, t3 # t2 = array_pointer + (t1 * 4)
        
        read_int(a0)
        sw a0, 0(t2) # a[i] = a0 = input
        addi t1, t1, 1 # i += 1
        
        j read_array_from_multiple_strings_loop
    read_array_from_multiple_strings_loop_end:
    jalr zero, 0(ra)


read_array_from_space_separated_string:
    push(ra)
    mv t0, a0 # a0 = n
    mv t1, a1 # a1 = array_pointer
    
    print_str("Input space separated array numbers: ")
    # Read string to buffer
    la a0, buffer
    li a1, 100
    li a7, 8
    ecall
    
    mv a0, t0
    mv a1, t1
    la a2, buffer
    jal ra, parse_array_from_string
    
    pop(ra)
    
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
    
parse_array_from_string:
    push(s0)
    push(s1)
    push(s2)
    mv s0, a0 # s0 = n
    mv s1, a1 # s1 = array_pointer
    mv s2, a2 # s2 = buffer pointer
    
    li t1, 0 # t1 = i (counter of readed numbers)
    
    parse_loop:
        beq t1, s0, parse_end  # i == n -> return

        lb t2, 0(s2)           # t2 = symbol
        beqz t2, parse_end     # t2 == "\0" -> return

        li t3, ' '             # 
        beq t2, t3, skip_space # t2 == ' ' -> skip

        li t4, 0               # t4 = current number storage

        parse_number:
            li t3, '0'
            sub t2, t2, t3         # t2  = int(t2)
            li t3, 9
            blt t2, zero, store_number  #
            bgt t2, t3, store_number    # !(0 <= t2 <= 9) -> store number in array

            li t3, 10
            mul t4, t4, t3       
            add t4, t4, t2         # t4 = 10*t4 + t2

            addi s2, s2, 1        
            lb t2, 0(s2)           # t2 = next symbol
            j parse_number

        store_number:
            sw t4, 0(s1)           
            addi s1, s1, 4         
            addi t1, t1, 1         
 
        skip_space:
            addi s2, s2, 1         # Переход к следующему символу
            
        j parse_loop
    parse_end:
        beq t1, s0, parse_array_from_string_return
        print_str("Not enough numbers parsed from string\nExpected:")
        print_int(s0)
        print_str("\nGot:")
        print_int(t1)
        print_str("\n")
    
    parse_array_from_string_return:
        pop(s2)
        pop(s1)
        pop(s0)
        jalr zero, 0(ra)
