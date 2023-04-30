module macu #(parameter DW = 8,
                        ADDW=10                   
)(
    input [DW-1:0]        xi,
    input [DW-1:0]        wi,
    input [ADDW-1:0]      p_sum_in,
    input                 w_en,
 
    output reg [ADDW:0]   p_sum_out,
    output reg [DW-1:0]   x_pass,
    output reg [DW-1:0]   wi_pass,
    output reg            w_en_pass,
    input clk,
    input rst_n
);

wire [8 :0] x,w;
wire [9:0] p;
reg [9:0] p_r;
reg [ADDW-1:0] p_sum_in_r; 
assign x={xi[7],xi};
assign w={wi[7],wi};

EG4_LOGIC_MULT #(
.INPUT_WIDTH_A (9 ),
. INPUT_WIDTH_B (9 ),
.OUTPUT_WIDTH (18 ),
. INPUTFORMAT ("SIGNED" ),
. INPUTREGA ("ENABLE" ),
. INPUTREGB ("ENABLE" ),
. OUTPUTREG ("ENABLE" ),
. IMPLEMENT ("DSP" ),
. SRMODE ("ASYNC" )
) i_mul (
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

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        p_r <= 9'h0;
        p_sum_in_r<= 0;
    end
    else begin
        p_r<=p[8:0];
        p_sum_in_r<= p_sum_in;
end

assign p_sum_new= p_r+p_sum_in_r;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        p_sum_out<9'h0;
    else
        p_sum_out<=p_sum_new;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        wi_pass<=0;
        w_en_pass<=0;
    end
    else begin
        wi_pass<=wi;
        w_en_pass<=w_en;
    end
end


endmodule