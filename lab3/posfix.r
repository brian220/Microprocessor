.syntax unified
	.cpu cortex-m4
	.thumb

.data
	user_stack:	.zero 128
	expr_result:	.word   0

.text
	.global main
	postfix_expr:   .asciz    "-100 10 20 + - 10 +"

main:
	LDR	R0, =postfix_expr
//TODO: Setup stack pointer to end of user_stack and calculate the expression using PUSH, POP operators, and store the result into expr_result
	mov r2, #0
	mov r3, #0
	mov r7, #0
	mov r8, #10
	bl atoi
	ldr r0, =expr_result
	ldr r2, [sp]
	str r2, [r0]
program_end:
	B		program_end

atoi:
    //TODO: implement a ��convert string to integer�� function
	ldrb r1, [r0]
	add r0, r0, #1
	cmp r1, #0x2d //-
	IT eq
	moveq r3, #2
	beq atoi
	cmp r1, #0x2b //+
	IT eq
	moveq r3, #3
	beq atoi
	cmp r1, #0x2f //0-9
	bgt num
	b endtok
num:
	cmp r3, #2
	IT eq
	moveq r3, #1
	mul r4, r2, r8
	sub r1, r1, #0x30
	add r2, r4, r1
	b atoi
endtok:
	cmp r3, #2
	blt push
	b pop
push:
	cmp r3, #1
	IT eq
	subeq r2, r7, r2
	push {r2}
	mov r2, #0
	mov r3, #0
	cmp r1, #0x00
	bne atoi
	bx lr
pop:
	pop {r6}
	pop {r5}
	cmp r3, #2
	ITE eq
	subeq r2, r5, r6
	addne r2, r5, r6
	push {r2}
	mov r2, #0
	mov r3, #0
	cmp r1, #0x00
	bne atoi
	bx lr
