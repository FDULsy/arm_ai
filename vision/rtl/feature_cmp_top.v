module feature_cmp_top #(parameter MODN = 30)(
    input       [1:0]           state       ,
    input       [15:0]          data        ,
    input       [MODN*16-1:0]   mod_bus     ,
    output  reg [MODN*4-1 :0]   diff_bus    ,
    input                       clk         ,
    input                       rst_n
);

wire [MODN*16-1:0] diff_bus_w;
genvar i;
generate
    for (i = 0;i<MODN ;i=i+1 ) begin: f_cmp
        feature_cmp i_feature_cmp(
            .d1(data),
            .d2(mod_bus[i*16 +: 16]),
            .diff(diff_bus_w[i*4 +: 4]),
            .clk(clk),
            .rst_n(rst_n)
        );
    end
endgenerate

always @(posedge clk or negedge rst_n ) begin
    if(!rst_n || (state==2'b00) || (state == 2'b11))
        diff_bus <= MODN*16'b0;
    else 
        diff_bus <= diff_bus_w;
end

endmodule