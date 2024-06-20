#include"chess.h"

//玩家：1    电脑：2 

bool is_win(int chess[9][9], int player) {
	int count;
	//横向检查
	for (int i = 0; i < 9; i++) {
		count = 0;
		for (int j = 0; j < 9; j++) {
			if (chess[i][j] == player)
				count++;
			else
				count = 0;
			if (count == 5)
				return true;
		}
	}
	//纵向检查 
	for (int j = 0; j < 9; j++) {
		count = 0;
		for (int i = 0; i < 9; i++) {
			if (chess[i][j] == player)
				count++;
			else
				count = 0;
			if (count == 5)
				return true;
		}
	}
	//主对角线检查
	for (int i = 0; i < 5; i++)
		for (int j = 0; j < 5; j++) {
			count = 0;
			for (int k = 0; k < 5; k++) {
				if (chess[i + k][j + k] == player)
					count++;
				else
					count = 0;
				if (count == 5)
					return true;
			}
		}
	//副对角线检查
	for (int i = 0; i < 5; i++)
		for (int j = 8; j >= 4; j--) {
			count = 0;
			for (int k = 0; k < 5; k++) {
				if (chess[i + k][j - k] == player)
					count++;
				else
					count = 0;
				if (count == 5)
					return true;
			}
		}
	return false;
}

//void Point_rand(int chess[9][9],int *x,int *y) //随机数下法
//{
//	srand(time(NULL));
//	while(1)
//	{
//		*x=rand()%9;
//        *y=rand()%9;
//        if(chess[*x][*y]==0) break;
//	}
//}

void reverse(int row[5]) //x=3、4的评分和x=1、0的评分相同，反转以简化计算量 
		{
	int temp;
	for (int i = 0, j = 4; i <= j; i++, j--) {
		temp = row[i];
		row[i] = row[j];
		row[j] = temp;
	}
}

int score(int row[5], int x) //评分函数 
		{
	if (x > 2) {
		reverse(row);
		x = 4 - x;
	}
	switch (x) {
	case 0: {
		if (row[1] == 2 && (row[2] == 2 || row[2] == 0)
				&& (row[3] == 2 || row[3] == 0)
				&& (row[4] == 2 || row[4] == 0)) {
			if (row[2] == 0)		//_20XX
				return (15);
			else if (row[3] == 0)	//_220X
				return (50);
			else if (row[4] == 0)  //_2220
				return (90);
			else
				//_2222
				return (1000);
		} else if (row[1] == 1 && (row[2] == 1 || row[2] == 0)
				&& (row[3] == 1 || row[3] == 0)
				&& (row[4] == 1 || row[4] == 0)) {
			if (row[2] == 0)		//_10XX
				return (5);
			else if (row[3] == 0)  //_110X
				return (30);
			else if (row[4] == 0)	//_1110
				return (70);
			else
				//_1111
				return (500);
		}
	}
		break;
	case 1: {
		if ((row[0] == 2 || row[0] == 0) && (row[2] == 2 || row[2] == 0)
				&& (row[3] == 2 || row[3] == 0)
				&& (row[4] == 2 || row[4] == 0)) {
			if (row[0] == 2) {
				if (row[2] == 0)		//2_0XX
					return (15);
				else if (row[3] == 0)  //2_20X
					return (50);
				else if (row[4] == 0)  //2_220
					return (90);
				else
					//2_222
					return (1000);
			} else if (row[2] == 0)      //0_0XX
				return (0);
			else if (row[3] == 0)      //0_20X
				return (15);
			else if (row[4] == 0)		//0_220
				return (50);
			else
				//0_222
				return (80);
		} else if ((row[0] == 1 || row[0] == 0) && (row[2] == 1 || row[2] == 0)
				&& (row[3] == 1 || row[3] == 0)
				&& (row[4] == 1 || row[4] == 0)) {
			if (row[0] == 1) {
				if (row[2] == 0)	    //1_0XX
					return (5);
				else if (row[3] == 0)  //1_10X
					return (30);
				else if (row[4] == 0)  //1_110
					return (70);
				else
					//1_111
					return (500);
			} else if (row[2] == 0)	    //0_0XX
				return (0);
			else if (row[3] == 0)	    //0_10X
				return (5);
			else if (row[4] == 0)      //0_110
				return (30);
			else
				//0_111
				return (60);
		}
	}
		break;
	case 2: {
		if ((row[0] == 2 || row[0] == 0) && (row[1] == 2 || row[1] == 0)
				&& (row[3] == 2 || row[3] == 0)
				&& (row[4] == 2 || row[4] == 0)) {
			if (row[1] == 2) {
				if (row[3] == 2) {
					if (row[0] == 2) {
						if (row[4] == 2)   //22_22
							return (1000);
						else
							return (90);	//22_20
					} else {
						if (row[4] == 2)   //02_22
							return (90);
						else
							//02_20
							return (50);
					}
				} else {
					if (row[0] == 2)       //22_0X
						return (40);
					else
						//02_0X
						return (15);
				}
			} else {
				if (row[3] == 2) {
					if (row[4] == 2)   	//X0_22
						return (40);
					else
						//X0_20
						return (15);
				}
			}
		} else if ((row[0] == 1 || row[0] == 0) && (row[1] == 1 || row[1] == 0)
				&& (row[3] == 1 || row[3] == 0)
				&& (row[4] == 1 || row[4] == 0)) {
			if (row[1] == 1) {
				if (row[3] == 1) {
					if (row[0] == 1) {
						if (row[4] == 1)   //11_11
							return (500);
						else
							//11_10
							return (70);
					} else {
						if (row[4] == 1)   //01_11
							return (70);
						else
							//01_10
							return (30);
					}
				} else {
					if (row[0] == 1)   	//11_0X
						return (20);
					else
						//01_0X
						return (5);
				}
			} else {
				if (row[3] == 1) {
					if (row[4] == 1)       //X0_11
						return (20);
					else
						//X0_10
						return (5);
				}
			}
		}
	}
		break;
	}
	return (0);
}

