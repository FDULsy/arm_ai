module macu #(parameter DW = 8,
                        OW=19                   
)(
    input [DW-1:0]          xi          , 
    input [DW-1:0]          wi          ,
    input                   w_en        ,
    input [OW-1:0]          ci          , 
 
    output reg [OW-1 :0]    co          ,

    input clk,
    input rst_n
);
localparam SE =OW-18 ;

reg [DW-1 : 0] s_x;
reg  [DW-1 : 0] s_w;

wire [ 8 : 0] x,w;
wire [17 : 0] p;
wire [OW-1 : 0] p_e;

reg [OW-1   : 0] s_p;
reg [OW-1   : 0] s_c;

wire [  OW : 0] co_w;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_w <= 0;
    else if(w_en)
        s_w <= wi;
    else
        s_w <= s_w;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_x <= 0;
    else
        s_x <= xi;
end

assign x={s_x[7],s_x};
assign w={s_w[7],s_w};

mul9 i_mul (
.a ( x ),
.b ( w ),
.p ( p )
//.cea (1'b1 ),
//.ceb (w_en ),
//.cepd (1'b1 ),
//.clk (clk ),
//.rstan (rst_n ),
//.rstbn (rst_n ),
//.rstpdn (rst_n )
);

assign p_e = {{SE{p[15]}},p[15:0]};

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s_p <= 0;
        // s_c <= 0;
    end
    else begin
        s_p <= p_e;
        // s_c <= ci;
    end    
end

assign co_w= s_p+ci;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        co <= 0;
    else
        co <= co_w;
end

endmodule
