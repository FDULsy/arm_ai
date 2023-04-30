module mac #(parameter DW=64,WW=48
) (
    input [DW-1:0]   mac_m_data,
    input            mac_m_valid,
    output           mac_m_ready,
    input [WW-1:0]   weights,
    input [WW/8-1:0] weights_en,
    input [WW-1:0]   bias,

    
);
 


 
endmodule