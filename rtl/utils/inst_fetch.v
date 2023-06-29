module inst_fetch #(parameter IW=36,
                              AW=10
) (
    output [IW-1:0] instgen_s_data,
    output instgen_s_valid,
    input  instgen_s_ready,

    //input  [IW-1:0] instw_m_data,
    //input  wen,
    input clk,
    input rst_n
);

reg [AW-1 : 0] PC;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        PC <= 0;
    else if(instgen_s_ready && instgen_s_valid)
        PC <= PC+1;
    else
        PC <= PC;
end

wire [8:0] d0,d1,d2,d3;
//例化ram,addr=PC,do=inst
instram i_instram1(
    .addra(PC),
    .dia(9'h0),
    .ocea(1'b0),
    .clka(clk),
    .wea(1'b0),
    .rsta(rst_n),
    .doa(d0)
);//synthesis keep

instram i_instram2(
    .addra(PC),
    .dia(9'h0),
    .ocea(1'b0),
    .clka(clk),
    .wea(1'b0),
    .rsta(rst_n),
    .doa(d1)
);//synthesis keep

instram i_instram3(
    .addra(PC),
    .dia(9'h0),
    .ocea(1'b0),
    .clka(clk),
    .wea(1'b0),
    .rsta(rst_n),
    .doa(d2)
);//synthesis keep

instram i_instram4(
    .addra(PC),
    .dia(9'h0),
    .ocea(1'b0),
    .clka(clk),
    .wea(1'b0),
    .rsta(rst_n),
    .doa(d3)
);//synthesis keep
assign instgen_s_data ={ d3,d2,d1,d0};
assign instgen_s_valid =1'b1;
    
endmodule