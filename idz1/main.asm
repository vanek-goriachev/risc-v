.include "macros.asm"
.data

.align 2
source_array: .space 64
processed_array: .space 64
expected_array: .space 64
buffer: .space 1024

# Данный макрос не вынесен в библиотеку поскольку не является чем то достаточно универсальным
# Просто обертка для написания тестов на очень специфическую задачу ;)
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
        jal ra, process_array           # process_array(n, &source_array, &processed_array) -> None
        
        li a0, %n
        la a1, processed_array
        la a2, expected_array
        jal ra, are_arrays_equal        # are_arrays_equal(n, &processed_array, &expected_array) -> None
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
    
.include "array_functions.asm"
