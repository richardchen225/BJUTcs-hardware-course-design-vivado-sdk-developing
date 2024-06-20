`timescale 1ns / 1ps
module	power_ctrl(
	input	wire			clk						,	
	input	wire			rst_n 					,	
	output	wire			ov5640_pwdn				,	//ov5640��pwdn�ź��ߣ���ʼΪ�ߣ�6ms������			
	output	wire			ov5640_rst_n            ,   //ov5640��rst_n��λ�ź��ߣ��͵�ƽ��Ч
	output	wire			power_done 					//�ϵ���ɱ�־λ����ɺ�һֱΪ��
);
localparam	DELAY_6MS		=		30_0000			;
localparam	DELAY_2MS		=		10_0000			;
localparam	DELAY_21MS		=		105_0000		;

reg		[18:0]		cnt_6ms							;
reg		[16:0]		cnt_2ms							;
reg		[20:0]		cnt_21ms						;

always @(posedge clk) begin
	if (rst_n == 1'b0) begin
		cnt_6ms <= 'd0;
	end
	else if (ov5640_pwdn == 1'b1) begin
		cnt_6ms <= cnt_6ms + 1'b1;
	end
end

always @(posedge clk) begin
	if (rst_n == 1'b0) begin
		cnt_2ms <= 'd0;
	end
	else if (ov5640_rst_n == 1'b0 && ov5640_pwdn == 1'b0) begin
		cnt_2ms <= cnt_2ms + 1'b1;
	end
end

always @(posedge clk) begin
	if (rst_n == 1'b0) begin
		cnt_21ms <= 'd0;
	end
	else if (ov5640_rst_n == 1'b1 & power_done == 1'b0) begin
		cnt_21ms <= cnt_21ms + 1'b1;
	end
end

assign ov5640_pwdn = (cnt_6ms >= DELAY_6MS) ? 1'b0 : 1'b1;		//��ʼΪ�ߣ�6ms���õ�
assign ov5640_rst_n = (cnt_2ms >= DELAY_2MS) ? 1'b1 : 1'b0; 	//��ʼΪ�ͣ�pwdn���ͺ�2ms�ø�
assign power_done = (cnt_21ms >= DELAY_21MS) ? 1'b1 : 1'b0;		//��ʼΪ�ͣ��ϵ���ɺ��ø�

endmodule
