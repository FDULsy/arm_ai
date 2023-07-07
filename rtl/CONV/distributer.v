module distributer #(
    parameter DW=8,CW=19,OW=22,ROW=8,COLUMN=6,INFOW=59,INFOW1=11,INFOW2=28
              
) (
    input   [DW*ROW-1    : 0]   m1_data     ,
    input                       m1_valid    ,
    input                       m1_first    ,
    input                       m1_last     ,
    input   [INFOW-1     : 0]   m1_info     ,

    output                      s1_first    ,
    output  [INFOW1-1    : 0]   s1_info     ,


    input   [CW*COLUMN-1 : 0]   m2_data     ,

    output  [OW*COLUMN-1 : 0]   s2_data     ,
    output  [INFOW2-1    : 0]   s2_info     ,
    output                      s2_valid    ,
    output                      s2_valid_pre,
    output                      s2_first    ,
    output  [9 : 0]             s2_base     ,
    output  [9 : 0]             s2_size     ,




    input                       clk         ,
    input                       rst_n
);
    
endmodule