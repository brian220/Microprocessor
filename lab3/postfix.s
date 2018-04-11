.syntax unified
	.cpu cortex-m4
	.thumb

.data

	user_stack:	.zero 128
	expr_result:	.word   0
	prefix_expr:   .asciz    "+ - -100 + 10 20 10"

.text

    .global main
    .equ RCC_AHB2ENR,   0x4002104C
	.equ GPIOA_MODER,   0x48000000
	.equ GPIOA_OTYPER,  0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR,   0x4800000C
	.equ GPIOA_ODR,     0x48000014
	.equ GPIOA_BSRR,	0x48000018 //set
	.equ GPIOA_BRR,		0x48000028 //clear

	.equ din,            0b100000   //pa5
	.equ cs,             0b1000000  //pa6
	.equ clk,            0b10000000 //pa7

	.equ	decode,			0x19
	.equ	intensity,		0x1A
	.equ	scan_limit,		0x1B
	.equ	shutdown,		0x1C
	.equ	display_test,	0x1F

main:
    ldr r0, =prefix_expr
//TODO: Setup stack pointer to end of user_stack and calculate the expression using PUSH, POP operators, and store the result into expr_result
    mov r3, #0
count_length:
    ldrb r1, [r0]
	push {r1}
	add r0, r0, #1
	add r3, r3, #1
	cmp r1, #0
	bne count_length

	ldr r0, =prefix_expr

	pop {r1}
	mov r2, #0
	strb r2, [r0,r3]
	sub r3, r3, #1

reverse_string:
    pop {r1}
    strb r1, [r0]
    add r0, r0, #1
    sub r3, r3, #1
    cmp r3, #0
    bne reverse_string

	ldr r0, =prefix_expr
	mov r2, #0
	mov r3, #0
	mov r4, #0
	mov r7, #0
	mov r8, #1
	mov r10, #0
	mov r11, #10
    mov r12, #0

	bl atoi
	ldr r0, =expr_result
	ldr r2, [sp]
	str r2, [r0]

    BL   GPIO_init
    BL   max7219_init
    mov r3, r2
    cmp r2, #0
    mov r9, #-1
    IT lt
    mullt r2, r2, r9
    mov r4, #1
    mov r10, #10
    mov r7, #0
count_num:
    add r7, r7, #1
    sdiv r3, r2, r10
    mul  r5, r3, r10
    sub  r6, r2, r5
    push {r6}
    mov  r2, r3
    cmp  r3, #0
    bne count_num
    mov r8, #8

show_num:
   sub r8, r8, #1
   mov r0, r8
   cmp r8, r7
   ITT eq
   ldreq r1, =0x00
   cmpeq r4, #1
   IT eq
   ldreq r1, =0x0a

   cmp r8, r7
   IT gt
   ldrgt r1, =0x00

   cmp r8, r7
   IT lt
   poplt {r1}
   BL MAX7219Send
   cmp r8, #0
   bgt show_num

program_end:
	B		program_end

atoi:
    //TODO: implement a ¡§convert string to integer¡¨ function
    ldrb r1, [r0]
	add r0, r0, #1

	cmp r1, #0x2d //-
	ITT eq
	moveq r3, #2
	cmpeq r12, #1
	IT eq
	moveq r3, #1

    cmp r1, #0x2d
    beq atoi

	cmp r1, #0x2b //+
	IT eq
	moveq r3, #3
	beq atoi

	cmp r1, #0x2f //0-9
	bgt num
	mov r12, #0   //space
	b endtok
num:
	mov r12, #1
	sub r1, r1, #0x30
	mul r4, r1, r8
	mul r8, r8, r11
	add r2, r4, r10
	mov r10, r2
	b atoi
endtok:
    mov r8, #1
    mov r10, #0
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
	subeq r2, r6, r5
	addne r2, r6, r5
	push {r2}
	mov r2, #0
	mov r3, #0
	cmp r1, #0x00
	bne atoi
	bx lr

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	//enable ahb2 clock
    movs r0, #0x7
    ldr  r1, =RCC_AHB2ENR
    str  r0, [r1]

    //set pa5,pa6,pa7,pa8 as output mode
    movs r0, #0x00015400
    ldr  r1, =GPIOA_MODER
    ldr  r2, [r1]
    and  r2, #0xFFFC03FF
    orrs r2, r2, r0
    str  r2, [r1]

	movs r0, #0x0002A800
    ldr  r1, =GPIOA_OSPEEDR
    strh r0, [r1]
    bx lr

MAX7219Send:
//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, lr}
	lsl r0, r0, #8
    add r0, r0, r1
	ldr r1, =clk
	ldr r2, =din
	ldr r3, =cs
	ldr r4, =GPIOA_BSRR //set
	ldr r5, =GPIOA_BRR  //clear
	mov r6, #16
max7219send_loop:
    mov r8, #1
    sub r9, r6, #1
    lsl r8, r8, r9
    str r1, [r5]  //clk = 0
    tst r0, r8
    beq bit_not_set
    str r2, [r4]
    b if_done

bit_not_set:
    str r2, [r5]
if_done:
    str r1, [r4]
    subs r6, r6 ,#1
    bgt max7219send_loop
    str r3, [r5]
    str r3, [r4]
    pop {r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, pc}
    bx lr

max7219_init:
	//TODO: Initial max7219 registers.
	push {r0, r1, lr}
	ldr r0,  =decode
	ldr r1,  =0xFF
	bl MAX7219Send

	ldr r0,  =display_test
	ldr r1,  =0x0
	bl MAX7219Send

	ldr r0,  =scan_limit
	ldr r1,  =0x6
	bl MAX7219Send

	ldr r0,  =intensity
	ldr r1,  =0xA
	bl MAX7219Send

	ldr r0,  =shutdown
	ldr r1,  =0x1
	bl MAX7219Send
	pop {r0, r1, pc}
	BX LR
