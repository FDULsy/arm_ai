module delay_chain #(parameter DW=64,DN=8
) (
    input  [DW-1:0] xi,
    output [DW-1:0] xo,

    input clk,
    input rst_n
);

localparam SDW=DW/DN ;

assign xo[0 +:8 ] = xi[0 +: 8];
genvar i;
generate
    for(i=1;i<DN;i=i+1) begin:delay_chain_gen
        delay #(.DW(SDW),.DLT(i)) i_delay(
            .xi(xi[8*i +: 8]),
            .xo(xo[8*i +: 8]),
            .clk(clk),
            .rst_n(rst_n)
        );
    end
endgenerate

    
endmodule