module c_rmux #(
    parameter DW0=16,DW=8,DN=8,IFW=7,AW=14
) (
    input [DW0-1 : 0]       m_data0         ,//sdram pic
    input                   m_data_first0   ,
    input                   m_data_last0    ,
    input                   m_data_valid0   ,
    output                  m_data_ready0   ,

    input [DN*DW-1 : 0]     m_data1         ,//ram1
    input                   m_data_first1   ,
    input                   m_data_last1    ,
    input                   m_data_valid1   ,
    output                  m_data_ready1   ,  

    input [DN*DW-1 : 0]     m_data2         ,//ram1
    input                   m_data_first2   ,
    input                   m_data_last2    ,
    input                   m_data_valid2   ,
    output                  m_data_ready2   ,  

    output [DN*DW-1 : 0]    s_data          ,
    output                  s_data_first    ,
    output                  s_data_last     ,
    output                  s_data_valid    ,
    input                   s_data_ready    ,   
    //output                  s_data_first_pre,

    input  [IFW-1   : 0]    rinfo           ,//channel_3[7:5],memsel_1[4],ramsel_1[3],rgb_c_1[2],R_pic_rdy_1   

    input  [54      : 0]    m_info          ,
    output [54      : 0]    s_info          ,

    input [AW-1 : 0]        m_addr          ,
    input                   m_addr_first    ,
    input                   m_addr_last     ,
    input                   m_addr_valid    ,
    output                  m_addr_ready    ,

    output                  s_read_pic_ready,

    output [AW-1 : 0]       s_addr          ,
    output                  s_addr_first    ,
    output                  s_addr_last     ,

    output                  s_addr_valid0   ,//pic:sram or fifo
    input                   s_addr_ready0   ,
    output                  s_addr_valid1   ,//ram1 ,a_ram_sel=0
    input                   s_addr_ready1   ,
    output                  s_addr_valid2   ,//ram2 ,a_ram_sel=1
    input                   s_addr_ready2   ,


    input                   clk             ,
    input                   rst_n    
);


wire [2:0] channel;

wire    mem_sel;
wire    ram_sel;

wire    a_mem_sel;
wire    a_ram_sel;

wire    d_mem_sel;
wire    d_ram_sel;

wire [AW+8 : 0] m_addr_bus;
wire [AW+8 : 0] s_addr_bus;

wire [IFW-1 : 0] info_pass ;
reg  [IFW-1 : 0] s_info_r ;

wire [DN*DW-1 : 0] pic_data;
wire [DN*DW-1 : 0] data_sel;

wire               first_sel;
wire               last_sel;
reg  [DN*DW-1 : 0] data_out;

wire [DN*DW+1 : 0] m_data_bus;
wire               m_data_valid;
// wire               m_data_ready;

wire [DN*DW+1 : 0] s_data_bus;

assign s_read_pic_ready = rinfo[4];

//=================info===========
// axi_frs #(.DW(52)) i_frs_addr0(    //早2拍
//     .m_data (m_info             ),
//     .m_valid(m_addr_valid       ),
//     .m_ready(                   ),

//     .s_data (s_info             ),
//     .s_valid(s_addr_valid       ),
//     .s_ready(s_addr_ready       ),

//     .clk(clk),
//     .rst_n(rst_n)
// );

assign s_info =  m_info; //早3拍


//================rinfo===========
assign mem_sel = rinfo[3];
assign ram_sel = rinfo[2];

assign a_mem_sel = info_pass[3];
assign a_ram_sel = info_pass[2];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_info_r <= 0;
    else
        s_info_r <= info_pass;
end

assign d_mem_sel = s_info_r[3];
assign d_ram_sel = s_info_r[2];

assign channel = s_info_r[6:4];

//=================addr===========
assign m_addr_bus = {rinfo,m_addr_first, m_addr_last, m_addr};

axi_frs #(.DW(AW+8)) i_frs_addr0(
    .m_data(m_addr_bus),
    .m_valid(m_addr_valid),
    .m_ready(m_addr_ready),

    .s_data(s_addr_bus),
    .s_valid(s_addr_valid),
    .s_ready(s_addr_ready),

    .clk(clk),
    .rst_n(rst_n)
);

assign {info_pass, s_addr_first, s_addr_last, s_addr} = s_addr_bus;
assign s_addr_valid0 = ~a_mem_sel && s_addr_valid ;
assign s_addr_valid1 = a_mem_sel && ~a_ram_sel && s_addr_valid ;
assign s_addr_valid2 = a_mem_sel && a_ram_sel && s_addr_valid ;
assign s_addr_ready = mem_sel ? (ram_sel ? s_addr_ready2: s_addr_ready1) : s_addr_ready0;

//=================data===========
assign pic_data = {40'h0,m_data1[15:11],3'b0,m_data1[10:5],2'b0,m_data1[4:0],3'b0};
assign data_sel = d_mem_sel ? (d_ram_sel ? m_data2 : m_data1) : pic_data ;

genvar i;
generate
    for (i = 0;i<DN ;i=i+1 ) begin
        always @(*) begin
            case (channel)
                3'b000: data_out = data_sel;
                3'b001: data_out = {'h0,data_sel[DW-1   : 0]};
                3'b010: data_out = {'h0,data_sel[2*DW-1 : 0]};
                3'b011: data_out = {'h0,data_sel[3*DW-1 : 0]};
                3'b100: data_out = {'h0,data_sel[4*DW-1 : 0]};
                3'b101: data_out = {'h0,data_sel[5*DW-1 : 0]};
                3'b110: data_out = {'h0,data_sel[6*DW-1 : 0]};
                3'b111: data_out = {'h0,data_sel[7*DW-1 : 0]};
                default: data_out= data_sel;
            endcase
        end
    end
endgenerate

assign first_sel = d_mem_sel ? (d_ram_sel ? m_data_first2 : m_data_first1) : m_data_first0 ;
assign last_sel = d_mem_sel ? (d_ram_sel ? m_data_last2 : m_data_last1) : m_data_last0 ;
assign m_data_bus = {first_sel, last_sel, data_out};

assign m_data_valid = d_mem_sel ? (d_ram_sel ? m_data_valid2 : m_data_valid1) : m_data_valid0 ;
// assign m_data_ready = d_mem_sel ? (d_ram_sel ? m_data_ready2 : m_data_ready1) : m_data_ready0 ;


axi_frs #(.DW(DN*DW+2)) i_frs_data(
    .m_data(m_data_bus   ),
    .m_valid(m_data_valid),
    .m_ready(            ),

    .s_data(s_data_bus),
    .s_valid(s_data_valid),
    .s_ready(s_data_ready),

    .clk(clk),
    .rst_n(rst_n)
);

assign s_data       = s_data_bus[DW*DN-1 : 0]   ;
assign s_data_first = s_data_bus[DW*DN+1]       ;
assign s_data_last  = s_data_bus[DW*DN  ]       ;
    
endmodule