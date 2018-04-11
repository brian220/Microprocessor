.syntax unified
.cpu cortex-m4
.thumb

.data
    result: .byte 0
.text
    .global main
    .equ X, 0x1234 //0101010110101010
    .equ Y, 0x4567 //1010101001010101

count_1:
    lsrs R3, #1
    adcs R4, R4, #0
    cmp R3, #0
    bne count_1
    bx LR
hamm:
    //TODO
    eor R3, R0, R1
    movs R4, #0

    movs R5, LR

    bl count_1

    str R4, [R2]
    bx R5
   /****/
main:

    ldr R0, =X   //This code will cause assemble error. Why? And how to fix.
    ldr R1, =Y

    ldr R2, =result
    bl hamm
L: b L
