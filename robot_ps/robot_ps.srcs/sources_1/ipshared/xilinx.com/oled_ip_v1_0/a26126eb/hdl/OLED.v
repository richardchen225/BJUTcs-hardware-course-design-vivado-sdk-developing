`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/01 11:40:38
// Design Name: 
// Module Name: OLED
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


module OLED (SCL, SDA, DaCom, clk, s_rst_n,rst_n, DATA, DC, TRI, res, CS, Busy);
input clk,s_rst_n,rst_n,DaCom,TRI;//总线时钟，复位，命令 or 数据， 发送触发信号
input [7:0] DATA;
output SCL,SDA,DC,res,Busy; //slave时钟，slave数据，命令 or 数据，复位，片选，是否忙碌
output reg CS;
reg DC;//命令or数据
reg SCL_buf; //从机时钟
reg [7:0] Data_buf; //数据缓冲区
reg link_SDA,link_SCL; //总线是否连接到对应寄存器上
reg [3:0] main_state; //主状态寄存器

parameter Ready = 4'b0000;
parameter Shift_7bit = 4'b0001;
parameter Shift_6bit = 4'b0010;
parameter Shift_5bit = 4'b0011;
parameter Shift_4bit = 4'b0100;
parameter Shift_3bit = 4'b0101;
parameter Shift_2bit = 4'b0110;
parameter Shift_1bit = 4'b0111;
parameter Shift_0bit = 4'b1000;
parameter End = 4'b1001;

assign res = s_rst_n;
assign SCL = link_SCL ? SCL_buf : 1'b0; //时钟是否连接
assign SDA = link_SDA ? Data_buf[7] : 1'bz;//数据是否连接
//assign CS = 1'b0; //一个slave，定死为0

assign Busy = ((main_state != Ready) &&  (CS == 1'b0)) ? 1'b1 : 1'b0; //开始发送时busy置高，准备就绪则置0

reg [4:0] count;
//spi最大频率为5Mhz，总线时钟是100Mhz
always @(negedge clk) 
    if(!s_rst_n) 
        begin
            count <= 5'd0;
            SCL_buf<=1'b0;
        end
     else
        if(count == 5'd59)
            begin
                SCL_buf = ~SCL_buf;
                count <= 5'd0;
            end
        else 
            count <= count + 5'd1;
            
always @(negedge SCL_buf)
    if(main_state == End)
        CS <= 1'b1;
    else if(main_state == Ready)
        CS <= 1'b1;
    else
        CS <= 1'b0;


//数据移位
always @(negedge SCL_buf) begin
    if(TRI == 1)
        Data_buf <= DATA;//初始化
    if(main_state == Ready && TRI)
        Data_buf <= DATA;//若多个数据的话
    else if(main_state == End)
        Data_buf[7] <= 1'bz;
    else if(main_state != Ready && main_state != Shift_7bit) //Shift_7bit本质是ready2
        Data_buf <= Data_buf << 1;
    else
        Data_buf <= Data_buf;
end     

//状态转移
always @(posedge SCL_buf or negedge rst_n)
    if(!rst_n) 
        begin
        link_SCL <= 0;
        link_SDA <= 0;
        main_state <= Ready;
        DC <= 0;
        end
    else 
        begin
            case (main_state)
                Ready:
                    if(TRI) //当TRI为1时发送
                        begin 
                            link_SCL <= 1;
                            link_SDA <= 1; //SDA线连接到数据寄存器
                            main_state <= Shift_7bit; 
                            if(DaCom) 
                                DC <= 1; //选择发送数据或命令
                            else 
                                DC <= 0; 
                        end
              
                Shift_7bit:
                    main_state <= Shift_6bit; 
                    //就绪2
                    
                Shift_6bit:
                    main_state <= Shift_5bit; //准备发送下一位

                Shift_5bit:
                    main_state <= Shift_4bit; 
                    
                Shift_4bit:
                    main_state <= Shift_3bit; 
                 
                Shift_3bit:
                    main_state <= Shift_2bit; 

                Shift_2bit:
                    main_state <= Shift_1bit; 

                Shift_1bit:
                    main_state <= Shift_0bit; 

                Shift_0bit:
                    main_state <= End;

             End:
                   begin
                       link_SCL <= 0; //断开时钟线
                       link_SDA <= 0; //断开数据
                       main_state <= Ready; 
                       DC <= 0; 
                    end
            endcase
        end
          
endmodule