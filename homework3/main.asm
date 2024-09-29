.data
prompt1: .ascii "Enter dividend: \0"
prompt2: .ascii "Enter divisor: \0"
result1: .ascii "Quotient: \0"
result2: .ascii "Remainder: \0"
error_div0: .ascii "Error: Division by zero\n\0"
newline: .ascii "\n\0"

.text
main:
    # Read dividend
    la a0, prompt1
    li a7, 4
    ecall
    li a7, 5
    ecall
    mv t0, a0

    # Read divisor
    la a0, prompt2
    li a7, 4
    ecall
    li a7, 5
    ecall
    mv t1, a0

    # Check for division by zero
    bnez t1, proceed
    la a0, error_div0
    li a7, 4
    ecall
    j end_program

proceed:
    # Initialize quotient and remainder
    li t2, 0
    mv t3, t0

    # Determine the sign of the quotient and remainder
    li t4, 1
    bgez t0, dividend_positive
    neg t0, t0
    neg t4, t4

dividend_positive:
    bgez t1, divisor_positive
    neg t1, t1
    neg t4, t4

divisor_positive:
    # Division loop
div_loop:
    blt t0, t1, calculation_done
    sub t0, t0, t1
    addi t2, t2, 1
    j div_loop

calculation_done:
    # Adjust signs of quotient and remainder
    bgtz t4, positive_quotient
    neg t2, t2

positive_quotient:
    mv t3, t0

    # Restore the sign of the original dividend to the remainder
    bgez t3, positive_rem
    neg t3, t3

positive_rem:
    mv a1, t3

    # Print Results
    la a0, result1
    li a7, 4
    ecall
    mv a0, t2
    li a7, 1
    ecall
    la a0, newline
    li a7, 4
    ecall

    la a0, result2
    li a7, 4
    ecall
    mv a0, a1
    li a7, 1
    ecall
    la a0, newline
    li a7, 4
    ecall

end_program:
    li a7, 10
    ecall
