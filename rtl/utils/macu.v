module macu #(
    parameter DW =8,CW=16,OW=17
) (
    input signed [DW-1:0]        xi,
    input signed [DW-1:0]        wi,
    input signed [CW-1:0]        ci,
    input                        w_en,
 
    output  [OW-1:0]        co,
    input clk,
    input rst_n 
);

localparam EW = CW-2*DW;
wire signed [15:0] p;
reg [DW-1 : 0] xi_r,wi_r;
reg  signed [CW-1:0] p_r;
//reg  [CW-1:0] ci_r;
reg [CW:0] co_r;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wi_r<=0;
    else if(w_en)
        wi_r<=wi;
    else
        wi_r<=wi_r;

end

assign p=xi_r*wi_r;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        xi_r <=0;
        p_r <= 0;
        //ci_r <=0;
    end
    else begin  
        xi_r <= xi;
        p_r  <= {{EW{p[2*DW-1]}},p};
        //ci_r <= ci;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        co_r <=0;
    else
        co_r <=ci+p_r;
end
assign co = co_r[OW-1:0];
    
endmodule