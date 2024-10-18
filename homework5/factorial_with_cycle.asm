.text

main:
    li a1, 0 # a1 = n

n_loop:
    addi a1, a1, 1 # n += 1
    mv a0, a1  # a0 = n
    
    jal ra, fact # a0 = fact(a0) = fact(n) 
    
    rem a0, a0, a1 # a0 = fact(n) % n
    bnez a0, overflow_detected # if (fact(n) % n != 0) -> overflow_detected
    
    j n_loop
    
overflow_detected:
    mv a0, a1  # a0 = n
    addi a0, a0, -1 # a0 = a0 - 1
    
    li a7, 1
    ecall
    
exit:
    li a7, 10
    ecall

fact:
    li t0, 1                 # t0 = 1 = fact
    li t1, 1                 # t1 = 1 = i

fact_loop:
    bgt t1, a0, fact_done    # if (i == n) break
    mul t0, t0, t1           # fact *= i
    addi t1, t1, 1           # i += 1
    j fact_loop             

fact_done:
    mv a0, t0               
    ret
