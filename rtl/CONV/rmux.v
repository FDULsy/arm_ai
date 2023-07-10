module rmux #(
    parameter DW0=16,DW=8,DN=8,IFW=4,AW=13
) (
    input [DN*DW-1 : 0]     m_data0         ,//ram
    input                   m_data_first0   ,
    input                   m_data_last0    ,
    input                   m_data_valid0   ,
    output                  m_data_ready0   ,

    input [DW0-1 : 0]       m_data1         ,//sdram pic
    input                   m_data_first1   ,
    input                   m_data_last1    ,
    input                   m_data_valid1   ,
    output                  m_data_ready1   ,  

    output [DN*DW-1 : 0]    s_data          ,
    output                  s_data_first    ,
    output                  s_data_last     ,
    output                  s_data_valid    ,
    input                   s_data_ready    ,   
    //output                  s_data_first_pre,

    input [IFW-1 : 0]       info            ,   

    input [AW-1 : 0]        m_addr          ,
    input                   m_addr_first    ,
    input                   m_addr_last     ,
    input                   m_addr_valid    ,
    output                  m_addr_ready    ,

    output                  s_ram_sel       ,
    output [AW-1 : 0]       s_addr0         ,//ram
    output                  s_addr_first0   ,
    output                  s_addr_last0    ,
    output                  s_addr_valid0   ,
    input                   s_addr_ready0   ,

    output [AW-1 : 0]       s_addr1         ,//sdram
    output                  s_addr_first1   ,
    output                  s_addr_last1    ,
    output                  s_addr_valid1   ,
    input                   s_addr_ready1   ,

    input                   clk             ,
    input                   rst_n
);

wire    mem_sel;

wire [2:0] channel;
reg [DN-1:0] channel_en;

wire [DN*DW-1 : 0] pic_data;
wire [DN*DW-1 : 0] data_sel;

wire [AW+2 : 0] m_addr_bus;
wire [AW+2 : 0] s_addr_bus;
wire m_addr_valid0;
wire m_addr_valid1;
wire m_addr_ready0;
wire m_addr_ready1;
wire s_addr_ready ;

wire data_ready;

//data
wire [DN*DW-1 : 0] data_sel_e;
wire [DN*DW+1 : 0] m_data_bus;
wire [DN*DW+1 : 0] s_data_bus;
wire            first_sel;
wire            last_sel;
wire            valid_sel;

assign ram_sel = info[4];
assign mem_sel = info[3];
assign channel = info[2:0];

assign m_addr_valid0 = ~mem_sel && m_addr_valid;
assign m_addr_valid1 = mem_sel && m_addr_valid;
assign m_addr_bus0 = {ram_sel,m_addr,m_addr_first,m_addr_last};
assign s_addr_ready  = mem_sel? s_addr_ready1 : s_addr_ready0;

axi_frs #(.DW(AW+3)) i_frs_addr0(
    .m_data(m_addr_bus0),
    .m_valid(m_addr_valid0),
    .m_ready(m_addr_ready0),

    .s_data(s_addr_bus0),
    .s_valid(s_addr_valid),
    .s_ready(s_addr_ready),

    .clk(clk),
    .rst_n(rst_n)
);
assign s_addr_valid
assign {s_ram_sel,s_addr0,s_addr_first0,s_addr_last0} = s_addr_bus;


always @(*) begin
    case (channel)
        3'b000: channel_en = 8'b11111111;
        3'b001: channel_en = 8'b00000001;
        3'b010: channel_en = 8'b00000011;
        3'b011: channel_en = 8'b00000111;
        3'b100: channel_en = 8'b00001111;
        3'b101: channel_en = 8'b00011111;
        3'b110: channel_en = 8'b00111111;
        3'b111: channel_en = 8'b01111111;
        default: channel_en=8'hff;
    endcase
end




assign pic_data = {40'h0,m_data1[15:11],3'b0,m_data1[10:5],2'b0,m_data1[4:0],3'b0};
assign data_sel = m_data_valid1? pic_data : m_data0;
assign first_sel = m_data_valid1? m_data_first1 : m_data_first0;
assign last_sel  = m_data_valid1? m_data_last1  : m_data_last0;
assign valid_sel = m_data_valid1? m_data_valid1 : m_data_valid0; 
assign m_data_ready0 = m_data_valid1? 0 : data_ready;
assign m_data_ready1 = m_data_valid1? data_ready : 0;


genvar i;
generate
    for (i =0 ;i<DN ;i=i+1 ) begin : a
        assign data_sel_e[i*DW +: DW] = channel_en[i] ? data_sel[i*DW +: DW] : 0;
    end
endgenerate 

assign m_data_bus = {data_sel_e,first_sel,last_sel};

axi_frs #(.DW(DN*DW+2)) i_frs_data(
    .m_data(m_data_bus),
    .m_valid(valid_sel),
    .m_ready(data_ready),

    .s_data(s_data_bus),
    .s_valid(s_data_valid),
    .s_ready(s_data_ready),

    .clk(clk),
    .rst_n(rst_n)
);
assign {s_data, s_data_first, s_data_last} =s_data_bus;

    
endmodule