/*
 * Robotarm_ps.c
 *
 *  Created on: 2024��5��4��
 *      Author: Jiawei_Shen
 */
#include"Robotarm_ps.h"

void trans(int x, int y, int *A, int *B, int *C) {
	if (x == 0 && y == 0) {
		*A = 100000;
		*B = 165636;
		*C = 155000;
	} else if (x == 0 && y == 1) {
		*A = 110000;
		*B = 170636;
		*C = 159000;
	} else if (x == 0 && y == 2) {
		*A = 119000;
		*B = 173636;
		*C = 164000;
	} else if (x == 0 && y == 3) {
		*A = 130000;
		*B = 175636;
		*C = 170000;
	} else if (x == 0 && y == 4) {
		*A = 143500;
		*B = 175636;
		*C = 172000;
	} else if (x == 0 && y == 5) {
		*A = 158000;
		*B = 175636;
		*C = 170000;
	} else if (x == 0 && y == 6) {
		*A = 170000;
		*B = 173636;
		*C = 165000;
	} else if (x == 0 && y == 7) {
		*A = 181000;
		*B = 171636;
		*C = 159000;
	} else if (x == 0 && y == 8) {
		*A = 190000;
		*B = 168636;
		*C = 151000;
	}

	else if (x == 1 && y == 0) {
		*A = 106000;
		*B = 162136;
		*C = 142000;
	} else if (x == 1 && y == 1) {
		*A = 114000;
		*B = 167136;
		*C = 147000;
	} else if (x == 1 && y == 2) {
		*A = 124000;
		*B = 171136;
		*C = 150000;
	} else if (x == 1 && y == 3) {
		*A = 133000;
		*B = 172936;
		*C = 153000;
	} else if (x == 1 && y == 4) {
		*A = 144000;
		*B = 173036;
		*C = 154000;
	} else if (x == 1 && y == 5) {
		*A = 156000;
		*B = 172636;
		*C = 153000;
	} else if (x == 1 && y == 6) {
		*A = 167000;
		*B = 170636;
		*C = 150000;
	} else if (x == 1 && y == 7) {
		*A = 177000;
		*B = 166636;
		*C = 147000;
	} else if (x == 1 && y == 8) {
		*A = 184000;
		*B = 164536;
		*C = 140000;
	}

	else if (x == 2 && y == 0) {
		*A = 111000;
		*B = 155136;
		*C = 132000;
	} else if (x == 2 && y == 1) {
		*A = 118000;
		*B = 159136;
		*C = 136000;
	} else if (x == 2 && y == 2) {
		*A = 126000;
		*B = 162136;
		*C = 140000;
	} else if (x == 2 && y == 3) {
		*A = 135000;
		*B = 165136;
		*C = 142000;
	} else if (x == 2 && y == 4) {
		*A = 144500;
		*B = 165836;
		*C = 143000;
	} else if (x == 2 && y == 5) {
		*A = 154000;
		*B = 165136;
		*C = 142000;
	} else if (x == 2 && y == 6) {
		*A = 163500;
		*B = 162136;
		*C = 140000;
	} else if (x == 2 && y == 7) {
		*A = 171000;
		*B = 159136;
		*C = 135000;
	} else if (x == 2 && y == 8) {
		*A = 180000;
		*B = 155136;
		*C = 132000;
	}

	else if (x == 3 && y == 0) {
		*A = 115000;
		*B = 147136;
		*C = 123000;
	} else if (x == 3 && y == 1) {
		*A = 121000;
		*B = 151636;
		*C = 127000;
	} else if (x == 3 && y == 2) {
		*A = 128000;
		*B = 155136;
		*C = 130000;
	} else if (x == 3 && y == 3) {
		*A = 136000;
		*B = 156136;
		*C = 132000;
	} else if (x == 3 && y == 4) {
		*A = 144500;
		*B = 156636;
		*C = 134000;
	} else if (x == 3 && y == 5) {
		*A = 152000;
		*B = 156136;
		*C = 132000;
	} else if (x == 3 && y == 6) {
		*A = 162000;
		*B = 155136;
		*C = 130000;
	} else if (x == 3 && y == 7) {
		*A = 169000;
		*B = 151636;
		*C = 126000;
	} else if (x == 3 && y == 8) {
		*A = 177000;
		*B = 147136;
		*C = 123000;
	}

	else if (x == 4 && y == 0) {
		*A = 118500;
		*B = 136136;
		*C = 113000;
	} else if (x == 4 && y == 1) {
		*A = 125000;
		*B = 140636;
		*C = 117000;
	} else if (x == 4 && y == 2) {
		*A = 130500;
		*B = 144136;
		*C = 119000;
	} else if (x == 4 && y == 3) {
		*A = 137500;
		*B = 145636;
		*C = 122000;
	} else if (x == 4 && y == 4) {
		*A = 145000;
		*B = 146636;
		*C = 123000;
	} else if (x == 4 && y == 5) {
		*A = 153000;
		*B = 145636;
		*C = 122000;
	} else if (x == 4 && y == 6) {
		*A = 160500;
		*B = 144136;
		*C = 119000;
	} else if (x == 4 && y == 7) {
		*A = 167000;
		*B = 140636;
		*C = 117000;
	} else if (x == 4 && y == 8) {
		*A = 173500;
		*B = 136136;
		*C = 113000;
	}

	else if (x == 5 && y == 0) {
		*A = 121000;
		*B = 125636;
		*C = 103000;
	} else if (x == 5 && y == 1) {
		*A = 127000;
		*B = 130136;
		*C = 107000;
	} else if (x == 5 && y == 2) {
		*A = 132000;
		*B = 134136;
		*C = 109000;
	} else if (x == 5 && y == 3) {
		*A = 138500;
		*B = 135136;
		*C = 110000;
	} else if (x == 5 && y == 4) {
		*A = 145500;
		*B = 136836;
		*C = 110000;
	} else if (x == 5 && y == 5) {
		*A = 152500;
		*B = 135136;
		*C = 110000;
	} else if (x == 5 && y == 6) {
		*A = 159500;
		*B = 134136;
		*C = 109000;
	} else if (x == 5 && y == 7) {
		*A = 165500;
		*B = 130636;
		*C = 107000;
	} else if (x == 5 && y == 8) {
		*A = 171000;
		*B = 125636;
		*C = 103000;
	}

	else if (x == 6 && y == 0) {
		*A = 124500;
		*B = 113636;
		*C = 90000;
	} else if (x == 6 && y == 1) {
		*A = 128000;
		*B = 118136;
		*C = 92500;
	} else if (x == 6 && y == 2) {
		*A = 134000;
		*B = 121136;
		*C = 94500;
	} else if (x == 6 && y == 3) {
		*A = 139000;
		*B = 122136;
		*C = 96000;
	} else if (x == 6 && y == 4) {
		*A = 146000;
		*B = 123136;
		*C = 96500;
	} else if (x == 6 && y == 5) {
		*A = 152000;
		*B = 122136;
		*C = 96000;
	} else if (x == 6 && y == 6) {
		*A = 159000;
		*B = 121136;
		*C = 94500;
	} else if (x == 6 && y == 7) {
		*A = 164250;
		*B = 117636;
		*C = 92500;
	} else if (x == 6 && y == 8) {
		*A = 169250;
		*B = 114636;
		*C = 89500;
	}

	else if (x == 7 && y == 0) {
		*A = 125250;
		*B = 97136;
		*C = 74000;
	} else if (x == 7 && y == 1) {
		*A = 129500;
		*B = 101136;
		*C = 77000;
	} else if (x == 7 && y == 2) {
		*A = 135000;
		*B = 104386;
		*C = 80000;
	} else if (x == 7 && y == 3) {
		*A = 140000;
		*B = 105136;
		*C = 82000;
	} else if (x == 7 && y == 4) {
		*A = 146000;
		*B = 105136;
		*C = 82500;
	} else if (x == 7 && y == 5) {
		*A = 151500;
		*B = 105636;
		*C = 82500;
	} else if (x == 7 && y == 6) {
		*A = 157500;
		*B = 104036;
		*C = 81000;
	} else if (x == 7 && y == 7) {
		*A = 163000;
		*B = 101136;
		*C = 77000;
	} else if (x == 7 && y == 8) {
		*A = 167500;
		*B = 97136;
		*C = 74000;
	}

	else {
		*A = 50000;
		*B = 110000;
		*C = 105000;
	}
}

