module dvp_bram(
    input                 rst_n           ,  
    input                 capture_en      ,  //��ʼ��׽����ʹ�ܣ���sccb_cfg_done�ṩ��
    // ����ͷ����
    input                 cam_pclk        ,  //cmos ��������ʱ��
    input                 cam_vsync       ,  //cmos ��ͬ���ź�
    input                 cam_href        ,  //cmos ��ͬ���ź�
    input        [7:0]    cam_data        ,  //cmos ����   
    // ���㰴��
    input                 button          ,   
    input                 clk_100         ,                      
    // ���뵽bram
    output     reg [31:0] addrb           ,
    output     reg [31:0] dinb            ,
    output     reg [3:0]  web             ,
    output     reg        rstb            ,
    output     reg        enb             ,
    // ͬ��ps��
    input                 ps_read         ,
    output     reg        ps_cnt   
);

// ps��ͬ��
always@(posedge clk_100 or negedge rst_n) begin
    if(!rst_n)
        ps_cnt<=0;
    else if(cap_frame==1'b1)
        ps_cnt<=1;
    else if(ps_read==1'b1)
        ps_cnt<=0;
end

// ��ⰴ���ź�
reg    bu_cnt;    //����״̬�Ĵ���
reg    bu;        //�����Ƿ��£���������Ϊ1������Ϊ0��
reg    cap_frame; //��ʼ�ɼ�һ֡ͼ���־
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
    
//�Ĵ���ȫ��������ɺ��ȵȴ�10֡����
//���Ĵ���������Ч���ٿ�ʼ�ɼ�ͼ��
parameter      WAIT_FRAME = 4'd10   ;    //�Ĵ��������ȶ��ȴ���֡����   
wire            cmos_frame_valid    ;    //������Чʹ���ź�
wire   [15:0]   cmos_frame_data     ;    //��Ч����             
wire            cmos_wr_req         ;    //����vsync�źŵ��½���
wire            pos_vsync           ;    //����vsync�źŵ�������
reg             cam_vsync_d0        ;
reg             cam_vsync_d1        ;
reg             cam_href_d0         ;
reg             cam_href_d1         ;
reg    [3:0]    cmos_ps_cnt         ;    //�ȴ�֡���ȶ�������
reg             frame_val_flag      ;    //֡��Ч�ı�־
reg    [7:0]    cam_data_d0         ;             
reg    [15:0]   cmos_data_t         ;    //����8λת16λ����ʱ�Ĵ���
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

//����vsync�źŵ�������
assign pos_vsync = (~cam_vsync_d1) & cam_vsync_d0;  
//����vsync�źŵ��½���
assign cmos_wr_req = cam_vsync_d1 & (~cam_vsync_d0); 

//�������ʹ����Ч�ź�
assign  cmos_frame_valid = (frame_val_flag&capture_en)  ?  byte_flag_d0  :  1'b0; 
//�������
assign  cmos_frame_data  = (frame_val_flag&capture_en)  ?  cmos_data_t   :  1'b0; 

//����vsync�źŵ������غ��½���
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

//��֡�����м���
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        cmos_ps_cnt <= 4'd0;
    else if(!cap_frame)
        cmos_ps_cnt <= 4'd0;
    else if(pos_vsync && (cmos_ps_cnt < WAIT_FRAME))
        cmos_ps_cnt <= cmos_ps_cnt + 4'd1;
end

//֡��Ч��־
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        frame_val_flag <= 1'b0;
    else if(!cap_frame)
        frame_val_flag <= 1'b0;
    else if((cmos_ps_cnt == WAIT_FRAME) && pos_vsync &&capture_en)
        frame_val_flag <= 1'b1;
  
end            

//8λ����ת16λRGB565����        
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

//�������������Ч�ź�(cmos_frame_valid)
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        byte_flag_d0 <= 1'b0;
    else if(!cap_frame)
        byte_flag_d0 <= 1'b0;
    else
        byte_flag_d0 <= byte_flag;    
end          

endmodule 