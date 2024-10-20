print_array: # void print_array(n, &array)
    push(s0)
    push(s1)

    mv s0, a0
    mv s1, a1
    
    li t0, 0 # t0 = i
    
    print_array_loop:
        bge t0, s0, print_array_loop_end # if i >= n
        
        calculate_ai_address(s1, t0, t1) # t1 = &a[i] = s1 + 4 * t0
       
        lw a0, 0(t1) # a0 = a[i]
        print_int(a0)
        print_sep()
        
        addi t0, t0, 1 # i += 1
        
        j print_array_loop
    print_array_loop_end:

    push(s1)
    push(s0)

    jalr zero, 0(ra)
    
read_array_from_multiple_strings: # void read_array_from_multiple_strings(n, &array)
    push(s0)
    push(s1)

    mv s0, a0
    mv s1, a1

    li t0, 0 # t0 = i
    
    read_array_from_multiple_strings_loop:
        bge t0, s0, read_array_from_multiple_strings_loop_end
        
        calculate_ai_address(s1, t0, t1) # t1 = &a[i] = s1 + 4 * t0
        
        read_int(a0)
        sw a0, 0(t1)   # a[i] = a0 = input
        addi t0, t0, 1 # i += 1
        
        j read_array_from_multiple_strings_loop
    read_array_from_multiple_strings_loop_end:

    pop(s1)
    pop(s0)

    jalr zero, 0(ra)


read_array_from_space_separated_string: # void read_array_from_space_separated_string(n, &array)
    push(ra)
    push(s0)
    push(s1)

    mv s0, a0
    mv s1, a1
    
    print_str("Input space separated array numbers: ")

    # Read string to buffer
    la a0, buffer
    li a1, 100
    li a7, 8
    ecall
    
    mv a0, s0
    mv a1, s1
    la a2, buffer
    jal ra, parse_array_from_string # parse_array_from_string(n, &array, &buffer) -> None
    
    pop(s1)
    pop(s0)
    pop(ra)
    
    jalr zero, 0(ra)
    
parse_array_from_string: # void parse_array_from_string(n, &array, &buffer)
    push(s0)
    push(s1)
    push(s2)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    
    li t0, 0 # t0 = i (counter of readed numbers)
    
    parse_loop:
        beq t0, s0, parse_end  # i == n -> return

        lb t1, 0(s2)           # t1 = symbol
        beqz t1, parse_end     # t1 == "\0" -> return

        li t2, ' '             
        beq t1, t2, skip_space # t1 == ' ' -> skip
        
        li t3, 0               # t3 = current number storage

        li t2, '-' 
        li t4, 1                 # after processing: t3 = t3 * t4
        bne t1, t2, parse_number # if (t1 != '-') than t4 = 1 
        li t4, -1                # else                t4 = -1
        
        addi s2, s2, 1        
        lb t1, 0(s2)             # t1 = next symbol

        parse_number:
            li t2, '0'
            sub t1, t1, t2              # t1 = int(t1)

            li t2, 9
            blt t1, zero, store_number
            bgt t1, t2, store_number    # !(0 <= t1 <= 9) -> store number in array

            li t2, 10
            mul t3, t3, t2       
            add t3, t3, t1         # t3 = 10 * t3 + t1

            addi s2, s2, 1        
            lb t1, 0(s2)           # t1 = next symbol
            j parse_number

        store_number:
            mul t3, t3, t4
            sw t3, 0(s1)           
            addi s1, s1, 4         
            addi t0, t0, 1         
 
        skip_space:
            addi s2, s2, 1
            
        j parse_loop

    parse_end:
        beq t0, s0, parse_array_from_string_return
        print_str("Not enough numbers parsed from string\nExpected:")
        print_int(s0)
        print_str("\nGot:")
        print_int(t0)
        print_str("\n")
    
    parse_array_from_string_return:
        pop(s2)
        pop(s1)
        pop(s0)
        jalr zero, 0(ra)

are_arrays_equal: # void are_arrays_equal(n, &array1, &array2)
    push(s0)
    push(s1)
    push(s2)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    
    li t0, 0 # t0 = i
    
    are_arrays_equal_loop:
        bge t0, s0, print_arrays_equal
        
        calculate_ai_address(s1, t0, t1) # t1 = &a[i] = s1 + 4 * t0
        lw t1, 0(t1)                     # t1 = a[i]
        
        calculate_ai_address(s2, t0, t2) # t2 = &b[i] = s2 + 4 * t0       
        lw t2, 0(t2)                     # t2 = b[i]
        
        bne t1, t2, print_arrays_not_equal
        
        addi t0, t0, 1 # i += 1
        
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