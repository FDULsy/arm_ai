module mac_row #(parameter DW=8,WW=8,CW=16,OW=17,COLUMN=6
) (
    input  [      DW-1 : 0]  xi,
    input  [  COLUMN*WW-1 : 0]  wi,
    input  [  COLUMN*CW-1 : 0]  ci,
    input                     w_en,

    output [ COLUMN*OW-1 : 0] co,

    input clk,
    input rst_n
);
localparam EW = CW-2*DW;

wire [DW-1 : 0] x_pass [COLUMN-1 : 0];
//reg  [DW-1 : 0] x_pass_r [COLUMN-2 : 0];
reg  [DW-1 : 0] x_pass_r [COLUMN-1 : 0];
assign x_pass[0] = xi;
assign x_pass[1] = x_pass_r[0];
assign x_pass[2] = x_pass_r[1];
assign x_pass[3] = x_pass_r[2];
assign x_pass[4] = x_pass_r[3];
assign x_pass[5] = x_pass_r[4];
genvar i;

// macu #(.DW(DW),.CW(CW),.OW(OW)) i_mac5(
//     .xi(x_pass[5]),
//     .wi(wi[5*WW +: WW]),
//     .ci(ci[5*CW +: CW]),
//     .w_en(w_en[5]),

//     .co(co[5*OW +: OW]),
//     .clk(clk),
//     .rst_n(rst_n)
// );
generate
    for (i=0;i<6;i=i+1) begin: mac_row_gen
        macu #(.DW(DW),.CW(CW),.OW(OW)) i_macu(
            .xi(x_pass[i]),
            .wi(wi[i*WW +: WW]),
            .ci(ci[i*CW +: CW]),
            .w_en(w_en),

            .co(co[i*(OW) +: OW]),

            .clk(clk),
            .rst_n(rst_n)
        );

        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                x_pass_r[i] <= 0;
            else 
                x_pass_r[i] <= x_pass[i];
        end
    end
endgenerate

    
endmodule