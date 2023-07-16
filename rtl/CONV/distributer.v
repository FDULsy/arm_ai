module distributer #(
    parameter DW=8,CW=19,OW=26,ROW=7,COLUMN=7,INFOW=55,INFOW1=28
              
) (
    input   [DW*ROW-1    : 0]   m1_data     ,
    input                       m1_first    ,
    input                       m1_last     ,
    input                       m1_valid    ,
    input                       m1_first_pre,

    input   [INFOW-1     : 0]   m1_info     ,

    output  [DW*ROW-1    : 0]   s1_data     ,//to mac

    output                      s1_start    ,
    output  [6:0]               s1_size     ,
    output                      s1_clear    ,

    input   [CW*COLUMN-1 : 0]   m2_data     ,

    output  [OW*COLUMN-1 : 0]   s2_data     ,
    output  [INFOW1-1    : 0]   s2_info     ,
    output                      s2_valid    ,
    output                      s2_valid_pre,
    output                      s2_first    ,
    output                      s2_last     ,
    output                      s2_start    ,
    output                      s2_fc       ,
    output  [8 : 0]             s2_base     ,
    output  [8 : 0]             s2_size     ,


    input                       clk         ,
    input                       rst_n
);

// wire [DW*ROW+1    : 0] m_bus;
// wire [DW*ROW+1    : 0] s_bus;
// wire s_valid;
wire [1 : 0] m_valid_bus;
wire [1 : 0] s_valid_bus;
wire [18 : 0] m_pre_bus ;
wire [18 : 0] s_pre_bus ;

genvar i;
//========================s1=====================
//weight
assign s1_start  = m1_first_pre;
assign s1_size   = m1_info[7:1];
assign s1_clear  = m1_info[51];

//delay
// assign m_bus = {m1_first , m1_last , m1_data};
// axi_frs #(.DW(DW*ROW+2)) i_axi_frs_data(
//     .m_data(m_bus),
//     .m_valid(m1_valid),
//     .m_ready(),

//     .s_data(s_bus),
//     .s_valid(s_valid),
//     .s_ready(1'b1),

//     .clk(clk),
//     .rst_n(rst_n)
// );

delay_chain #(.DW(DW*ROW),.DN(ROW)) i_delay_chain(
    .xi     (m1_data    ),
    .xo     (s1_data    ),
    .clk    (clk        ),
    .rst_n  (rst_n      )
);

assign m_valid_bus = { m1_first, m1_last};

delay #(.DW(1),.DLT(7)) i_delay0(
    .xi(m1_first),
    .xo(s2_start),

    .clk(clk),
    .rst_n(rst_n)
);

delay #(.DW(1),.DLT(8)) i_delay1(
    .xi(m1_valid),
    .xo(s2_valid_pre),

    .clk(clk),
    .rst_n(rst_n)
);


delay #(.DW(1),.DLT(1)) i_delay2(
    .xi(s2_valid_pre),
    .xo(s2_valid),

    .clk(clk),
    .rst_n(rst_n)
);

delay #(.DW(2),.DLT(9)) i_delay3(
    .xi(m_valid_bus),
    .xo(s_valid_bus),

    .clk(clk),
    .rst_n(rst_n)
);

assign m_pre_bus = {m1_info[40:23],m1_info[0]};

delay #(.DW(19),.DLT(7)) i_delay4(
    .xi(m_pre_bus),
    .xo(s_pre_bus),

    .clk(clk),
    .rst_n(rst_n)
);


//========================s2=====================
assign { s2_first, s2_last} = s_valid_bus;
assign { s2_size, s2_base, s2_fc} = s_pre_bus;
generate
    for (i =0 ;i<COLUMN ;i=i+1 ) begin
        assign s2_data[i*OW +: OW] = { {7{m2_data[(i+1)*CW-1]}},m2_data[i*CW +: CW]};
    end
endgenerate

assign s2_info = {m1_info[54:52],m1_info[50:41],m1_info[22:8]};
    
endmodule