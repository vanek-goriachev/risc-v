.include "macros.asm"
.data

.align 2
source_array: .space 64
processed_array: .space 64
expected_array: .space 64
buffer: .space 1024


.macro test(%n, %source, %expected)
    .data 
        source_buffer: .asciz %source
        expected_buffer: .asciz %expected
    .text
        li a0, %n
        la a1, source_array
        la a2, source_buffer
        jal ra, parse_array_from_string # parse_array_from_string(n, &source_array, &source_buffer) -> None
        
        li a0, %n
        la a1, expected_array
        la a2, expected_buffer
        jal ra, parse_array_from_string # parse_array_from_string(n, &expected_array, &expected_buffer) -> None
        
        li a0, %n
        la a1, source_array
        la a2, processed_array
        jal ra, process_array # process_array(n, &source_array, &processed_array) -> None
        
        li a0, %n
        la a1, processed_array
        la a2, expected_array
        jal ra, are_arrays_equal # are_arrays_equal(n, &processed_array, &expected_array) -> None
.end_macro

.text
main: # void main()
    push(s0)

    print_str("Input N - array length. N must be even. Input 0 to run tests:\n")

    read_int(s0) # s0 = n
    
    mv a0, s0
    beqz a0, tests_run    # if n == 0 -> tests
                       
    li t0, 2
    rem t0, a0, t0
    beqz t0, manual_run   # if n % 2 == 0 -> manual run             

    j n_must_be_even      # else -> error
                          # because my idz variant is 24
                          # If n is odd the task is... 
                          # Undefined i think))

    tests_run:
        test(4, "1 2 3 4", "2 1 4 3")
        test(6, "12 54 74 11 25 16", "54 12 11 74 16 25")
        test(4, "-1 2 -3 4", "2 -1 4 -3")
        test(4, "-1 2 -3 4", "2 -1 4 -4")
        j main_end
        
    manual_run:
        mv a0, s0
        la a1, source_array 

        # Эта строчка используется для чтения массива как "1 2 3 4"
        jal ra, read_array_from_space_separated_string  # read_array_from_space_separated_string(n, &source_array) -> None

        # Эта строчка используется для чтения массива как "1\n2\n3\n4\n"
        # jal ra, read_array_from_multiple_strings # read_array_from_multiple_strings(n, &source_array) -> None

        mv a0, s0
        la a1, source_array
        la a2, processed_array
        jal ra, process_array # process_array(n, &source_array, &processed_array) -> None
        
        mv a0, s0
        la a1, processed_array 
        jal ra, print_array # print_array(n, &processed_array) -> None
        j main_end
        
    n_must_be_even:
        print_str("N must be a even number")
        j main_end
        
    main_end:
        pop(s0)
        exit()
    

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
    

process_array: # void process_array(n, &source_array, &target_array)
    push(s0)
    push(s1)
    push(s2)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    
    li t0, 0 # t0 = i
    
    process_array_loop:
        bge t0, s0, process_array_loop_end
        
        calculate_ai_address(s1, t0, t1) # t1 = &a[i] = s1 + 4 * t0
        lw t1, 0(t1)                     # t1 = a[i]

        calculate_ai_address(s2, t0, t2) # t2 = &b[i] = s2 + 4 * t0
        
        li t3, 2
        rem t3, t0, t3 # t3 = i % 2
        bnez t3, move_item_bacward
        
        move_item_forward:
            # calculate b[i+1] address
            sw t1, 4(t2)
            j end_forward_or_backward_branch
        move_item_bacward:
            # calculate b[i-1] address
            sw t1, -4(t2)
        end_forward_or_backward_branch:
        
        addi t0, t0, 1 # i += 1
        
        j process_array_loop
    process_array_loop_end:
    
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
