module conv_inst_loop #(
    parameter IRW=31,IN=3,AW=14   
) (
    input       [IRW*IN-1 : 0]  m_inst      ,
    input                       m_valid     ,
    output                      m_ready     ,    

    output      [IRW*IN-1 : 0]  s_inst      ,
    output                      s_valid     ,
    input                       s_ready     ,


    input                       clk         ,
    input                       rst_n
);
localparam EW = AW-7 ;



wire fc;

wire [AW-1 : 0] inst_base;
wire [   6 : 0] inst_dim0_size;
wire [AW-1 : 0] out_base;
wire [AW-1 : 0] tmp_base;
wire [AW-1 : 0] next_base;
reg [AW-1 : 0]  next_base_r;
reg [2:0] base_change_cnt;
reg  [AW-1 : 0] base_add1 ;
reg  [   6 : 0] base_add2 ;
wire [AW-1 : 0] base_add2_w ;

assign fc               = m_inst[0];
assign inst_base        = m_inst[21  : 8];
assign inst_dim0_size   = m_inst[28  : 22];

reg    [3:0] cnt    ;
wire m1_vlaid;
wire m1_ready;

wire [IRW*IN-1 : 0] m1_bus;


always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        base_change_cnt <= 0;
    else if(m_ready) 
        base_change_cnt = 0;
    else
        base_change_cnt = base_change_cnt +1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        next_base_r <= 0
    else if(base_change_cnt==3'b111)
        next_base_r <= next_base;
end

assign tmp_base = (cnt==4'b0110) ? out_base : tmp_base

always @(*) begin
    case(cnt)
        0: base_add1 <= 0;
        1: base_add1 <= 0;
        2: base_add1 <= out_base;
        3: base_add1 <= out_base;
        4: base_add1 <= tmp_base;
        5: base_add1 <= out_base;
        6: base_add1 <= out_base;
        7: base_add1 <= inst_base;
        8: base_add1 <= out_base;
        9: base_add1 <= inst_base;
    endcase
end

always @(*) begin
    case(cnt)
        0: base_add2 <= 0;
        1: base_add2 <= 0;
        2: base_add2 <= 7'b0000001;
        3: base_add2 <= 7'b0000001;
        4: base_add2 <= inst_dim0_size;
        5: base_add2 <= 7'b0000001;
        6: base_add2 <= 7'b0000001;
        7: base_add2 <= inst_dim0_size;
        8: base_add2 <= 7'b0000001;
        9: base_add2 <= 7'b0000001;
        default: base_add2 <= 0;
    endcase
end

assign base_add2_w = {EW'b0,base_add2};
assign next_base = (base_add1 + base_add2);

assign out_base = (cnt==4'b1001) ?  inst_base : next_base_r;
assign m_ready = (~s_valid) | (cnt=4'b0 && m1_ready);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        m1_vlaid <= 1'b0;
    else if(m_valid && m_ready)
        m1_vlaid <= 1'b1;
    else if((cnt != 4'b0) && !fc && m_ready)
        m1_vlaid <= 1'b1;
    else
        m1_vlaid <= 0; 
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 4'b1001;
    else if(m_valid && m_ready)
        cnt <= 4'b1001;
    else if(s_ready && !fc)
        cnt <= cnt - 1'b1;
    else if(cnt==0)
        cnt <= 4'b1001;
    else
        cnt <= cnt;
end

assign m1_bus = {m_inst[IRW*IN-1 : 22],out_base ,m_inst[0]};

axi_frs #(.DW(IRW*IN)) i_axi_frs_inst(
    .m_data(),
    .m_valid(m1_vlaid),
    .m_ready(m1_ready),

    .s_data(s_data),
    .s_valid(s_valid),
    .s_ready(s_ready),

    .clk(clk),
    .rst_n(rst_n)
);

    
endmodule