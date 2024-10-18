.text

main:
    li a1, 0 # a1 = n

n_loop:
    addi a1, a1, 1 # n += 1
    mv a0, a1  # a0 = n
    
    jal ra, fact # a0 = fact(a0) = fact(n)
    
    rem a0, a0, a1
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
    # if a0 (n) < 1
    addi t0, a0, -1
    bge  t0, zero, fact_else
    # return 1
    li   a0, 1
    jalr zero, 0(ra)

    # else
fact_else:
    # save old a0 and ra to stack
    addi sp, sp, -8
    sw   ra,  4(sp)
    sw   a0,  0(sp)

    addi a0, a0, -1
    jal  ra, fact
    mv   t1, a0

    # restore old a0 and ra from stack
    lw   a0, 0(sp)
    lw   ra, 4(sp)
    addi sp, sp, 8

    # return a0 * fact(a0 - 1)
    mul  a0, a0, t1
    jalr zero, 0(ra)


