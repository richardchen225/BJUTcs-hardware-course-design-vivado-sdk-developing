#include <stdio.h>
#include "xparameters.h"
#include <xil_io.h>
#include <sleep.h>
#include <vector>
#include <iostream>
#include <utility>
#include "chess.h"
#include "Robotarm_ps.h"
#include "oled.h"
#include "ov5640.h"
#include "tts.h"
using namespace std;
#define BRAM_ADDR XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR
#define DVP_ADDR XPAR_OV5640_DVP_BRAM_0_S00_AXI_BASEADDR
#define ROBOTARM_ADDR XPAR_ROBOTARM_CAR_0_S00_AXI_BASEADDR

//玩家—白—1    机器—黑—2 

int main() {
	//玩家分数、机器分数 
	int score_human = 0, score_ai = 0;
	//机械臂使能初始化
	Xil_Out32(ROBOTARM_ADDR + 12, 0);

	while (1) {
		//tts说该人类下了
		renleixuanshou();
		//刷新显示屏
		robot_vs_human(score_ai, score_human);
		// 摄像头捕获数据并且图像处理
		vector<vector<int> > board;
		Xil_Out32(DVP_ADDR + 4, 0);
		while (!Xil_In32(DVP_ADDR)) {
			printf("z");
		}
		jiqirenxuanshou();
		if (Xil_In32(DVP_ADDR)) {
			sleep(1);
			board = psReadBram();
			Xil_Out32(DVP_ADDR + 4, 1);
		}
		// 将棋盘信息传输给五子棋算法程序
		int chess[9][9];
		for (int i = 0; i < 9; i++)
			for (int j = 0; j < 9; j++)
				chess[i][j] = board[i][j];
		//玩家获胜
		if (is_win(chess, 1)) {
			gongxirenlei();
			score_human++;
			human_win();
			start();
		} else {
			//获取下棋坐标
			int x, y;
			Point_score(chess, &x, &y);
			printf("%d\n%d\n", x, y);
			// 机械臂开始根据坐标位置下棋
			int A, B, C;
			trans(x, y, &A, &B, &C);
			Xil_Out32(ROBOTARM_ADDR, A);
			Xil_Out32(ROBOTARM_ADDR + 4, B);
			Xil_Out32(ROBOTARM_ADDR + 8, C);
			Xil_Out32(ROBOTARM_ADDR + 12, 1);
			sleep(1);
			Xil_Out32(ROBOTARM_ADDR + 12, 0);
			sleep(5);
			//电脑获胜
			chess[x][y] = 2;
			if (is_win(chess, 2)) {
				gongxijiqiren();
				score_ai++;
				robot_win();
				start();
			}
		}
	}
	return 0;
}

