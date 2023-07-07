module mac_row #(parameter DW=8,OW=19,COLUMN=6
) (
    input  [      DW-1 : 0]     xi,
    input  [  COLUMN*DW-1 : 0]  wi,
    input  [  COLUMN*OW-1 : 0]  ci,
    input                     w_en,

    output [ COLUMN*OW-1 : 0] co,

    input clk,
    input rst_n
);

genvar i;

// macu #(.DW(DW),.OW(OW),.OW(OW)) i_mac5(
//     .xi(x_pass[5]),
//     .wi(wi[5*DW +: DW]),
//     .ci(ci[5*OW +: OW]),
//     .w_en(w_en[5]),

//     .co(co[5*OW +: OW]),
//     .clk(clk),
//     .rst_n(rst_n)
// );
generate
    for (i=0;i<6;i=i+1) begin: mac_row_gen
        macu #(.DW(DW),.OW(OW)) i_macu(
            .xi(xi),
            .wi(wi[i*DW +: DW]),
            .w_en(w_en),
            .ci(ci[i*OW +: OW]),
            
            .co(co[i*(OW) +: OW]),

            .clk(clk),
            .rst_n(rst_n)
        );
    end
endgenerate

    
endmodule