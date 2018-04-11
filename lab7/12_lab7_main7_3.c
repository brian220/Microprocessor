#include "stm32l476xx.h"
#include <stdlib.h>
#include <stdio.h>
#define X0 0b1
#define X1 0b10
#define X2 0b100
#define X3 0b1000
#define Y0 0b1000
#define Y1 0b10000
#define Y2 0b100000
#define Y3 0b1000000
unsigned int x_pin[4] = {X0, X1, X2, X3};
unsigned int y_pin[4] = {Y0, Y1, Y2, Y3};
int PRE = 400000;

unsigned int keypad[4][4] ={{2616,2937,3296,0},{3492,3920,4400,0},{4939,5233,0,0},{0,0,0,0}};
extern void GPIO_init();
void GPIO_init_AF(){
    //TODO: Initial GPIO pin as alternate function for buzzer. You can choose to use C or assembly to finish this function.
	GPIOA->MODER &= 0xfffffffc;//pa[0] = buzz;
    GPIOA->MODER |= 0x00000002;
	GPIOA->OSPEEDR  &= 0xfffffffc;
	GPIOA->OSPEEDR |= 0x00000002;
	GPIOA->AFR[0] |= 1;

	RCC->AHB2ENR = RCC->AHB2ENR|0x7;
	GPIOC->MODER &= 0xffffff00;//pc0123 = output;
	GPIOC->MODER |= 0x00000055;
	GPIOC->PUPDR &= 0xffffff00;
	GPIOC->PUPDR |= 0x00000055;
	GPIOC->OSPEEDR &= 0xffffff00;
	GPIOC->OSPEEDR |= 0x00000055;
	GPIOC->ODR &= 0b0000;

	GPIOB->MODER &= 0xffffc03f;//pb3456 = input;
	GPIOB->PUPDR &= 0xffffc03f;
	GPIOB->PUPDR |= 0x00002a80;
	GPIOB->OSPEEDR &= 0xffffc03f;
	GPIOB->OSPEEDR |= 0x00001540;
	return;
}
void Timer_init(){
    //TODO: Initialize timer
	RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;

	TIM2->ARR = (uint32_t)99;//Reload value
	TIM2->CCR1 = (uint32_t)49;
	TIM2->PSC = (uint32_t)PRE;//Prescaler

	TIM2->CCMR1 |= 7 << 4;
	TIM2->CCMR1 |= 1 << 3;

	TIM2->CCER |= 1;
	TIM2->EGR = TIM_EGR_UG;
	return;
}

int main(){
	GPIO_init();
	GPIO_init_AF();
    Timer_init();
	while(1) {
		TIM2->PSC = (uint32_t)PRE / 3000;
		TIM2->CR1 |= TIM_CR1_CEN;
	    GPIOC -> ODR &= 0;
	    GPIOC -> ODR |= (1 << 1); // x check col	  
    }
	
	
	/*
    int t = 0;
    int press_tag = 0;
    int k = 0;
	//TODO: Scan the keypad and use PWM to send the corresponding frequency square wave to buzzer.
	while(1){

		    for(int x_col = 0; x_col < 4; x_col ++){

		    	TIM2->CR1 &= ~(TIM_CR1_CEN);
			    GPIOC -> ODR &= 0;
			    GPIOC -> ODR |= (1 << x_col); // x check col
			    for(int y_row = 0; y_row < 4; y_row ++){

			    	int press = GPIOB -> IDR & (1 << (y_row + 3));
				    if(press){
				    	t = keypad[y_row][x_col];
				    	TIM2->PSC = (uint32_t)PRE / t;
				    	TIM2->CR1 |= TIM_CR1_CEN;

				    	while(k > 0 || (GPIOB -> IDR & 0b1111000) > 0){
				    		if((GPIOB -> IDR & 0b1111000) > 0){

				    			  k =  1000;
				    		}
				    	    else{

				    			  k --;
				    		}
				    	}
				    }
			    }

		    }
		}*/
		
}
