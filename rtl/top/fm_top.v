module fm_top(
    input [47:0]       w_data,
    input [13 : 0]     w_addr,
    input              w_valid,
    output             w_ready,
   
    input [13 : 0]     r_addr,
    input              r_valid,
    input              r_first,
    input              r_last,
    output             r_ready,
    output reg [63 : 0]    r_data,
    output reg         r_data_valid,
    output reg         r_data_first,
    output reg         r_data_last,
    input              r_data_ready,
    
    input clk,
    input rst_n

);
assign w_ready =1'b1;
wire [15:0] rd0,rd1,rd2,rd3,rd4,rd5,rd6,rd7,rd8,rd9,rd10,rd11;
wire [15:0] wd0,wd1,wd2;
wire w_valid0,w_valid1,w_valid2,w_valid3;
assign r_ready =1'b1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        r_data_valid <= 0 ;
        r_data_first <= 0 ;
        r_data_last  <= 0 ;
    end
    else begin
        r_data_valid <= r_valid;
        r_data_first <= r_first;
        r_data_last  <= r_last;
    end
end

always @(*) begin
    case (r_addr[12:11])
        2'b00: r_data = {rd3,rd2,rd1,rd0};
        2'b01: r_data = {rd7,rd6,rd5,rd4};
        2'b10: r_data = {rd11,rd10,rd9,rd8};
        default: r_data = {rd3,rd2,rd1,rd0};
    endcase
end

assign wd0 = w_data[15:0];
assign wd1 = w_data[31:16];
assign wd2 = w_data[47:32];
assign w_valid0 = w_addr[12:11] == 2'b00;
assign w_valid1 = w_addr[12:11] == 2'b01;
assign w_valid2 = w_addr[12:11] == 2'b10;
assign w_valid3 = w_addr[12:11] == 2'b11;

ram32 i_ram0(
    .addra(w_addr[10:0]),
    .dia(wd0),
    .cea(w_valid0),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd0),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

ram32 i_ram1(
    .addra(w_addr[10:0]),
    .dia(wd1),
    .cea(w_valid0),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd1),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

ram32 i_ram2(
    .addra(w_addr[10:0]),
    .dia(wd2),
    .cea(w_valid0),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd2),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

ram32 i_ram3(
    .addra(w_addr[10:0]),
    .dia(wd0),
    .cea(w_valid1),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd3),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

ram32 i_ram4(
    .addra(w_addr[10:0]),
    .dia(wd1),
    .cea(w_valid1),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd4),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

ram32 i_ram5(
    .addra(w_addr[10:0]),
    .dia(wd2),
    .cea(w_valid1),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd5),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);

ram32 i_ram6(
    .addra(w_addr[10:0]),
    .dia(wd0),
    .cea(w_valid2),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd6),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);
ram32 i_ram7(
    .addra(w_addr[10:0]),
    .dia(wd1),
    .cea(w_valid2),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd7),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);
ram32 i_ram8(
    .addra(w_addr[10:0]),
    .dia(wd2),
    .cea(w_valid2),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd8),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);
ram32 i_ram9(
    .addra(w_addr[10:0]),
    .dia(wd0),
    .cea(w_valid3),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd9),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);
ram32 i_ram10(
    .addra(w_addr[10:0]),
    .dia(wd1),
    .cea(w_valid3),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd10),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);
ram32 i_ram11(
    .addra(w_addr[10:0]),
    .dia(wd2),
    .cea(w_valid3),
    .clka(clk),

    .addrb(r_addr[10:0]),
    .dob(rd11),
    .oceb(1'b1),
    .clkb(clk),
    .rstb(rst_n)
);


endmodule