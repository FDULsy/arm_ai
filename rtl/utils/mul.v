module mul #(
    parameter DW=9,OW=18
) (
    input  signed  [DW-1 : 0] d1,
    input  signed [DW-1 : 0] d2,
    output signed [OW-1 : 0] do,

    input clk,
    input rst_n
);

reg signed [DW-1 : 0] d1_r,d2_r;
reg signed [OW-1 : 0] do_r;
wire signed [OW-1 : 0] y;

assign y=d1_r*d2_r;

always @(posedge clk or rst_n) begin
    if(!rst_n) begin
        d1_r <= 0;
        d2_r <= 0;
        do_r <= 0;
    end
    else begin
        d1_r <= d1;
        d2_r <= d2;
        do_r <= y;
    end
end

assign do=do_r;

    
endmodule