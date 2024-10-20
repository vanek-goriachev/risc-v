.include "macros.asm"

.data

.align 2
source_array: .space 64
processed_array: .space 64
expected_array: .space 64
buffer: .space 1024

.global run_tests

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
run_tests:
    push(ra)
    
    test(4, "1 2 3 4", "2 1 4 3")
    test(6, "12 54 74 11 25 16", "54 12 11 74 16 25")
    test(4, "-1 2 -3 4", "2 -1 4 -3")
    
    pop(ra)
    ret
