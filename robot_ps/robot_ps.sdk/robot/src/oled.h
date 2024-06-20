/*
 * oled.h
 *
 *  Created on: 2024��5��9��
 *      Author: 25732
 */

#ifndef OLED_H_
#define OLED_H_

#include "stdlib.h"
#include "xil_types.h"
#include "xil_io.h"
//OLEDģʽ����
//0:4�ߴ���ģʽ
//1:����8080ģʽ
#define OLED_MODE 0
#define SIZE 16
#define XLevelL		0x00
#define XLevelH		0x10
#define Max_Column	128
#define Max_Row		64
#define	Brightness	0xFF
#define X_WIDTH 	128
#define Y_WIDTH 	64
//-----------------OLED�˿ڶ���----------------

#define OLED_BASE_ADDR XPAR_OLED_IP_0_S00_AXI_BASEADDR

//Xil_Out32д�룬Xil_In32��ȡ

//TRI��reg0
#define OLED_TRI_Set() (Xil_Out32(OLED_BASE_ADDR,  1))
#define OLED_TRI_Clr() (Xil_Out32(OLED_BASE_ADDR,  0))

// DC��reg1 0���ݣ�1����
#define OLED_DC_Set() (Xil_Out32(OLED_BASE_ADDR + 4, 1))
#define OLED_DC_Clr() (Xil_Out32(OLED_BASE_ADDR + 4, 0))

// DATA����reg2
#define OLED_Data_Set(data) (Xil_Out32(OLED_BASE_ADDR + 8, data))
#define OLED_Data_Clr() (Xil_Out32(OLED_BASE_ADDR + 8, 0))

//RST reg3
#define OLED_RST_Set() (Xil_Out32(OLED_BASE_ADDR + 12, 1))
#define OLED_RST_Clr() (Xil_Out32(OLED_BASE_ADDR + 12, 0))

//Busy reg4
#define OLED_BUSY_Set() (Xil_In32(OLED_BASE_ADDR + 16))

#define OLED_CMD  0	//д����#define OLED_DATA 1	//д����
//OLED�����ú���
void OLED_WR_Byte(u8 dat, u8 cmd);
void OLED_Display_On(void);
void OLED_Display_Off(void);
void OLED_Init(void);
void OLED_Clear(void);
void OLED_DrawPoint(u8 x, u8 y, u8 t);
void OLED_Fill(u8 x1, u8 y1, u8 x2, u8 y2, u8 dot);
void OLED_ShowChar(u8 x, u8 y, u8 chr);
void OLED_ShowNum(u8 x, u8 y, u32 num, u8 len, u8 size);
void OLED_ShowString(u8 x, u8 y, u8 *p);
void OLED_Set_Pos(unsigned char x, unsigned char y);
void OLED_ShowCHinese(u8 x, u8 y, u8 no);
void OLED_DrawBMP(unsigned char x0, unsigned char y0, unsigned char x1,
		unsigned char y1, unsigned char BMP[]);

void robot_vs_human(int sr, int sh);

void robot_win();

void human_win();
#endif
