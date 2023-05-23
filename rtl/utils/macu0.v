module macu #(parameter DW = 8,
                        CW=16                   
)(
    input [DW-1:0]        xi,
    input [DW-1:0]        wi,
    input [CW-1:0]        ci,
    input                 w_en,
 
    output reg [CW:0]     co,
    input clk,
    input rst_n
);
localparam SE =CW-16 ;

wire [ 8 : 0] x,w;
wire [17 : 0] p;
reg  [CW-1 : 0] p_r;
wire [CW-1 : 0] p_e;
reg  [CW-1 : 0] ci_r; 
wire [  CW : 0] co_w;
assign x={xi[7],xi};
assign w={wi[7],wi};

mul9 i_mul (
.a ( x ),
.b ( w ),
.p ( p ),
.cea (1'b1 ),
.ceb (w_en ),
.cepd (1'b1 ),
.clk (clk ),
.rstan (rst_n ),
.rstbn (rst_n ),
.rstdn (rst_n )
);

assign p_e = {{SE{p[15]}},p[15:0]};

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_r <= 0;
        ci_r<= 0;
    end
    else begin
        p_r<=p_e;
        ci_r<= ci;
    end
end

assign co_w= p_r+ci_r;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        co<=9'h0;
    else
        co<=co_w;
end


endmodule
