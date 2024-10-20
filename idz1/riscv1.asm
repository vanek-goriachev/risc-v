.include "macros.asm"
.data
.align 2
buffer: .space 100      # Буфер для ввода строки
.align 2
array:  .space 400      # Пространство для массива (100 целых чисел)

.text
.global main

main:
    push(s0)
    
    print_str("Enter elements amount: ")
    read_int(s0) # s0 = N
    
    # Запрос на ввод
    print_str("Enter numbers separated by spaces: ")

    # Чтение строки
    la a0, buffer
    li a1, 100
    li a7, 8
    ecall
    
    # call func
    mv a0, s0
    la a1, array
    la a2, buffer
    jal ra, parse_array_from_string
    
    mv a0, s0
    la a1, array
    jal ra, print_array
    
    pop(s0)
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
    ret
    
parse_array_from_string:
    push(s0)
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
        pop(s0)
        ret