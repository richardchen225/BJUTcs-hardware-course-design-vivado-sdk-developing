set_property SRC_FILE_INFO {cfile:c:/Users/chenr/Desktop/robot_ps/robot_ps.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0/design_1_processing_system7_0_0.xdc rfile:../../../robot_ps.srcs/sources_1/bd/design_1/ip/design_1_processing_system7_0_0/design_1_processing_system7_0_0.xdc id:1 order:EARLY scoped_inst:design_1_i/processing_system7_0/inst} [current_design]
set_property SRC_FILE_INFO {cfile:c:/Users/chenr/Desktop/robot_ps/robot_ps.srcs/sources_1/bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0.xdc rfile:../../../robot_ps.srcs/sources_1/bd/design_1/ip/design_1_clk_wiz_0_0/design_1_clk_wiz_0_0.xdc id:2 order:EARLY scoped_inst:design_1_i/clk_wiz_0/inst} [current_design]
set_property SRC_FILE_INFO {cfile:C:/Users/chenr/Desktop/robot_ps/robot_ps.srcs/constrs_1/new/cons.xdc rfile:../../../robot_ps.srcs/constrs_1/new/cons.xdc id:3} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:21 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter clk_fpga_0 0.3
set_property src_info {type:SCOPED_XDC file:2 line:56 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter [get_clocks -of_objects [get_ports clk_in1]] 0.1
set_property src_info {type:XDC file:3 line:1 export:INPUT save:INPUT read:READ} [current_design]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets cam_pclk_IBUF]
