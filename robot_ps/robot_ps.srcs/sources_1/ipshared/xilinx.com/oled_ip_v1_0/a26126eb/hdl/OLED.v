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
input clk,s_rst_n,rst_n,DaCom,TRI;//����ʱ�ӣ���λ������ or ���ݣ� ���ʹ����ź�
input [7:0] DATA;
output SCL,SDA,DC,res,Busy; //slaveʱ�ӣ�slave���ݣ����� or ���ݣ���λ��Ƭѡ���Ƿ�æµ
output reg CS;
reg DC;//����or����
reg SCL_buf; //�ӻ�ʱ��
reg [7:0] Data_buf; //���ݻ�����
reg link_SDA,link_SCL; //�����Ƿ����ӵ���Ӧ�Ĵ�����
reg [3:0] main_state; //��״̬�Ĵ���

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
assign SCL = link_SCL ? SCL_buf : 1'b0; //ʱ���Ƿ�����
assign SDA = link_SDA ? Data_buf[7] : 1'bz;//�����Ƿ�����
//assign CS = 1'b0; //һ��slave������Ϊ0

assign Busy = ((main_state != Ready) &&  (CS == 1'b0)) ? 1'b1 : 1'b0; //��ʼ����ʱbusy�øߣ�׼����������0

reg [4:0] count;
//spi���Ƶ��Ϊ5Mhz������ʱ����100Mhz
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


//������λ
always @(negedge SCL_buf) begin
    if(TRI == 1)
        Data_buf <= DATA;//��ʼ��
    if(main_state == Ready && TRI)
        Data_buf <= DATA;//��������ݵĻ�
    else if(main_state == End)
        Data_buf[7] <= 1'bz;
    else if(main_state != Ready && main_state != Shift_7bit) //Shift_7bit������ready2
        Data_buf <= Data_buf << 1;
    else
        Data_buf <= Data_buf;
end     

//״̬ת��
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
                    if(TRI) //��TRIΪ1ʱ����
                        begin 
                            link_SCL <= 1;
                            link_SDA <= 1; //SDA�����ӵ����ݼĴ���
                            main_state <= Shift_7bit; 
                            if(DaCom) 
                                DC <= 1; //ѡ�������ݻ�����
                            else 
                                DC <= 0; 
                        end
              
                Shift_7bit:
                    main_state <= Shift_6bit; 
                    //����2
                    
                Shift_6bit:
                    main_state <= Shift_5bit; //׼��������һλ

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
                       link_SCL <= 0; //�Ͽ�ʱ����
                       link_SDA <= 0; //�Ͽ�����
                       main_state <= Ready; 
                       DC <= 0; 
                    end
            endcase
        end
          
endmodule