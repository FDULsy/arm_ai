module inst_fetch #(parameter IW=36,
                              AW=11
) (
    output [IW-1:0] instgen_s_data,
    output reg instgen_s_valid,
    input  instgen_s_ready,
    input  finish         ,

    //input  [IW-1:0] instw_m_data,
    //input  wen,
    input clk,
    input rst_n
);

reg [AW-1 : 0] PC;
reg valid;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        instgen_s_valid <= 0;
    else
        instgen_s_valid <= valid;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        PC <= 0;
        valid <= 1'b1;
    end
    else if(finish) begin
        PC <= 0;
        valid <= 1'b1;
    end
    else if(instgen_s_ready) begin
        PC <= PC+1;
        valid <= 1'b1;
    end
    else begin
        PC <= PC;
        valid <= 1'b0;
    end
end


instram i_instram(
    .doa(instgen_s_data),
    .dia('h0),
    .addra(PC),
    .clka(clk),
    .wea(1'b0),
    .rsta(rst_n)
);

endmodule