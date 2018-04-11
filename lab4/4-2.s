.syntax unified
.cpu cortex-m4
.thumb

.data

.text

.global main
	.equ X, 1000
	.equ Y, 300
	.equ PASS, 0x3
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014
	.equ GPIOA_IDR, 0x48000010
    .equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_IDR, 0x48000410


	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_IDR, 0x48000810
main:
    bl GPIO_INIT
    mov r10, #0
loop:

	ldr r5,	=GPIOC_IDR
    ldr r6,	[r5]
    movs r7, #1
    lsl r7,	#13
    ands r6, r7
	beq comp
	bne loop
comp:
   ldr r2, =PASS
   ldr r0, =GPIOB_IDR
   ldr r1, [r0]
   lsl r1, #24
   lsr r1, #28
   eor r1, #0xf
   cmp r1, r2
   ite eq
   moveq r10, #3
   movne r10, #1

displayled:
   ldr r1,	=GPIOA_ODR
blink:
   //Set	PA5	as	low	then	delay
   movs r0,	#0
   strh r0,	[r1]
   bl Delay
   //Set	PA5	as	high	then	delay
   movs r0,	#0b111100000
   strh r0,	[r1]
   bl Delay
   sub r10, r10, #1
   cmp r10, #0
   bne blink
   b loop

GPIO_INIT:
    //enable ahb2 clock
    movs r0, #0x7
    ldr  r1, =RCC_AHB2ENR
    str  r0, [r1]

    //set pa5,pa6,pa7,pa8 as output mode
    ldr  r1, =GPIOA_MODER
    ldr  r0, [r1]
    ldr  r2, =#0xFFF157FF
	and  r0,r2
    str  r0, [r1]
	ldr  r1, =GPIOA_ODR
	mov  r0, #0b111100000
	strh  r0, [r1]
    //set pb5,pb6,pb7,pb8 as input mode

    ldr  r1, =GPIOB_MODER
    ldr  r0, [r1]
    ldr  r2, =#0xffff00ff
    and  r0, r2
    str  r0, [r1]
    ldr  r1, =GPIOB_PUPDR
    ldr  r0, [r1]
    ldr  r2, =#0xffff55ff
    and  r0, r2
    str  r0, [r1]
	//set user button
	ldr r1,	=GPIOC_MODER
 	ldr r0,	[r1]
	ldr r2,	=#0xF3FFFFFF
	and r0,	r2
	str r0,	[r1]
    //high speed mode
    movs r0, #0x0002A800
    ldr  r1, =GPIOA_OSPEEDR
    strh r0, [r1]
    bx lr
Delay:
LDR R3, =X
L1: LDR R4,	=Y
L2: SUBS R4,	#1
BNE L2
SUBS R3,	#1
BNE L1
BX LR
