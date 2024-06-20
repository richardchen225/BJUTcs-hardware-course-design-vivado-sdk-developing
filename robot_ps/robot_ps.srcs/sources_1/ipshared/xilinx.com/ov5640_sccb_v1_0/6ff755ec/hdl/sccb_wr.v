`timescale 1ns / 1ps
module SCCB_WR // ��ģ������Ϊ��Ƶ��+����д״̬��
#(
    parameter   CLK_FREQ   		= 	26'd50_000_000, 	//ģ�������ʱ��Ƶ��
    parameter   SCCB_FREQ   	    = 	18'd250_000     	//SCL��ʱ��Ƶ��
)
(
	input	wire				clk 						,	//ϵͳʱ��
	input	wire				rst_n 						,	//��λ�ź�
	input	wire				sccb_exec 					,	//sccbЭ�鴫�俪ʼ�����ź���cfg��sccb_en��Ϊ���룩
	input	wire	[15:0]		sccb_addr 					,	//�Ĵ�����ַ ����ַ��cfg����
	input	wire	[ 7:0]		sccb_data_wr 				,	//д���� �����ݴ�cfg����
	input	wire	[ 6:0]		SLAVE_ADDR 					,	//�ӻ���ַ �������ַ�ǹ̶���Ϊ7'h78��

    output  reg					sccb_clk 					, 	//sccbģ��Ĺ���ʱ��
	output	reg 				sccb_done_wr 			    ,	//sccbЭ�鴫����ɣ������cfg��sccb_done��
	output	reg	 				sio_c 						,	//sccbЭ�鴫��ʱ�� �����ӵ�ov5640��
	output	wire 				sio_d 							//sccbЭ�������� �����ӵ�ov5640��
);

// ����״̬��������д�е�״̬����ת��
parameter	st_idle			=		6'b00_0001			;	//��ʼ״̬
parameter	st_addr_wr		=		6'b00_0010 			;	//�豸��ַд
parameter	st_addr_16		=		6'b00_0100 			;	//�Ĵ�����ַ�߰�λд��
parameter	st_addr_8 		=		6'b00_1000 			;	//�Ĵ�����ַ�Ͱ�λд��
parameter 	st_data_wr		=		6'b01_0000			;	//д���ݴ���
parameter	st_stop			=		6'b10_0000 			;	//һ��ͨѶ����

parameter CLK_DIVIDE_MAX = (CLK_FREQ / SCCB_FREQ) >> (1'b1 + 2'd2) - 1'b1;	//(SCCBЭ����ķ�Ƶ�������ֵ)

reg		[ 5:0]		cur_state								;	//״̬����ǰ״̬
reg		[ 5:0]		next_state								;	//״̬����һ״̬
reg					st_done									;	//״̬��ɣ����ݷ�����ɣ�
reg		[ 23:0]		clk_divide								;	//ģ������ʱ�ӵķ�Ƶϵ������Ƶ����������
reg 	[ 7:0]		cnt 									; 	//sccb_clk ����
reg 				bit_ctrl 							    ;	//��ַλ���ƼĴ�
reg 	[ 7:0]		sccb_data_wr_reg 						;	//д���ݼĴ� ����ʱ���·����ΪԴ���ݽ���д�룩
reg 	[15:0]		sccb_addr_reg 							;	//�Ĵ�����ַ�Ĵ�
reg 	[ 7:0]		SLAVE_ADDR_reg 							;	//�ӻ��豸��ַ�Ĵ�

reg 				sio_d_dir 								;	//sio����������� �������������
reg					sio_d_out								;	//sio_d����ź�

assign sio_d = (sio_d_dir == 1'b1) ? sio_d_out : 'dz;

//ģ������ʱ�Ӽ�����
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

//ģ������ʱ��
always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		sccb_clk <= 1'b0;
	end
	else if(clk_divide == CLK_DIVIDE_MAX) begin
		sccb_clk <= ~sccb_clk;
	end
end

//����ʽ״̬����ͬ��ʱ������״̬ת��
always @(posedge sccb_clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		cur_state <= st_idle;
	end
	else begin
		cur_state <= next_state;
	end
end

//����߼��ж�״̬ת������
always @(*) begin
	next_state = st_idle;
	case(cur_state)
		st_idle		:	begin 			//��ʼ״̬�������俪ʼʱ״̬��ת
			if(sccb_exec == 1'b1)begin
				next_state = st_addr_wr;
			end
			else begin
				next_state = st_idle;
			end
		end
		st_addr_wr	:	begin 				//�����豸��ַ�Ӷ�
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
		st_addr_16	:	begin 				//���ͼĴ�����ַ�߰�λ
			if(st_done == 1'b1)begin
				next_state = st_addr_8;
			end
			else begin
				next_state = st_addr_16;
			end
		end
		st_addr_8 	:	begin 				//���ͼĴ�����ַ�Ͱ�λ
			if(st_done == 1'b1)begin
					next_state = st_data_wr;
			end
			else begin
				next_state = st_addr_8; 		//δ��ɣ�����
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

//ʱ���·����״̬���
always @(posedge sccb_clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		cnt 				<= 	'd0 			;	//����Ĵ���
		st_done 			<=	'd0 			;	//������ɱ�־λ
		sio_c 				<= 	'd1				;	//sioʱ����
		sio_d_out 			<= 	'd1 			; 	//sio_d���
		sio_d_dir 			<=	'd1 			;	//sio_d��������ж�
		bit_ctrl       		<=	'd1 		    ; 	//�Ĵ�����ַλ�Ĵ�
		sccb_addr_reg 		<= 	sccb_addr 		; 	//�Ĵ�����ַ�Ĵ�
		sccb_data_wr_reg 	<=	sccb_data_wr 	;	//д���ݼĴ�
		SLAVE_ADDR_reg 		<=  SLAVE_ADDR 		; 	//�ӻ���ַ�Ĵ�
	end
	else  begin
		st_done <= 1'b0;
		cnt <=	cnt + 1'b1;
		case(cur_state)
		st_idle 	:	begin
			cnt 				<= 	'd0 			;	//����Ĵ���
			st_done 			<=	'd0 			;	//������ɱ�־λ
			sio_c 				<= 	'd1				;	//sioʱ����,Ĭ�ϸߵ�ƽ
			sio_d_out 			<= 	'd1 			; 	//sio_d�����Ĭ�ϸߵ�ƽ
			sio_d_dir 			<=	'd1 			;	//sio_d��������ж�
			sccb_done_wr		<=	'd0             ;
			bit_ctrl     		<=	'd1 		    ; 	//�Ĵ�����ַλ�Ĵ�
			sccb_addr_reg 		<= 	sccb_addr 		; 	//�Ĵ�����ַ�Ĵ�
			sccb_data_wr_reg 	<=	sccb_data_wr 	;	//д���ݼĴ�
			SLAVE_ADDR_reg 		<=  SLAVE_ADDR 		; 	//�ӻ���ַ�Ĵ�				
		end
		st_addr_wr 	:	begin 							//������ʼ�ź��豸��ַ��д��־
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
				38: begin 					//sccb��Ӧ���־λ���ں�
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
