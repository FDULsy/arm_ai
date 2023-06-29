`timescale 1ps/1ps
module delay #(parameter DW=8,DLT=1//DLT=delay time
) (
    input  [DW-1:0] xi,
    output [DW-1:0] xo,

    input clk,
    input rst_n
);
    
reg [DW-1:0] x_r [DLT-1:0];

genvar i;
generate
    for(i=0;i<DLT;i=i+1) begin:delay_gen
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                x_r[i] <=  0;
            else if(i==0)
                x_r[0] <= xi;
            else
                x_r[i] <=  x_r[i-1];
        end
    end
endgenerate

assign xo = x_r[DLT-1];

endmodule