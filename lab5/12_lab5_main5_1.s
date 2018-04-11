.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr: .byte 0x7e, 0x30, 0x6d, 0x79, 0x33, 0x5b, 0x5f, 0x70, 0x7f, 0x7b, 0x77, 0x1f, 0x4e, 0x3d, 0x4f, 0x47 //TODO: put 0 to F 7-Seg LED pattern here

.text
	.global main
	.equ X, 1000
	.equ Y, 1000
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OSPEEDER, 0x48000008
	.equ GPIOA_PUPDR,0x4800000C
	.equ GPIOA_IDR, 0x48000010
	.equ GPIOA_ODR, 0x48000014
	.equ GPIOA_BSRR, 0x48000018
	.equ GPIOA_BRR, 0x48000028
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_IDR, 0x48000810
	.equ DIN, 0b100000
	.equ CS, 0b1000000
	.equ CLK, 0b10000000
main:
    BL   GPIO_init
    BL   max7219_init
loop:
    ldr r9, =arr
    ldr r8, =0xF
    b  Display0toF
GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	movs r0, #0x7
    ldr  r1, =RCC_AHB2ENR
    str  r0, [r1]

	ldr  r1, =GPIOA_MODER
    ldr  r0, [r1]
    ldr  r2, =#0xFFFF57FF
	and  r0,r2
    str  r0, [r1]

    ldr r1,	=GPIOC_MODER
 	ldr r0,	[r1]
	ldr r2,	=#0xF3FFFFFF
	and r0,	r2
	str r0,	[r1]

    ldr  r1, =GPIOA_OSPEEDER
    ldr  r0, [r1]
    ldr  r2, =#0xFFFF57FF
	and  r0, r2
    str  r0, [r1]
	BX LR

Display0toF:
	//TODO: Display 0 to F at first digit on 7-SEG LED. Display one per second.
	ldr r0, =0x01
	ldr r1, =0x00
	ldrb r1, [r9]
	BL MAX7219Send
	bl Delay
	add r9, r9, #1
	subs r8, r8, #1
	bge Display0toF
	b loop

MAX7219Send:
   //input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {LR}
	lsl	r0, 8
	add r0, r1
	ldr r1, =DIN
	ldr r2, =CS
	ldr r3, =CLK
	ldr r4, =GPIOA_BSRR
	ldr r5, =GPIOA_BRR
	ldr r6, =0xF
send_loop:
	mov r7, 1
	lsl r7, r6
	str r3, [r5]
	tst r0, r7
	beq bit_not_set
	str r1, [r4]
	b if_done
bit_not_set:
	str r1, [r5]
if_done:
	str r3, [r4]
	subs r6, 0x1
	bge send_loop
	str r2, [r5]
	str r2, [r4]
	pop {PC}
max7219_init:
	//TODO: Initialize max7219 registers
	push {lr}
	ldr r0, =0x0c
	ldr r1, =0x01
	BL MAX7219Send
	ldr r0, =0x09
	ldr r1, =0x00
	BL MAX7219Send
	ldr r0, =0x0a
	ldr r1, =0x0a
	BL MAX7219Send
	ldr r0, =0x0b
	ldr r1, =0x00
	BL MAX7219Send
	ldr r0, =0x0f
	ldr r1, =0x00
	BL MAX7219Send
	pop {pc}
Delay:
	push {lr}
	LDR R3, =X
	L1: LDR R4,	=Y
	L2: SUBS R4, #1
	BNE L2
	SUBS R3, #1
	BNE L1
	pop {pc}


