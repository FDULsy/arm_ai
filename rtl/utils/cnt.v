module cnt(
    input clk,
    input rst_n,    
    output en
);

reg cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 0;
    else
        cnt <= ~cnt;
end

endmodule