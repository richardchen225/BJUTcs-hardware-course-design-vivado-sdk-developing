`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/02 13:56:19
// Design Name: 
// Module Name: Robotarm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Robotarm(
input clk,rst,en,
input [31:0] period_A,period_B,period_C,
output reg pwm_s1,pwm_s2,pwm_s3,pump
);
reg [3:0] state;
reg [31:0] cnt_cycle,cnt_delay;
parameter cycle='d200_0000;
parameter delay='d1_0000_0000;
parameter period_min='d5_0000;
parameter period_up='d7_0000;
parameter period_take='d10_5000;
parameter period_mid='d11_0000;

always @ (posedge clk)
    if(rst==1'b0) cnt_cycle<=32'b0;
    else
        if(cnt_cycle<cycle) cnt_cycle<=cnt_cycle+1'b1;
        else cnt_cycle<=32'b0;

always @ (posedge clk)
    if(rst==1'b0)
        begin
        state<=4'b0000;
        cnt_delay<=32'b0;
        pwm_s1<=1'b0;
        pwm_s2<=1'b0;
        pwm_s3<=1'b0;
        pump<=1'b0;
        end
    else
        case(state)
        4'b0000:
            begin
            pwm_s1<=(cnt_cycle<period_min) ? 1:0;
            pwm_s2<=(cnt_cycle<period_mid) ? 1:0;
            pwm_s3<=(cnt_cycle<period_take) ? 1:0;
            pump<=1'b0;
            if(en==1'b1) state<=4'b0001;
            end
        4'b0001:
            begin
            pwm_s1<=(cnt_cycle<period_min) ? 1:0;
            pwm_s2<=(cnt_cycle<period_mid) ? 1:0;
            pwm_s3<=(cnt_cycle<period_take) ? 1:0;
            pump<=1'b1;
            if(cnt_delay==2*delay) begin cnt_delay<=32'b0; state<=4'b0010; end
            else cnt_delay<=cnt_delay+1'b1;
            end
        4'b0010:
            begin
            pwm_s1<=(cnt_cycle<period_min) ? 1:0;
            pwm_s2<=(cnt_cycle<period_mid) ? 1:0;
            pwm_s3<=(cnt_cycle<period_up) ? 1:0;
            pump<=1'b1;
            if(cnt_delay==delay) begin cnt_delay<=32'b0; state<=4'b0011; end
            else cnt_delay<=cnt_delay+1'b1;
            end
        4'b0011:
            begin
            pwm_s1<=(cnt_cycle<period_A) ? 1:0;
            pwm_s2<=(cnt_cycle<period_mid) ? 1:0;
            pwm_s3<=(cnt_cycle<period_up) ? 1:0;
            pump<=1'b1;
            if(cnt_delay==delay) begin cnt_delay<=32'b0; state<=4'b0100; end
            else cnt_delay<=cnt_delay+1'b1;
            end
        4'b0100:
            begin
            pwm_s1<=(cnt_cycle<period_A) ? 1:0;
            pwm_s2<=(cnt_cycle<period_B) ? 1:0;
            pwm_s3<=(cnt_cycle<period_up) ? 1:0;
            pump<=1'b1;
            if(cnt_delay==delay) begin cnt_delay<=32'b0; state<=4'b0101; end
            else cnt_delay<=cnt_delay+1'b1;
            end
        4'b0101:
            begin
            pwm_s1<=(cnt_cycle<period_A) ? 1:0;
            pwm_s2<=(cnt_cycle<period_B) ? 1:0;
            pwm_s3<=(cnt_cycle<period_C) ? 1:0;
            pump<=1'b1;
            if(cnt_delay==delay) begin cnt_delay<=32'b0; state<=4'b0110; end
            else cnt_delay<=cnt_delay+1'b1;
            end
        4'b0110:
            begin
            pwm_s1<=(cnt_cycle<period_A) ? 1:0;
            pwm_s2<=(cnt_cycle<period_B) ? 1:0;
            pwm_s3<=(cnt_cycle<period_C) ? 1:0;
            pump<=1'b0;
            if(cnt_delay==delay) begin cnt_delay<=32'b0; state<=4'b0111; end
            else cnt_delay<=cnt_delay+1'b1;
            end
        4'b0111:
            begin
            pwm_s1<=(cnt_cycle<period_A) ? 1:0;
            pwm_s2<=(cnt_cycle<period_B) ? 1:0;
            pwm_s3<=(cnt_cycle<period_up) ? 1:0;
            pump<=1'b0;
            if(cnt_delay==delay) begin cnt_delay<=32'b0; state<=4'b1000; end
            else cnt_delay<=cnt_delay+1'b1;
            end
        4'b1000:
            begin
            pwm_s1<=(cnt_cycle<period_A) ? 1:0;
            pwm_s2<=(cnt_cycle<period_mid) ? 1:0;
            pwm_s3<=(cnt_cycle<period_up) ? 1:0;
            pump<=1'b0;
            if(cnt_delay==delay) begin cnt_delay<=32'b0; state<=4'b1001; end
            else cnt_delay<=cnt_delay+1'b1;
            end
        4'b1001:
            begin
            pwm_s1<=(cnt_cycle<period_min) ? 1:0;
            pwm_s2<=(cnt_cycle<period_mid) ? 1:0;
            pwm_s3<=(cnt_cycle<period_up) ? 1:0;
            pump<=1'b0;
            if(cnt_delay==delay) begin cnt_delay<=32'b0; state<=4'b0000; end
            else cnt_delay<=cnt_delay+1'b1;
            end
        endcase
endmodule
