.syntax unified
	.cpu cortex-m4
	.thumb
.data
.text
	.global main
	.equ X, 1000000
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
from_zero:
	ldr r8, =0
	ldr r9, =1
	bl print
loop:
	ldr r5,	=GPIOC_IDR
    ldr r6,	[r5]
    movs r7, #1
    lsl r7,	#13
    ands r6, r7
    it eq
    bleq pressed
    ldr r10, =0x3ffff
    cmp r3, r10
    ldr r3, =0
    bgt from_zero
	b loop
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
MAX7219Send:
   //input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r0,r1,r2,r3,r4,r5,r6,r7,LR}
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
	pop {r0,r1,r2,r3,r4,r5,r6,r7,PC}
max7219_init:
	//TODO: Initialize max7219 registers
	push {lr}
	ldr r0, =0x0c
	ldr r1, =0x01
	BL MAX7219Send
	ldr r0, =0x09
	ldr r1, =0xff
	BL MAX7219Send
	ldr r0, =0x0a
	ldr r1, =0x0a
	BL MAX7219Send
	ldr r0, =0x0b
	ldr r1, =0x07
	BL MAX7219Send
	ldr r0, =0x0f
	ldr r1, =0x00
	BL MAX7219Send
	pop {pc}
pressed:
	push {lr}
	add r10, r8, r9
	mov r8, r9
	mov r9, r10
	lsr r10, r8, #26
	cmp r10, #0
	bgt overflow
	bl print
L1:	ldr r4,	=Y
	add r3, r3, #1
L2: ldr r5,	=GPIOC_IDR
    ldr r6,	[r5]
    movs r7, #1
    lsl r7,	#13
    ands r6, r7
    beq L1
	subs R4, #1
	bne L2
	pop {pc}
print:
	push {r2,r3,r4,lr}
	ldr r0, =0x01
	ldr r10, =10
	mov r2, r8
bcdloop:
	cmp r10, #1
	it eq
	ldreq r1, =0x0f
	beq L3
	sdiv r3, r2, r10
	mul r4, r3, r10
	sub r1, r2, r4
	mov r2, r3
	cmp r3, #0
	it eq
	moveq r10, #1
L3:	BL MAX7219Send
	add r0, r0, #1
	cmp r0, #9
	blt bcdloop
	pop {r2,r3,r4,pc}
overflow:
	push {r2,r3,r4,lr}
	ldr r0, =0x01
L4:	cmp r0, #2
	it lt
	ldrlt r1, =0x01
	it eq
	ldreq r1, =0x0a
	it gt
	ldrgt r1, =0x0f
	BL MAX7219Send
	add r0, r0, #1
	cmp r0, #9
	blt L4
	pop {r2,r3,r4,lr}
	b L1
