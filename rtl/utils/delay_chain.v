module delay_chain #(parameter DW=64,DN=8
) (
    input  [DW-1:0] xi,
    output [DW-1:0] xo,

    input clk,
    input rst_n
);

localparam SDW=DW/DN ;

assign xo[0 +: SDW ] = xi[0 +: SDW];
genvar i;
generate
    for(i=1;i<DN;i=i+1) begin:delay_chain_gen
        delay #(.DW(SDW),.DLT(i)) i_delay(
            .xi(xi[SDW*i +: SDW]),
            .xo(xo[SDW*i +: SDW]),
            .clk(clk),
            .rst_n(rst_n)
        );
    end
endgenerate

    
endmodule