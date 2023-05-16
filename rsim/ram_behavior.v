module ram_behavior #(
    parameter AW=8, DW=32
) (
    input  [AW-1:0]      r_addr,
    input                r_en,
    output reg [DW-1:0]  r_data,

    input  [AW-1:0]  w_addr,
    input            w_en,
    input  [DW-1:0]  w_data,

    input clk,
    input rst_n
);

reg [DW-1:0] mem [AW-1:0];

always @(posedge clk ) begin
     if(r_en)
        r_data <= mem[r_addr];
end

always @(posedge clk ) begin
    if(w_en)
        mem[w_addr] <= w_data;
end

genvar i;
generate
    for ( i=0 ;i<2**AW ;i=i+1 ) begin
        always @(negedge rst_n) begin
            if(!rst_n)
                mem[i] <= i;
        end
    end
endgenerate
endmodule
