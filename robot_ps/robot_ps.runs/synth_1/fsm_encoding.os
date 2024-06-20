
 add_fsm_encoding \
       {OLED.main_state} \
       { }  \
       {{0000 0000} {0001 0001} {0010 0010} {0011 0011} {0100 0100} {0101 0101} {0110 0110} {0111 0111} {1000 1000} {1001 1001} }

 add_fsm_encoding \
       {Robotarm.state} \
       { }  \
       {{0000 0000} {0001 0001} {0010 0010} {0011 0011} {0100 0100} {0101 0101} {0110 0110} {0111 0111} {1000 1000} {1001 1001} }

 add_fsm_encoding \
       {rd_chnl.rlast_sm_cs} \
       { }  \
       {{000 000} {001 010} {010 011} {011 100} {100 001} }

 add_fsm_encoding \
       {axi_data_fifo_v2_1_axic_reg_srl_fifo.state} \
       { }  \
       {{00 0100} {01 1000} {10 0001} {11 0010} }

 add_fsm_encoding \
       {uart_tx.current_state} \
       { }  \
       {{000 00} {001 01} {010 10} {011 11} }

 add_fsm_encoding \
       {uart_tx.next_state} \
       { }  \
       {{000 00} {001 01} {010 10} {011 11} }
