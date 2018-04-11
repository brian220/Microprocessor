#include<stdio.h>
#include<stdlib.h>
#include"stm32l476xx.h"
//input pin = pa7
int mode;
unsigned int state[4] = {3, 6, 12, 9};


void GPIO_init()
{
	RCC->AHB2ENR = RCC->AHB2ENR|0x7;
	GPIOC->MODER &= 0xffffff00;//pa0123 = output;
	GPIOC->MODER |= 0x00000055;
	GPIOC->PUPDR &= 0xffffff00;
	GPIOC->OSPEEDR &= 0xffffff00;
	GPIOC->OSPEEDR |= 0x00000055;
	GPIOC->ODR &= 0b0000;
	GPIOA->MODER &= 0xffff3fff;
	GPIOA->PUPDR &= 0xffff3fff;
	GPIOA->PUPDR &= 0x00004000;
	GPIOB->MODER   &= 0b11111111110000000000000000111111;
	GPIOB->MODER   |= 0b00000000000101010101010101000000;
	GPIOB->PUPDR   &= 0b11111111110000000000000000111111;
	GPIOB->PUPDR   |= 0b00000000000101010101010101000000;
	GPIOB->OSPEEDR &= 0b11111111110000000000000000111111;
	GPIOB->OSPEEDR |= 0b00000000000101010101010101000000;
	GPIOB->ODR &= 0;
}
void SystemClock_Config(void)
{
	RCC->APB2ENR |= 1;
	SysTick->LOAD  = 8000; //1000hz
	SysTick->VAL   = 0; //Load the SysTick Counter Value
	SysTick->CTRL  = SysTick_CTRL_CLKSOURCE_Msk | SysTick_CTRL_TICKINT_Msk | SysTick_CTRL_ENABLE_Msk;

	RCC->CR |= RCC_CR_HSION;// turn on HSI16 oscillator
	while((RCC->CR & RCC_CR_HSIRDY) == 0);//check HSI16 ready
	RCC->CFGR |= 9<<4;//SYSCLK divide by 4. SYSCLK = 16MHz/4 = 4Mhz
	if((RCC->CR & RCC_CR_HSIRDY) == 0)
		return;
}

void SysTick_Handler(void) {
	static int l =0;
	static int r =0;
	switch(mode)
	{
	case 0:
		return;
	case 1:
		l = (l+3)%4;
		r = (r+3)%4;
		GPIOB->ODR = state[l]<<3;
		GPIOB->ODR |= state[r]<<7;
		return;
	case 2:
		l = (l+1)%4;
		r = (r+1)%4;
		GPIOB->ODR = state[l]<<3;
		GPIOB->ODR |= state[r]<<7;
		return;
	case 3:
		l = (l+3)%4;
		r = (r+1)%4;
		GPIOB->ODR = state[l]<<3;
		GPIOB->ODR |= state[r]<<7;
		return;
	case 4:
		l = (l+1)%4;
		r = (r+3)%4;
		GPIOB->ODR = state[l]<<3;
		GPIOB->ODR |= state[r]<<7;
		return;
	default:
		return;
	}
}
void IR_receive()
{
	int count =0;
	int code=0;
	//delay_us(2500);
	while((GPIOA->IDR & 0x0080) == 0)
	{
		count++;
	}
	if(count > 750)
		count = 0;
	else
		return;
	while((GPIOA->IDR & 0x0080) != 0);
	for(int i=0;i<32;i++)
	{
		while((GPIOA->IDR & 0x0080) == 0)
		{
			count++;
		}
		if(count > 750)
		{
			count = 0;
			i = 0;
			while((GPIOA->IDR & 0x0080) != 0);
			continue;
		}
		count = 0;
		while((GPIOA->IDR & 0x0080) != 0)
		{
			count++;
			if(count >5000)
			{
				return;
			}
		}
		if(count > 50)
		{
			code = code<<1;
			code++;
		}
		else
		{
			code = code<<1;
		}
	}
	switch(code)
		{
			case 0x00FF629D:
				/*" FORWARD"*/
				GPIOC->ODR = 0b0011;
				mode = 3;
				break;
			case 0x00FF22DD:
				/*" LEFT"*/
				GPIOC->ODR = 0b001;
				mode = 2;
				break;
			case 0x00FF02FD:
				/*" -OK-"*/
				break;
			case 0x00FFC23D:
				/*" RIGHT"*/
				GPIOC->ODR = 0b0010;
				mode = 1;
				break;
			case 0x00FFA857:
				/*" REVERSE"*/
				break;
			case 0x00FF6897:
				/*" 1"*/
				break;
			case 0x00FF9867:
				/*" 2"*/
				break;
			case 0x00FFB04F:
				/*" 3"*/
				break;
			case 0x00FF30CF:
				/*" 4"*/
				break;
			case 0x00FF18E7:
				/*" 5"*/
				break;
			case 0x00FF7A85:
				/*" 6"*/
				break;
			case 0x00FF10EF:
				/*" 7"*/
				break;
			case 0x00FF38C7:
				/*" 8"*/
				break;
			case 0x00FF5AA5:
				/*" 9"*/
				break;
			case 0x00FF42BD:
				/*" *"*/
				break;
			case 0x00FF4AB5:
				/*" 0"*/
				break;
			case 0x00FF52AD:
				/*" #"*/
				break;
			case 0xFFFFFFFF:
				/*" REPEAT"*/
				break;
			default:
				break;
		}
	return;
}
void clr_cmd()
{
	//clear previous command
	GPIOC->ODR = 0b0000;
	mode =0;
	return;
}
int main()
{
	GPIO_init();
	SystemClock_Config();
	int release = 0;
	mode =0;
	while(1)
	{
		while((GPIOA->IDR & 0x0080) != 0)
		{
			release++;
			if(release >5000)
			{
				clr_cmd();
			}
		}
		IR_receive();
		release = 0;
	}
	return 0;
}
