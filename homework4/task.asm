.data
array:      .space 40       
prompt:     .asciz "Введите количество элементов массива (1-10):\n"
input_msg:  .asciz "Введите элемент массива:\n"
sum_msg:    .asciz "\nСумма: "
overflow_msg: .asciz "Произошло переполнение! Последняя корректная сумма: "
count_msg:  .asciz "Количество элементов в корректной сумме: "
even_msg:   .asciz "\nКоличество нечетных элементов: "
odd_msg:    .asciz "\nКоличество четных элементов: "

n: .word 0
odd_counter: .word 0
even_counter: .word 0

.text
.globl main

main:
    li a7, 4                         
    la a0, prompt
    ecall

    li a7, 5                         
    ecall
    
    la a7, n
    sw a0, 0(a7)
    mv t0, a0

    li t1, 1
    blt t0, t1, end                   
    li t1, 10
    bgt t0, t1, end                   

     
    li t2, 0                          
    la t3, array                      

input_loop:
    bge t2, t0, sum_elements          

    li a7, 4                          
    la a0, input_msg
    ecall

    li a7, 5                          
    ecall

    sw a0, 0(t3)                      
    addi t3, t3, 4                    
    addi t2, t2, 1                    
    j input_loop                      

sum_elements:
    li t4, 0                          
    li t5, 0                          
    la t3, array                      

    li t2, 0                          

sum_loop:
    bge t2, t0, display_result        

    lw t1, 0(t3)                      
    add t4, t4, t1                    

     
     
    addi t5, t5, 1                    

     
    andi t6, t1, 2                     
    beq t6, zero, count_even          
    lw t0, odd_counter
    addi t0, t0, 1                    
    la a7, odd_counter
    sw t0, 0(a7)
    j update_pointers

count_even:
    lw t0, even_counter
    addi t0, t0, 1                    
    la a7, even_counter
    sw t0, 0(a7)
    
update_pointers:
    addi t3, t3, 4                    
    addi t2, t2, 1                    
    la a7, n
    lw t0, 0(a7)
    j sum_loop                        

overflow_handling:
     
    li a7, 4
    la a0, overflow_msg
    ecall

     
    li a7, 1
    mv a0, t4
    ecall

     
    li a7, 4
    la a0, count_msg
    ecall

    li a7, 1
    mv a0, t5
    ecall

     
    j display_even_odd

display_result:
     
    li a7, 4
    la a0, sum_msg
    ecall
    
    li a7, 1
    mv a0, t4
    ecall

     
    j display_even_odd

display_even_odd:
     
    li a7, 4
    la a0, even_msg
    ecall

    li a7, 1
    lw a0, even_counter
    ecall

     
    li a7, 4
    la a0, odd_msg
    ecall

    li a7, 1
    lw a0, odd_counter
    ecall

end:
     
    li a7, 10                         
    ecall
