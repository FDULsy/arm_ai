module rgb2b(
    input   [255:0]     data_in     ,
    output  [15 :0]     binary  
);

localparam R_th = 5'd11;
localparam B_th = 5'd11;

genvar i;
generate
    for (i = 0;i<16 ; i=i+1 ) begin
        assign binary[i] = ((data_in[16*i+11 +:5] >R_th) && (data_in[16*i +:5] >B_th)) ? 1'b0 : 1'b1;
    end
endgenerate

endmodule