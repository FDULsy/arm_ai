module weightrom
(
    input  wire       i_last   ,
    input  wire       i_clk    ,
    input  wire       i_rst_n  ,
    input  wire [2:0] i_data_n ,
    input  wire [1:0] i_fc,

    output reg        o_data_en,
    output wire [7:0] o_data0  ,
    output wire [7:0] o_data1  ,
    output wire [7:0] o_data2  ,
    output wire [7:0] o_data3  ,
    output wire [7:0] o_data4  ,
    output wire [7:0] o_data5
);
reg [12:0] addr0;
reg [12:0] addr1;
reg [12:0] addr2;
reg [12:0] addr3;
reg [12:0] addr4;
reg [12:0] addr5;
reg [2:0] data_cnt;
reg       data0_en;
reg       data1_en;
reg       data2_en;
reg       data3_en;
reg       data4_en;
reg       data5_en;
wire      data_en;

//*****

weightram iw1(
    .addra(addr0),
    .dia(8'h0),
    .ocea(1'b1),
    .clka(i_clk),
    .wea(1'b1),
    .rsta(i_rst_n),
    .doa(o_data0),

    .addrb(addr1),
    .dib(8'h0),
    .oceb(1'b1),
    .clkb(i_clk),
    .web(1'b1),
    .rstb(i_rst_n),
    .dob(o_data1)
);

weightram iw2(
    .addra(addr2),
    .dia(8'h0),
    .ocea(1'b1),
    .clka(i_clk),
    .wea(1'b1),
    .rsta(i_rst_n),
    .doa(o_data2),

    .addrb(addr3),
    .dib(8'h0),
    .oceb(1'b1),
    .clkb(i_clk),
    .web(1'b1),
    .rstb(i_rst_n),
    .dob(o_data3)
);

weightram iw3(
    .addra(addr4),
    .dia(8'h0),
    .ocea(1'b1),
    .clka(i_clk),
    .wea(1'b1),
    .rsta(i_rst_n),
    .doa(o_data4),

    .addrb(addr5),
    .dib(8'h0),
    .oceb(1'b1),
    .clkb(i_clk),
    .web(1'b1),
    .rstb(i_rst_n),
    .dob(o_data5)
);

always @(posedge i_clk or negedge i_rst_n) begin
    if (i_rst_n == 1'b0) begin
        data_cnt <= 3'b0;
    end
    else if (i_last == 1'b1)begin
        data_cnt <= 3'b0;
    end
    else if (data_cnt  == i_data_n) begin
        data_cnt <= data_cnt;
    end
    else begin
        data_cnt <= data_cnt + 1'b1;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (i_rst_n == 1'b0) begin
        data0_en <=  1'b1;
    end
    else if(i_last == 1'b1)begin
        data0_en <= 1'b1;
    end
    else if (data_cnt == i_data_n) begin
        data0_en <=  1'b0;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (i_rst_n == 1'b0) begin
        data1_en <=  1'b0;
        data2_en <=  1'b0;
        data3_en <=  1'b0;
        data4_en <=  1'b0;
        data5_en <=  1'b0;
    end
    else begin
        data1_en <=  data0_en;
        data2_en <=  data1_en;
        data3_en <=  data2_en;
        data4_en <=  data3_en;
        data5_en <=  data4_en;
    end
end

assign data_en = data0_en | data1_en | data2_en | data3_en | data4_en | data5_en;
always @(posedge i_clk or negedge i_rst_n) begin
    if (i_rst_n == 1'b0) begin
        o_data_en <=  1'b0;
    end
    else begin
        o_data_en <=  data_en;
    end
end

always@(posedge i_clk or negedge i_rst_n)begin
    if (i_rst_n == 1'b0) begin
        addr0 <=  8'b0;
    end
    else if(data0_en == 1'b1)begin
        addr0 <=  addr0 + 1'b1;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin
    if (i_rst_n == 1'b0) begin
        addr1 <=  8'b0;
        addr2 <=  8'b0;
        addr3 <=  8'b0;
        addr4 <=  8'b0;
        addr5 <=  8'b0;
    end
    else begin
        addr1 <=  addr0;
        addr2 <=  addr1;
        addr3 <=  addr2;
        addr4 <=  addr3;
        addr5 <=  addr4;
    end
end

endmodule