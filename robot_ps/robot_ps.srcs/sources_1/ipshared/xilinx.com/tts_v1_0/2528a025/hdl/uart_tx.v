`timescale 1ns / 1ps

module uart_tx
#(
    parameter integer CLK_FRE     = 100,  
    parameter integer BAUD_RATE   = 9600,  
    parameter integer STOP_BITS   = 1     
)
(
    input  wire                   clk,           
    input  wire                   rstn,         
    input  wire [7 : 0]           tx_data,     
    input  wire                   tx_data_valid, 
    output wire                   uart_tx_ready, 
    output wire                   uart_tx_on,    
    output reg                    uart_tx      
);
   
localparam STATE_IDLE    = 3'b000;                        //空闲状态
localparam STATE_START   = 3'b001;                        //开始状态
localparam STATE_DATA    = 3'b010;                        //数据发送状态
localparam STATE_STOP    = 3'b011;                        //结束状态       
localparam integer CYCLE = CLK_FRE * 1000000 / BAUD_RATE; //波特计数周期 传输一位数据所需要的时钟个数
//
reg               [2:0] current_state;
reg               [2:0] next_state;
reg [100 : 0] baud_cnt;       // 波特率计数器 
reg               [3:0] data_bit_cnt;   // count for tranmitting data bits
reg   [7 : 0] tx_data_buffer;
wire                    baud_valid;     // 波特计数有效位
           
assign uart_tx_ready = (current_state == STATE_IDLE);  //UART is ready when in STATE_IDLE
assign baud_valid    = (current_state != STATE_IDLE);
assign uart_tx_on    = baud_valid;

// counter of baud rate
always @ (posedge clk)
begin
  if(!rstn) begin
    baud_cnt <= 0;
  end
  else begin
    if(!baud_valid) begin
        baud_cnt <= 0;
    end
    else if(baud_cnt == CYCLE - 1) begin
        baud_cnt <= 0;
    end
    else begin
        baud_cnt <= baud_cnt + 1;
	end
  end	
end         
          
          
//状态机状态变化定义
always @ (posedge clk) begin
    if(!rstn)
        current_state <= STATE_IDLE;
    else begin
      if(tx_data_valid && uart_tx_ready) begin
        current_state <= next_state;
      end
      else if(baud_valid && (baud_cnt == CYCLE - 1)) begin
        current_state <= next_state;
      end
    end
end

always @ (*) begin
  case(current_state)
    STATE_IDLE:
      next_state = STATE_START;
    STATE_START:
      next_state = STATE_DATA;
    STATE_DATA:
      if(data_bit_cnt == 7) begin
          next_state = STATE_STOP;
      end
      else begin
        next_state = STATE_DATA;
      end
    STATE_STOP:
      if(!rstn) begin
        next_state = STATE_IDLE;
	    end
      else begin
        next_state = STATE_STOP;
      end      
    default: ;
  endcase
end

always @ (posedge clk) begin
  if(!rstn) begin
    tx_data_buffer <= 'd0;
    uart_tx <= 1'b1;
    data_bit_cnt <= 4'd0;
  end
  else begin
    case(current_state)
      STATE_IDLE: begin
        uart_tx <= 1'b1;
        data_bit_cnt <= 4'd0;
        if(tx_data_valid && uart_tx_ready) begin
          tx_data_buffer <= tx_data;
        end
      end
      STATE_START: begin
        uart_tx <= 1'b0;
		  end
      STATE_DATA: begin
        uart_tx <= tx_data_buffer[data_bit_cnt];
        if(baud_cnt == CYCLE - 1) begin
          data_bit_cnt <= data_bit_cnt + 1;
        end
      end
      STATE_STOP: begin
        uart_tx <= 1'b1;
      end
      default: ;
    endcase
  end
end

endmodule