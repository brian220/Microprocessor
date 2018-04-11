#include<stdio.h>
#include<stdlib.h>
#include"stm32l476xx.h"
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
int TIME_SEC = 1207;
int display(int data, int num_digs)
{
	int i =0;
	int digit;
	if(data>99999999)
		return -1;
	for(i=1;i<=num_digs;i++)
	{
		digit = data%10;
		data/=10;
		if(digit == 0 && data == 0 && i>3)
			digit = 15;
		if(i == 3)
			digit |= 0x80;
		max7219_send(i, digit);
	}
	return 0;
}
void TIMER_init()
{
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;//4,000,000Hz
	TIM2->PSC = (uint32_t)39999;
	TIM2->ARR = (uint32_t)TIME_SEC;
	TIM2->EGR = TIM_EGR_UG;
}
int main()
{
	GPIO_init();
	max7219_init();
	TIMER_init();
	display(0,8);
	TIM2->CR1 |= TIM_CR1_CEN;
	TIM2->SR &= ~(TIM_SR_UIF);
	while(1)
	{
		int time = TIM2->CNT;
		display(time,8);
		if(time == TIME_SEC)
		{
			TIM2->CR1 &= ~(TIM_CR1_CEN);
			return 0;
		}

	}
}
