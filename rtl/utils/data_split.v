module data_split #(
    parameter DN=6,DW = 21,MWH=18,MWL=4
) (
    input  [DN*DW-1 : 0]   m_data,

    output [DN*MWH-1 : 0]  s_data_h,
    output [DN*MWL-1 : 0]  s_data_l
);

wire [DW : 0] m_datan [DN-1:0];

genvar i;
generate
    for (i=0;i<DN;i=i+1) begin:split_data
        assign m_datan[i] = {m_data[(i+1)*DW-1],m_data[i*DW +: Dw]};
        assign s_data_h[i*MWH +: MWH] = m_datan[i][MWL +: MWH];
        assign s_data_l[i*MWL +: MWL] = m_datan[i][0   +: MWL];
    end
endgenerate

endmodule
