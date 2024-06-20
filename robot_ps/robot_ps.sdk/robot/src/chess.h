/*
 * chess.h
 *
 *  Created on: 2024Äê5ÔÂ30ÈÕ
 *      Author: chenr
 */

#ifndef CHESS_H_
#define CHESS_H_

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

bool is_win(int chess[9][9], int player);

void Point_rand(int chess[9][9], int *x, int *y);

void reverse(int row[5]);

int score(int row[5], int x);

int score_row(int chess[9][9], int x, int y);

int score_col(int chess[9][9], int x, int y);

int score_ltor(int chess[9][9], int x, int y);

int score_rtol(int chess[9][9], int x, int y);

int score_total(int chess[9][9], int x, int y);

void Point_score(int chess[9][9], int *x, int *y);

#endif /* CHESS_H_ */
