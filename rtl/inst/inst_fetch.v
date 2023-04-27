module inst_gen #(parameter IW=32,
                              AW=11
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
wire [IW-1:0] inst;



always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        PC <= 0;
    else if(inst_s_ready && inst_s_valid)
        PC <= PC+1;
    else
        PC <= PC;
end

//例化ram,addr=PC,do=inst


assign instgen_s_valid =1'b1;
    
endmodule