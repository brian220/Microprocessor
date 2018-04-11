.syntax unified
.cpu cortex-m4
.thumb

.data
	student_id1: .byte 0, 4, 1, 6, 0, 9, 4 //TODO: put your student id here
    student_id2: .byte 0, 4, 1, 6, 0, 3, 3

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
    BL   GPIO_init
    BL   max7219_init
    //TODO: display your student id on 7-Seg LED
    ldr r9, =student_id2
    mov r0, #8

for_loop:
    sub  r0, r0, #1
    ldrb r1, [r9]
    add  r9, r9, #1
    bl MAX7219Send
    cmp r0, #0
    bgt for_loop
Program_end:
	B Program_end

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
