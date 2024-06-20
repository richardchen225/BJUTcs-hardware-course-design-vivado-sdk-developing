//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.2 (win64) Build 1266856 Fri Jun 26 16:35:25 MDT 2015
//Date        : Thu Jun 13 23:01:52 2024
//Host        : RichardChen running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (CS,
    DC,
    DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    SCL,
    SDA,
    button,
    cam_data,
    cam_href,
    cam_pclk,
    cam_vsync,
    clk_in1,
    ov5640_pwdn,
    ov5640_rst_n,
    pump,
    pwm_s1,
    pwm_s2,
    pwm_s3,
    res,
    sio_c,
    sio_d,
    uart_tx);
  output CS;
  output DC;
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output SCL;
  output SDA;
  input button;
  input [7:0]cam_data;
  input cam_href;
  input cam_pclk;
  input cam_vsync;
  input clk_in1;
  output ov5640_pwdn;
  output ov5640_rst_n;
  output pump;
  output pwm_s1;
  output pwm_s2;
  output pwm_s3;
  output res;
  output sio_c;
  output sio_d;
  output uart_tx;

  wire CS;
  wire DC;
  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire SCL;
  wire SDA;
  wire button;
  wire [7:0]cam_data;
  wire cam_href;
  wire cam_pclk;
  wire cam_vsync;
  wire clk_in1;
  wire ov5640_pwdn;
  wire ov5640_rst_n;
  wire pump;
  wire pwm_s1;
  wire pwm_s2;
  wire pwm_s3;
  wire res;
  wire sio_c;
  wire sio_d;
  wire uart_tx;

  design_1 design_1_i
       (.CS(CS),
        .DC(DC),
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .SCL(SCL),
        .SDA(SDA),
        .button(button),
        .cam_data(cam_data),
        .cam_href(cam_href),
        .cam_pclk(cam_pclk),
        .cam_vsync(cam_vsync),
        .clk_in1(clk_in1),
        .ov5640_pwdn(ov5640_pwdn),
        .ov5640_rst_n(ov5640_rst_n),
        .pump(pump),
        .pwm_s1(pwm_s1),
        .pwm_s2(pwm_s2),
        .pwm_s3(pwm_s3),
        .res(res),
        .sio_c(sio_c),
        .sio_d(sio_d),
        .uart_tx(uart_tx));
endmodule
