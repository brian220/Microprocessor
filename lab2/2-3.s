.syntax unified
.cpu cortex-m4
.thumb
.data
arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC
.text
    .global main
do_sort:
    //TODO
	mov r3, #7
	mov r4, r0
loops:
	ldrb r1, [r4]
	add r4, r4, #1
	ldrb r2, [r4]
	cmp r1, r2
	bgt loop_back
	sub r4, r4, #1
	strb r2, [r4]
	add r4, r4, #1
	strb r1, [r4]
loop_back:
	sub r5, r4, r0
	cmp r3, r5
	bgt loops
	sub r3, r3, #1
	cmp r3, #0
	mov r4, r0
	bne loops
    bx lr
main:
    ldr r0, =arr1
    bl do_sort
    ldr r0, =arr2
    bl do_sort
L: b L