int score_row(int chess[9][9], int x, int y) //截取横向覆盖的数组 
		{
	int sum = 0, row[5];
	for (int i = y - 4; i <= y; i++) {
		if (!(i >= 0 && i <= 4))
			continue;
		else {
			for (int j = 0; j < 5; j++)
				row[j] = chess[x][i + j];
			sum += score(row, y - i);
		}
	}
	return sum;
}

int score_col(int chess[9][9], int x, int y) //截取纵向覆盖的数组 
		{
	int sum = 0, row[5];
	for (int i = x - 4; i <= x; i++) {
		if (!(i >= 0 && i <= 4))
			continue;
		else {
			for (int j = 0; j < 5; j++)
				row[j] = chess[i + j][y];
			sum += score(row, x - i);
		}
	}
	return sum;
}

int score_ltor(int chess[9][9], int x, int y) //截取主对角线覆盖的数组 
		{
	int sum = 0, row[5];
	for (int i = -4; i <= 0; i++) {
		if (!(x + i >= 0 && y + i >= 0 && y + i <= 4 && x + i <= 4))
			continue;
		else {
			for (int j = 0; j < 5; j++)
				row[j] = chess[x + i + j][y + i + j];
			sum += score(row, -i);
		}
	}
	return sum;
}

int score_rtol(int chess[9][9], int x, int y) //截取副对角线覆盖的数组 
		{
	int sum = 0, row[5];
	for (int i = -4; i <= 0; i++) {
		if (!(x - i >= 4 && y + i >= 0 && x - i <= 8 && y + i <= 4))
			continue;
		else {
			for (int j = 0; j < 5; j++)
				row[j] = chess[x - i - j][y + i + j];
			sum += score(row, -i);
		}
	}
	return sum;
}

int score_total(int chess[9][9], int x, int y) //位置总评分 
		{
	int sum = 0;
	sum += score_row(chess, x, y);
	sum += score_col(chess, x, y);
	sum += score_ltor(chess, x, y);
	sum += score_rtol(chess, x, y);
	return sum;
}

void Point_score(int chess[9][9], int *x, int *y) //分数最大下法 
		{
	int sum, max = -1;
	for (int i = 0; i < 8; i++) {
		for (int j = 0; j < 9; j++) {
			if (chess[i][j] != 0)
				continue;
			sum = 0;
			sum += score_total(chess, i, j);
			if (sum > max) {
				max = sum;
				*x = i;
				*y = j;
			}
		}
	}
}
