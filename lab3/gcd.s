.syntax unified
.cpu cortex-m4

.data
  result: .word  0
  max_size:  .word  0
.text
  m: .word  0x5E
  n: .word  0x60
  .global main

main:
   ldr r0, m
   ldr r1, n
   push {r0, r1}
   movs r3, #0
   bl GCD
   lsl r6, r3
   ldr r1, =max_size
   str r0, [r1]
   ldr r1, =result
   str r6, [r1]
L : B L
GCD:
    //TODO: Implement your GCD function

	ldr r4, [sp]
	ldr r5, [sp, #4]
	pop {r0, r1}
	push {lr}

    movs r9, #0
    movs r11, #0

	cmp r4, #0
	beq set_a

	cmp r5, #0
	beq set_b

	movs r7, r4
	movs r8, r5

	lsrs r7, #1
	adcs r9, r9, #0
	lsrs r8, #1
    adcs r11, r11, #0

    orr  r7, r9, r11
    and r8, r9, r11

    cmp r7, #0
    beq two_even

    cmp r9, #0
    beq a_even

    cmp r11, #0
    beq b_even

    cmp r8, #1
    beq two_odd
recursive_jump:
    movs r0, r4
    movs r1, r5
    push {r0, r1}
    bl GCD
    add r0, r0, #1
    pop {lr}
    bx lr
set_a:
    movs r6, r5
    movs r0, #0
    bx lr
set_b:
    movs r6, r4
    movs r0, #0
    bx lr
two_even:
    lsr r4, #1
    lsr r5, #1
    add r3, r3, #1
    b recursive_jump
a_even:
    lsr r4, #1
    b recursive_jump
b_even:
    lsr r5, #1
    b recursive_jump
two_odd:
    movs r7, r5
    cmp r4, r5
    blt save_r4
    sub r4, r4, r5
    cmp r4, #0
    blt r4_change
    movs r5, r7
    b recursive_jump
save_r4:
    movs r7, r4
	sub r4, r4, r5
    cmp r4, #0
    blt r4_change
    movs r5, r7
    b recursive_jump
r4_change:
    movs r8, #0
    sub r4, r8, r4
    movs r5, r7
    b recursive_jump
