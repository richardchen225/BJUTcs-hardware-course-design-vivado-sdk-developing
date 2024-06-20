module dvp_bram(
    input                 rst_n           ,  
    input                 capture_en      ,  //开始捕捉画面使能（由sccb_cfg_done提供）
    // 摄像头输入
    input                 cam_pclk        ,  //cmos 数据像素时钟
    input                 cam_vsync       ,  //cmos 场同步信号
    input                 cam_href        ,  //cmos 行同步信号
    input        [7:0]    cam_data        ,  //cmos 数据   
    // 拍摄按键
    input                 button          ,   
    input                 clk_100         ,                      
    // 输入到bram
    output     reg [31:0] addrb           ,
    output     reg [31:0] dinb            ,
    output     reg [3:0]  web             ,
    output     reg        rstb            ,
    output     reg        enb             ,
    // 同步ps端
    input                 ps_read         ,
    output     reg        ps_cnt   
);

// ps端同步
always@(posedge clk_100 or negedge rst_n) begin
    if(!rst_n)
        ps_cnt<=0;
    else if(cap_frame==1'b1)
        ps_cnt<=1;
    else if(ps_read==1'b1)
        ps_cnt<=0;
end

// 检测按键信号
reg    bu_cnt;    //按键状态寄存器
reg    bu;        //按键是否按下（按键不按为1，按下为0）
reg    cap_frame; //开始采集一帧图像标志
always@(posedge clk_100 or negedge rst_n) begin
    if(!rst_n)
        bu_cnt<=1;
    else 
        bu_cnt<=button;
end
always@(*) begin
    if(!rst_n)
        bu=0;
    else
        bu=(~(bu_cnt & button ) )? 1'b1: 1'b0;
end
always@(posedge clk_100 or negedge rst_n) begin
    if(!rst_n)
        cap_frame<=0;
    else if(bu==1'b1 && cap_frame==1'b0)
        cap_frame<=1'b1;
    else if(frame_flag==1'b1)
        cap_frame<=1'b0;
end
    
//寄存器全部配置完成后，先等待10帧数据
//待寄存器配置生效后再开始采集图像
parameter      WAIT_FRAME = 4'd10   ;    //寄存器数据稳定等待的帧个数   
wire            cmos_frame_valid    ;    //数据有效使能信号
wire   [15:0]   cmos_frame_data     ;    //有效数据             
wire            cmos_wr_req         ;    //采样vsync信号的下降沿
wire            pos_vsync           ;    //采样vsync信号的上升沿
reg             cam_vsync_d0        ;
reg             cam_vsync_d1        ;
reg             cam_href_d0         ;
reg             cam_href_d1         ;
reg    [3:0]    cmos_ps_cnt         ;    //等待帧数稳定计数器
reg             frame_val_flag      ;    //帧有效的标志
reg    [7:0]    cam_data_d0         ;             
reg    [15:0]   cmos_data_t         ;    //用于8位转16位的临时寄存器
reg             byte_flag           ;             
reg             byte_flag_d0        ;

// bram
reg [31:0] cnt;
reg [15:0] frame_reg;
reg frame_flag;
always@(posedge cap_frame or negedge cmos_frame_valid or negedge rst_n)begin
    if(!rst_n)begin
        web[3:0]          <=  4'd0;
        addrb[31:0]       <= 32'd0;
        dinb[31:0]        <= 32'd0;
        cnt<=0;
        enb<=0;
        rstb<=1'b1;
        frame_flag<=1'b0;
    end 
    else if(!cap_frame) begin
        web[3:0]          <=  4'd0;
        addrb[31:0]       <= 32'd0;
        dinb[31:0]        <= 32'd0;
        cnt<=0;
        enb<=0;
        rstb<=1'b1;
        frame_flag<=1'b0;
    end 
    else 
        if(cnt<'d1 && frame_val_flag==1'b1) begin
            cnt<='d1;
            frame_reg<=cmos_frame_data;
            enb<=1'b1;
            rstb<=1'b0;
        end
        else if(frame_val_flag==1'b1 && addrb<=32'h0007_ffff)begin
            cnt<=0;
            rstb<=1'b0;
            enb<=1'b1;
            web[3:0]          <= 4'b1111;
            addrb[31:0]       <= addrb[31:0] + 32'd4;
            dinb[31:0]        <= {frame_reg,cmos_frame_data};
        end
        else if(frame_val_flag==1'b1 &&addrb>=32'h0007_ffff)
            frame_flag<=1'b1;
end

//采样vsync信号的上升沿
assign pos_vsync = (~cam_vsync_d1) & cam_vsync_d0;  
//采样vsync信号的下降沿
assign cmos_wr_req = cam_vsync_d1 & (~cam_vsync_d0); 

//输出数据使能有效信号
assign  cmos_frame_valid = (frame_val_flag&capture_en)  ?  byte_flag_d0  :  1'b0; 
//输出数据
assign  cmos_frame_data  = (frame_val_flag&capture_en)  ?  cmos_data_t   :  1'b0; 

//采样vsync信号的上升沿和下降沿
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cam_vsync_d0 <= 1'b0;
        cam_vsync_d1 <= 1'b0;
        cam_href_d0 <= 1'b0;
        cam_href_d1 <= 1'b0;
    end
    else if(!cap_frame) begin
        cam_vsync_d0 <= 1'b0;
        cam_vsync_d1 <= 1'b0;
        cam_href_d0 <= 1'b0;
        cam_href_d1 <= 1'b0;
    end
    else begin
        cam_vsync_d0 <= cam_vsync;
        cam_vsync_d1 <= cam_vsync_d0;
        cam_href_d0 <= cam_href;
        cam_href_d1 <= cam_href_d0;
    end
end

//对帧数进行计数
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        cmos_ps_cnt <= 4'd0;
    else if(!cap_frame)
        cmos_ps_cnt <= 4'd0;
    else if(pos_vsync && (cmos_ps_cnt < WAIT_FRAME))
        cmos_ps_cnt <= cmos_ps_cnt + 4'd1;
end

//帧有效标志
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        frame_val_flag <= 1'b0;
    else if(!cap_frame)
        frame_val_flag <= 1'b0;
    else if((cmos_ps_cnt == WAIT_FRAME) && pos_vsync &&capture_en)
        frame_val_flag <= 1'b1;
  
end            

//8位数据转16位RGB565数据        
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cmos_data_t <= 16'd0;
        cam_data_d0 <= 8'd0;
        byte_flag <= 1'b0;
    end
    else if(!cap_frame) begin
        cmos_data_t <= 16'd0;
        cam_data_d0 <= 8'd0;
        byte_flag <= 1'b0;
    end        
    else if(cam_href) begin
        byte_flag <= ~byte_flag;
        cam_data_d0 <= cam_data;
        if(byte_flag)
            cmos_data_t <= {cam_data_d0,cam_data};
        else;   
    end
    else begin
        byte_flag <= 1'b0;
        cam_data_d0 <= 8'b0;
    end    
end        

//产生输出数据有效信号(cmos_frame_valid)
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        byte_flag_d0 <= 1'b0;
    else if(!cap_frame)
        byte_flag_d0 <= 1'b0;
    else
        byte_flag_d0 <= byte_flag;    
end          

endmodule 