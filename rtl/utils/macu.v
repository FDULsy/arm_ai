module macu #(
    parameter DW =8,CW=16
) (
    input [DW-1:0]        xi,
    input [DW-1:0]        wi,
    input [CW-1:0]        ci,
 
    output  [CW:0]        co,
    input clk,
    input rst_n 
);

wire [15:0] p;
reg  [15:0] p_r;
reg  [CW-1:0] ci_r;
reg [CW:0] co_r;
 
assign p=xi*wi;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_r <= 0;
        ci_r <=0;
    end
    else begin  
        p_r <= p;
        ci_r<=ci;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        co_r <=0;
    else
        co_r <=ci_r+p_r;
end
assign co = co_r;
    
endmodule