/*
 * ov5640.h
 *
 *  Created on: 2024Äê5ÔÂ31ÈÕ
 *      Author: chenr
 */

#ifndef OV5640_H_
#define OV5640_H_
#include <stdio.h>
#include "xparameters.h"
#include <xil_io.h>
#include <sleep.h>
#include <vector>
#include <iostream>
#include <utility>
using namespace std;
pair<float, float> ratio(vector<vector<int> > img);

vector<vector<int> > board_pro(vector<vector<int> > gray);

vector<vector<int> > psReadBram();

#endif /* OV5640_H_ */
