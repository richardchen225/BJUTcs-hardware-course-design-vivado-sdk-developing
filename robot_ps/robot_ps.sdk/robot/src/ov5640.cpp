#include"ov5640.h"
using namespace std;

#define BRAM_ADDR XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR
#define DVP_ADDR XPAR_OV5640_DVP_BRAM_0_S00_AXI_BASEADDR

int xy[9][9][2] = { { { 12, 70 }, { 12, 104 }, { 12, 154 }, { 12, 198 }, { 12,
		238 }, { 12, 296 }, { 12, 334 }, { 12, 376 }, { 12, 420 } }, {
		{ 54, 70 }, { 54, 104 }, { 54, 154 }, { 54, 198 }, { 54, 238 }, { 54,
				296 }, { 54, 334 }, { 54, 376 }, { 54, 420 } }, { { 124, 70 }, {
		124, 104 }, { 124, 154 }, { 124, 198 }, { 124, 238 }, { 124, 290 }, {
		124, 334 }, { 124, 376 }, { 124, 420 } }, { { 182, 70 }, { 182, 104 }, {
		182, 154 }, { 182, 198 }, { 182, 230 }, { 182, 296 }, { 182, 334 }, {
		182, 376 }, { 182, 420 } }, { { 250, 70 }, { 250, 104 }, { 250, 154 }, {
		250, 198 }, { 250, 238 }, { 250, 296 }, { 250, 334 }, { 250, 376 }, {
		250, 420 } },

{ { 312, 70 }, { 312, 104 }, { 312, 154 }, { 312, 198 }, { 312, 238 }, { 312,
		296 }, { 312, 334 }, { 312, 376 }, { 312, 420 } }, { { 384, 70 }, { 384,
		104 }, { 384, 154 }, { 384, 198 }, { 384, 238 }, { 384, 296 }, { 384,
		334 }, { 384, 376 }, { 384, 420 } }, { { 432, 70 }, { 432, 104 }, { 432,
		154 }, { 432, 198 }, { 432, 238 }, { 432, 296 }, { 432, 334 }, { 432,
		376 }, { 432, 420 } }, { { 482, 70 }, { 482, 104 }, { 482, 154 }, { 482,
		198 }, { 482, 238 }, { 482, 296 }, { 482, 334 }, { 482, 376 }, { 482,
		420 } } };

pair<float, float> ratio(vector<vector<int> > img) {
	int height = img.size();
	int width = img[0].size();

	int a = 0, b = 0;

	for (int row = 0; row < height; row++) {
		for (int col = 0; col < width; col++) {
			int val = img[row][col];
			if (val >= 0 && val <= 70) // 根据实际情况调整颜色范围
				a++;
			else if (val >= 180 && val <= 255)
				b++;
		}
	}

	float black_ratio = a * 1.0 / (height * width);
	float white_ratio = b * 1.0 / (height * width);
	pair<float, float> p(black_ratio, white_ratio);
	return p;
}

vector<vector<int> > board_pro(vector<vector<int> > gray) {
	vector<vector<int> > list(9, vector<int>(9, 0));
	int diameter = 35;
	for (int i = 0; i < 9; i++) {
		for (int j = 0; j < 9; j++) {

			// 图像切块
			vector<vector<int> > imgTemp(diameter, vector<int>(diameter, 0));
			for (int k = xy[i][j][0]; k < xy[i][j][0] + diameter; k++) {
				for (int h = xy[i][j][1]; h < xy[i][j][1] + diameter; h++) {
					imgTemp[k - xy[i][j][0]][h - xy[i][j][1]] = gray[k][h];
				}
			}
			pair<float, float> r = ratio(imgTemp);
			float b = r.first;
			float w = r.second;
			if (b > 0.4) {
				list[i][j] = 2; // Black
			} else if (w > 0.3) {
				list[i][j] = 1; // White
			} else {
				list[i][j] = 0; // Empty
			}
		}
	}
	return list;
}

vector<vector<int> > psReadBram() {
	int data = 0;
	int k = 1;
	vector<vector<int> > gray(512, vector<int>(512, 0));
	int cnt = 0;
	while (k < 130817) {
		data = Xil_In32(BRAM_ADDR + 4 * k);
		int first = (data & 0xffff0000) >> 16;
		int R1 = (first & 0xf800) >> 8;
		int G1 = (first & 0x07E0) >> 3;
		int B1 = (first & 0x001f) << 3;
		int g1 = R1 * 0.3 + G1 * 0.59 + B1 * 0.11;
		gray[cnt / 512][cnt % 512] = g1;
		cnt++;
		int second = data & 0x0000ffff;
		int R2 = (second & 0xf800) >> 8;
		int G2 = (second & 0x07E0) >> 3;
		int B2 = (second & 0x001f) << 3;
		int g2 = R2 * 0.3 + G2 * 0.59 + B2 * 0.11;
		gray[cnt / 512][cnt % 512] = g2;
		cnt++;
		k++;
	}
	for (int i = 0; i < 512; i++) {
		gray[511][i] = gray[510][i];
	}
	// 输入的img是灰度棋盘图像
	vector<vector<int> > board = board_pro(gray);
	for (int i = 0; i < 9; i++) {
		for (int j = 0; j < 9; j++) {
			printf("%d ", board[i][j]);
		}
		printf("\n");
	}
	return board;
}

