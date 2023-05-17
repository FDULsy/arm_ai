module mac_row #(parameter DW=8,WW=8,CW=16,COLUMN=6
) (
    input  [      DW-1 : 0]  xi,
    input  [  COLUMN*WW-1 : 0]  wi,
    input  [  COLUMN*CW-1 : 0]  ci,
    input  [     COLUMN-1 : 0]  w_en,

    output [ COLUMN*(CW+1)-1 : 0] co,

    input clk,
    input rst_n
);

wire [DW-1 : 0] x_pass [COLUMN-1 : 0];
reg  [DW-1 : 0] x_pass_r [COLUMN-2 : 0];

assign x_pass[0] = xi;
assign x_pass[COLUMN-1 : 1] = x_pass_r;
genvar i;
generate
    for (i=0;i<COLUMN;i=i+1) begin: mac_row_gen
        macu #(.DW(DW),.CW(CW)) i_macu(
            .xi(x_pass[i]),
            .wi(wi[i*WW +: WW]),
            .ci(ci[i*CW +: CW]),
            .w_en(w_en[i]),

            .co(co[i*(CW+1) +: (CW+1)]),

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