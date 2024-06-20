`timescale 1ns / 1ps
module SCCB_WR // 此模块整体为分频器+三相写状态机
#(
    parameter   CLK_FREQ   		= 	26'd50_000_000, 	//模块输入的时钟频率
    parameter   SCCB_FREQ   	    = 	18'd250_000     	//SCL的时钟频率
)
(
	input	wire				clk 						,	//系统时钟
	input	wire				rst_n 						,	//复位信号
	input	wire				sccb_exec 					,	//sccb协议传输开始（此信号由cfg的sccb_en作为输入）
	input	wire	[15:0]		sccb_addr 					,	//寄存器地址 （地址从cfg来）
	input	wire	[ 7:0]		sccb_data_wr 				,	//写数据 （数据从cfg来）
	input	wire	[ 6:0]		SLAVE_ADDR 					,	//从机地址 （这个地址是固定的为7'h78）

    output  reg					sccb_clk 					, 	//sccb模块的工作时钟
	output	reg 				sccb_done_wr 			    ,	//sccb协议传输完成（输出到cfg的sccb_done）
	output	reg	 				sio_c 						,	//sccb协议传输时钟 （连接到ov5640）
	output	wire 				sio_d 							//sccb协议数据线 （连接到ov5640）
);

// 下列状态按照三相写中的状态进行转换
parameter	st_idle			=		6'b00_0001			;	//初始状态
parameter	st_addr_wr		=		6'b00_0010 			;	//设备地址写
parameter	st_addr_16		=		6'b00_0100 			;	//寄存器地址高八位写入
parameter	st_addr_8 		=		6'b00_1000 			;	//寄存器地址低八位写入
parameter 	st_data_wr		=		6'b01_0000			;	//写数据传输
parameter	st_stop			=		6'b10_0000 			;	//一次通讯结束

parameter CLK_DIVIDE_MAX = (CLK_FREQ / SCCB_FREQ) >> (1'b1 + 2'd2) - 1'b1;	//(SCCB协议的四分频计数最大值)

reg		[ 5:0]		cur_state								;	//状态机当前状态
reg		[ 5:0]		next_state								;	//状态机下一状态
reg					st_done									;	//状态完成（数据发送完成）
reg		[ 23:0]		clk_divide								;	//模块驱动时钟的分频系数（分频器计数器）
reg 	[ 7:0]		cnt 									; 	//sccb_clk 计数
reg 				bit_ctrl 							    ;	//地址位控制寄存
reg 	[ 7:0]		sccb_data_wr_reg 						;	//写数据寄存 （在时序电路中作为源数据进行写入）
reg 	[15:0]		sccb_addr_reg 							;	//寄存器地址寄存
reg 	[ 7:0]		SLAVE_ADDR_reg 							;	//从机设备地址寄存

reg 				sio_d_dir 								;	//sio输入输出控制 高输出，低输入
reg					sio_d_out								;	//sio_d输出信号

assign sio_d = (sio_d_dir == 1'b1) ? sio_d_out : 'dz;

//模块驱动时钟计数器
always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		clk_divide <= 'd0;
	end
	else if (clk_divide == CLK_DIVIDE_MAX) begin
		clk_divide <= 'd0;
	end
	else begin
		clk_divide <= clk_divide + 1'b1;
	end
end

//模块驱动时钟
always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		sccb_clk <= 1'b0;
	end
	else if(clk_divide == CLK_DIVIDE_MAX) begin
		sccb_clk <= ~sccb_clk;
	end
end

//三段式状态机，同步时序描述状态转移
always @(posedge sccb_clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		cur_state <= st_idle;
	end
	else begin
		cur_state <= next_state;
	end
end

//组合逻辑判断状态转移条件
always @(*) begin
	next_state = st_idle;
	case(cur_state)
		st_idle		:	begin 			//初始状态，当传输开始时状态跳转
			if(sccb_exec == 1'b1)begin
				next_state = st_addr_wr;
			end
			else begin
				next_state = st_idle;
			end
		end
		st_addr_wr	:	begin 				//发送设备地址加读
			if(st_done == 1'b1)begin
				if (bit_ctrl == 1'b1)begin
					next_state = st_addr_16;
				end
				else begin
					next_state = st_addr_8;
				end
			end
			else begin
				next_state = st_addr_wr;
			end
		end
		st_addr_16	:	begin 				//发送寄存器地址高八位
			if(st_done == 1'b1)begin
				next_state = st_addr_8;
			end
			else begin
				next_state = st_addr_16;
			end
		end
		st_addr_8 	:	begin 				//发送寄存器地址低八位
			if(st_done == 1'b1)begin
					next_state = st_data_wr;
			end
			else begin
				next_state = st_addr_8; 		//未完成，保持
			end
		end
		st_data_wr 	:	begin
			if(st_done == 1'b1)begin
				next_state = st_stop;
			end
			else begin
				next_state = st_data_wr;
			end
		end
		st_stop 	:	begin
			if(st_done == 1'b1)begin
				next_state = st_idle;
			end
			else begin
				next_state = st_stop;
			end
		end
		default 	:	next_state = st_idle;
	endcase
end

//时序电路描述状态输出
always @(posedge sccb_clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		cnt 				<= 	'd0 			;	//传输寄存器
		st_done 			<=	'd0 			;	//传输完成标志位
		sio_c 				<= 	'd1				;	//sio时钟线
		sio_d_out 			<= 	'd1 			; 	//sio_d输出
		sio_d_dir 			<=	'd1 			;	//sio_d输入输出判断
		bit_ctrl       		<=	'd1 		    ; 	//寄存器地址位寄存
		sccb_addr_reg 		<= 	sccb_addr 		; 	//寄存器地址寄存
		sccb_data_wr_reg 	<=	sccb_data_wr 	;	//写数据寄存
		SLAVE_ADDR_reg 		<=  SLAVE_ADDR 		; 	//从机地址寄存
	end
	else  begin
		st_done <= 1'b0;
		cnt <=	cnt + 1'b1;
		case(cur_state)
		st_idle 	:	begin
			cnt 				<= 	'd0 			;	//传输寄存器
			st_done 			<=	'd0 			;	//传输完成标志位
			sio_c 				<= 	'd1				;	//sio时钟线,默认高电平
			sio_d_out 			<= 	'd1 			; 	//sio_d输出，默认高电平
			sio_d_dir 			<=	'd1 			;	//sio_d输入输出判断
			sccb_done_wr		<=	'd0             ;
			bit_ctrl     		<=	'd1 		    ; 	//寄存器地址位寄存
			sccb_addr_reg 		<= 	sccb_addr 		; 	//寄存器地址寄存
			sccb_data_wr_reg 	<=	sccb_data_wr 	;	//写数据寄存
			SLAVE_ADDR_reg 		<=  SLAVE_ADDR 		; 	//从机地址寄存				
		end
		st_addr_wr 	:	begin 							//发送起始信号设备地址加写标志
			cnt <= cnt + 1'b1;
				case(cnt)
				1 :	sio_d_out 	<=  1'b0;				
				3 :sio_c 		<=  1'b0; 
				4 :sio_d_out 	<=  SLAVE_ADDR_reg[7];
				5 :sio_c 		<=  1'b1;
				7 :sio_c		<=  1'b0;
				8 :sio_d_out 	<=  SLAVE_ADDR_reg[6];
				9 :sio_c 		<=  1'b1;
				11:sio_c 		<=  1'b0;
				12:sio_d_out	<=  SLAVE_ADDR_reg[5];
				13:sio_c 		<=  1'b1;
				15:sio_c		<=  1'b0;
				16:sio_d_out 	<=  SLAVE_ADDR_reg[4];
				17:sio_c 		<=  1'b1;
				19:sio_c		<=  1'b0;
				20:sio_d_out 	<=  SLAVE_ADDR_reg[3];
				21:sio_c 		<=  1'b1;
				23:sio_c		<=  1'b0;
				24:sio_d_out 	<=  SLAVE_ADDR_reg[2];
				25:sio_c 		<=  1'b1;
				27:sio_c		<=  1'b0;
				28:sio_d_out 	<=  SLAVE_ADDR_reg[1];
				29:sio_c 		<=  1'b1;
				31:sio_c		<=  1'b0;
				32:sio_d_out 	<=  SLAVE_ADDR_reg[0];
				33:sio_c 		<=  1'b1;
				35:sio_c		<=  1'b0;
				36:	begin
					sio_d_dir 	<=  1'b0;
					sio_d_out   <=  1'b1;
				end 
				37:sio_c 		<=  1'b1;
				38: begin 					//sccb的应答标志位不在乎
					st_done <= 1'b1;
				end
				39:	begin 
					sio_c		<=  1'b0;
					cnt 		<= 	'd0;
				end	
				default 	: 	;
				endcase							
		end
		st_addr_16 	:	begin
			cnt <= cnt + 1'b1;
				case(cnt)
				0 :	begin
					sio_d_out 	<=	sccb_addr_reg[15];
					sio_d_dir 	<=  1'b1;
				end					
				1 :sio_c 		<=	1'b1;
				3 :sio_c 	 	<=  1'b0;
				4 :sio_d_out 	<=	sccb_addr_reg[14];
				5 :sio_c 		<=  1'b1;
				7 :sio_c 	 	<=  1'b0;
				8 :sio_d_out 	<=	sccb_addr_reg[13];
				9 :sio_c 		<=	1'b1;
				11:sio_c 	 	<=  1'b0;
				12:sio_d_out 	<=	sccb_addr_reg[12];
				13:sio_c 		<=  1'b1;
				15:sio_c 	 	<=  1'b0;
				16:sio_d_out 	<=	sccb_addr_reg[11];
				17:sio_c 		<=	1'b1;
				19:sio_c 	 	<=  1'b0;
				20:sio_d_out 	<=	sccb_addr_reg[10];
				21:sio_c 		<=  1'b1;
				23:sio_c 	 	<=  1'b0;
				24:sio_d_out 	<=	sccb_addr_reg[9];
				25:sio_c 		<=	1'b1;
				27:sio_c 	 	<=  1'b0;
				28:sio_d_out 	<=	sccb_addr_reg[8];
				29:sio_c 		<=  1'b1;
				31:sio_c 	 	<=  1'b0;
				32:begin
					sio_d_dir <= 1'b0;
					sio_d_out <= 1'b1;
				end
				33:sio_c 		<=	1'b1;
				34:st_done 		<= 	1'b1;
				35:	begin
					sio_c 		<= 	1'b0;
					cnt 		<= 'd0;
					bit_ctrl  <= 1'b0;
				end
										
				default 	: 	;
				endcase							
		end
		st_addr_8 	:	begin
			cnt <= cnt + 1'b1;
				case(cnt)
				0 :	begin
					sio_d_out 	<=	sccb_addr_reg[7];
					sio_d_dir 	<= 	1'b1;
				end 
				1 :sio_c 		<=	1'b1;
				3 :sio_c 	 	<=  1'b0;
				4 :sio_d_out 	<=	sccb_addr_reg[6];
				5 :sio_c 		<=  1'b1;
				7 :sio_c 	 	<=  1'b0;
				8 :sio_d_out 	<=	sccb_addr_reg[5];
				9 :sio_c 		<=	1'b1;
				11:sio_c 	 	<=  1'b0;
				12:sio_d_out 	<=	sccb_addr_reg[4];
				13:sio_c 		<=  1'b1;
				15:sio_c 	 	<=  1'b0;
				16:sio_d_out 	<=	sccb_addr_reg[3];
				17:sio_c 		<=	1'b1;
				19:sio_c 	 	<=  1'b0;
				20:sio_d_out 	<=	sccb_addr_reg[2];
				21:sio_c 		<=  1'b1;
				23:sio_c 	 	<=  1'b0;
				24:sio_d_out 	<=	sccb_addr_reg[1];
				25:sio_c 		<=	1'b1;
				27:sio_c 	 	<=  1'b0;
				28:sio_d_out 	<=	sccb_addr_reg[0];
				29:sio_c 		<=  1'b1;
				31:sio_c 	 	<=  1'b0;
				32:begin
					sio_d_dir <= 1'b0;
					sio_d_out <= 1'b1;
				end
				33:sio_c 		<=	1'b1;
				34:st_done 		<= 	1'b1;
				35:	begin
					sio_c 		<= 	1'b0;
					cnt 		<=  'd0;
					bit_ctrl  <= 1'b1;
				end
										
				default 	: 	;
				endcase							
		end
			st_data_wr 	:	begin
			cnt <= cnt + 1'b1;
				case(cnt)
					0 :begin
						sio_d_out 	<=	sccb_data_wr_reg[7];
						sio_d_dir 	<=  1'b1;
					end 
					1 :sio_c 		<=	1'b1;
					3 :sio_c 	 	<=  1'b0;
					4 :sio_d_out 	<=	sccb_data_wr_reg[6];
					5 :sio_c 		<=  1'b1;
					7 :sio_c 	 	<=  1'b0;
					8 :sio_d_out 	<=	sccb_data_wr_reg[5];
					9 :sio_c 		<=	1'b1;
					11:sio_c 	 	<=  1'b0;
					12:sio_d_out 	<=	sccb_data_wr_reg[4];
					13:sio_c 		<=  1'b1;
					15:sio_c 	 	<=  1'b0;
					16:sio_d_out 	<=	sccb_data_wr_reg[3];
					17:sio_c 		<=	1'b1;
					19:sio_c 	 	<=  1'b0;
					20:sio_d_out 	<=	sccb_data_wr_reg[2];
					21:sio_c 		<=  1'b1;
					23:sio_c 	 	<=  1'b0;
					24:sio_d_out 	<=	sccb_data_wr_reg[1];
					25:sio_c 		<=	1'b1;
					27:sio_c 	 	<=  1'b0;
					28:sio_d_out 	<=	sccb_data_wr_reg[0];
					29:sio_c 		<=  1'b1;
					31:sio_c 	 	<=  1'b0;
					32:begin
						sio_d_dir <= 1'b0;
						sio_d_out <= 1'b1;
					end
					33:sio_c 		<=	1'b1;
					34:st_done 		<= 	1'b1;
					35:	begin
						sio_c 		<= 	1'b0;
						cnt 		<= 	'd0;
					end
											
					default 	: 	;
				endcase							
			end
		st_stop 	:	begin
			cnt 	<=	cnt + 1'b1;
			case(cnt)
				0 :	begin
					sio_d_out 	<= 	1'b0;
					sio_d_dir 	<=	1'b1;
				end
				
				1 :sio_c 		<=	1'b1;
				4 :sio_d_out	<=	1'b1;
				14:	begin
					sccb_done_wr 	<=	1'b1;
					st_done 	<=	1'b1;
				end					
				15: begin	
				cnt 			<=	'd0;
				sccb_done_wr 	<=	1'b0;
				end
				default  :	;
			endcase
		end
		endcase
	end
end
endmodule
