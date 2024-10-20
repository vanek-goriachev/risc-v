.include "macros.asm"

.data

.align 2
source_array: .space 64
processed_array: .space 64
expected_array: .space 64
buffer: .space 1024

.global process_array

.text
main: # void main()
    push(s0)

    print_str("Input N - array length. N must be even. Input 0 to run tests:\n")

    read_int(s0) # s0 = n
    
    mv a0, s0
    beqz a0, call_run_tests    # if n == 0 -> tests
                       
    li t0, 2
    rem t0, a0, t0
    beqz t0, manual_run   # if n % 2 == 0 -> manual run             

    j n_must_be_even      # else -> error
                          # because my idz variant is 24
                          # If n is odd the task is... 
                          # Undefined i think))
    
    call_run_tests:
        jal ra, run_tests
        j main_end
    
    manual_run:
        mv a0, s0
        la a1, source_array 

        # Эти две строчки используются для чтения массива как "1 2 3 4"
        la a2, buffer
        jal ra, read_array_from_space_separated_string  # read_array_from_space_separated_string(n, &source_array) -> None

        # Эта строчка используется для чтения массива как "1\n2\n3\n4\n"
        # jal ra, read_array_from_multiple_strings # read_array_from_multiple_strings(n, &source_array) -> None

        mv a0, s0
        la a1, source_array
        la a2, processed_array
        jal ra, process_array                          # process_array(n, &source_array, &processed_array) -> None
        
        mv a0, s0
        la a1, processed_array 
        jal ra, print_array                            # print_array(n, &processed_array) -> None
        j main_end
        
    n_must_be_even:
        print_str("N must be a even number")
        j main_end
        
    main_end:
        pop(s0)
        exit()
    

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
    
