module ioram #(
    parameter DW=8,DN=7,AW=14
) (
    input   [AW-1   : 0]    r_addr          ,
    input                   r_addr_first    ,
    input                   r_addr_last     ,
    input                   r_addr_valid    ,
    output  reg             r_addr_ready    ,
    output  [DW*DN-1 : 0]   r_data          ,
    output  reg             r_data_first    ,
    output  reg             r_data_last     ,
    output  reg             r_data_valid    ,
    input                   r_data_ready    ,

    input   [AW-1   : 0]    w_addr          ,
    input                   w_addr_first    ,
    input                   w_addr_last     ,
    input                   w_addr_valid    ,
    output                  w_addr_ready    ,
    input   [DW*DN-1 : 0]   w_data          ,

    input                   clk             ,
    input                   rst_n     
);

assign w_addr_ready =1'b1;

ram_tmp1 i_ram1(
    .dia(w_data),
    .addra(w_addr),
    .cea(w_addr_valid)
    .clka(clk),
    .dob(r_data),
    .addrb(r_addr),
    .clkb(clk),
    .rstb(rst_n)
);

reg in_writing;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        in_writing <= 0;
    else if(w_addr_last)
        in_writing <= 0;
    else if(w_addr_first)
        in_writing <= 1'b1;
end
always @(posedge clk or negedge rst_n ) begin
    if(!rst)
        r_addr_ready <= 0;
    else if(r_addr_last && !in_writing)
        r_addr_ready <= 0;
    else if(in_writing)
        r_addr_ready <= 1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r_data_first <= 0;
        r_data_last  <= 0;
        r_data_valid <= 0;
    end
    else begin
        r_data_first <= r_addr_first;
        r_data_last  <= r_addr_last;
        r_data_valid <= r_addr_valid;
    end
end


endmodule