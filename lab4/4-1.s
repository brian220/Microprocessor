.syntax unified
.cpu cortex-m4
.thumb

.data
leds: .byte 0

.text
	.global main
	.equ X, 1000
	.equ Y, 400
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014
	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_IDR, 0x48000810
main:
    BL      GPIO_init
	MOVS	R1, #1
	mov		r9, #0
	LDR	    R0, =leds
	STRB	R1, [R0]
    MOVS    R2, #0
Loop:
	//TODO: Write the display pattern into leds variable
    CMP     r2, #0
    IT      EQ
    MOVEQ   r0, #1

    CMP     r2, #1
    IT      EQ
    MOVEQ   r0, #3

    CMP     r2, #2
    IT      EQ
    MOVEQ   r0, #6

    CMP     r2, #3
    IT      EQ
    MOVEQ   r0, #12

    CMP     r2, #4
    IT      EQ
    MOVEQ   r0, #8

    CMP     r2, #5
    IT      EQ
    MOVEQ   r0, #12

    CMP     r2, #6
    IT      EQ
    MOVEQ   r0, #6

    CMP     r2, #7
    ITT     EQ
    MOVEQ   r0, #3
    MOVEQ   r2, #-1
    cmp r9, #0
    IT eq
	BLeq	DisplayLED
    BL      Delay
	B		Loop

GPIO_init:

  //TODO: Initial LED GPIO pins as output
  //Enable AHB2 clock
  MOVS r0, #0x5
  LDR  r1, =RCC_AHB2ENR
  STR  r0, [r1]

  //set pa5,pa6,p a7, pa8 as output mode
  MOVS r0, #0x00015400
  LDR  r1, =GPIOA_MODER
  LDR  r2, [r1]
  AND  r2, #0xFFFC03FF
  ORRS r2, r2, r0
  STR  r2, [r1]
  //user button
  ldr r1,	=GPIOC_MODER
  ldr r0,	[r1]
  ldr r2,	=#0xF3FFFFFF
  and r0,	r2
  str r0,	[r1]
  //high speed mode
  MOVS r0, #0x0002A800
  LDR  r1, =GPIOA_OSPEEDR
  STRH r0, [r1]

  BX LR

DisplayLED:

	LSL  r0, #5
	MOVS r3, #0xFFFFFFFF
    LDR  r1, =GPIOA_ODR
    EOR  r0, r0, r3
    STRH r0, [r1]
    ADD  r2, r2, #1
	BX   LR

Delay:
   //TODO: Write a delay 1sec function
   LDR   r3, =X
L1:LDR   r4, =Y
L2:	ldr r5,	=GPIOC_IDR
    ldr r6,	[r5]
    movs r7, #1
    lsl r7,	#13
    ands r6, r7
    beq do_pushed
	SUBS  r4, #1
    BNE   L2
    eor r9, r9, r8
    mov r8, #0
    SUBS  r3, #1
    BNE   L1
BX LR
do_pushed:
	mov r8, #1
	ldr r4, =Y
	b L2

