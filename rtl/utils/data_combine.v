module data_combine #(
    parameter DN=6, DW=21, MWH=18,MWL=4
) (
    input  [DN*MWH-1 : 0] m_data_h,
    input  [DN*MWL-1 : 0] m_data_l,

    output [DN*DW-1  : 0] s_data
);

genvar i;
generate
    for (i=0;i<DN;i=i+1) begin:combine_data
       
        assign s_data[i*DW +: DW] = {m_data_h[i*MWH +: (MWH-1)],m_data_l[i*MWL +: MWL]};

    end
endgenerate
    
endmodule
