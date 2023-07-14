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
wire negedge_s_ready;
wire [AW-1 : 0] inst_base;
wire [   6 : 0] inst_dim0_size;
wire [AW-1 : 0] out_base;
wire [AW-1 : 0] tmp_base;
wire [AW-1 : 0] next_base;
reg [AW-1 : 0]  next_base_r;
reg [1:0] base_change_cnt;
reg  [AW-1 : 0] base_add1 ;
reg  [   6 : 0] base_add2 ;
wire [AW-1 : 0] base_add2_w ;
reg s_ready_r;

assign fc               = m_inst[0];
assign inst_base        = m_inst[21  : 8];
assign inst_dim0_size   = m_inst[28  : 22];

reg in_loop;
reg    [3:0] cnt    ;
reg m1_vlaid;
wire m1_ready;

wire [AW-1 : 0] out_base_r;

wire [IRW*IN-1 : 0] m1_bus;



always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_ready_r <= 0;
    else
        s_ready_r <= s_ready;
end

assign negedge_s_ready = !s_ready && s_ready_r;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        base_change_cnt <= 0;
    else if(m1_ready) 
        base_change_cnt <= 0;
    else
        base_change_cnt <= base_change_cnt +2'b01;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        next_base_r <= 0;
    else if(base_change_cnt==2'b11)
        next_base_r <= next_base;
end

assign tmp_base = (cnt==4'b0011 && m1_vlaid) ? out_base : tmp_base;

// always @(posedge clk or negedge rst_n) begin
//     if (!rst_n)
//         tmp_base<=0;
//     else if(cnt==4'b0011)
// end

always @(*) begin
    case(cnt)
        0: base_add1 <= inst_base;// 
        1: base_add1 <= out_base_r;
        2: base_add1 <= inst_base;
        3: base_add1 <= out_base_r;
        4: base_add1 <= out_base_r;
        5: base_add1 <= tmp_base;
        6: base_add1 <= out_base_r;
        7: base_add1 <= out_base_r;
        8: base_add1 <= 0;
        9: base_add1 <= 0;
    endcase
end

always @(*) begin
    case(cnt)
        9: base_add2 <= 0;
        8: base_add2 <= 0;
        7: base_add2 <= 7'b0000001;
        6: base_add2 <= 7'b0000001;
        5: base_add2 <= inst_dim0_size;
        4: base_add2 <= 7'b0000001;
        3: base_add2 <= 7'b0000001;
        2: base_add2 <= inst_dim0_size;
        1: base_add2 <= 7'b0000001;
        0: base_add2 <= 7'b0000001;
        default: base_add2 <= 0;
    endcase
end

assign base_add2_w = {{EW{1'b0}},base_add2};
assign next_base = (base_add1 + base_add2);

assign out_base = (cnt==4'b0000) ?  inst_base : next_base_r;
assign m_ready =  fc ?  (!m1_vlaid || m1_ready) : (!in_loop && s_ready );

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        m1_vlaid <= 1'b0;
    else if(fc )
        m1_vlaid <= m_valid;
    else if(cnt==4'b0 && m1_ready && m_valid)
        m1_vlaid <= 1'b1; 
    else if(cnt[3]==1'b1)
        m1_vlaid <= 0;
    else if(cnt!=4'b0 && m1_ready)
        m1_vlaid <= 1'b1; 
    else
        m1_vlaid <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        in_loop <= 0;
    else if (m_valid && m_ready && !fc)
        in_loop <= 1;
    else if(cnt==4'b1001)
        in_loop <= 0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 4'b0000;
    else if(cnt==4'b1001 )
        cnt <= 4'b0000;
    else if(in_loop && s_ready)
        cnt <= cnt +1'b1;

end

assign m1_bus = {m_inst[IRW*IN-1 : 22],out_base ,m_inst[7:0]};

axi_frs #(.DW(IRW*IN)) i_axi_frs_inst(
    .m_data(m1_bus),
    .m_valid(m1_vlaid),
    .m_ready(m1_ready),

    .s_data(s_inst),
    .s_valid(s_valid),
    .s_ready(s_ready),

    .clk(clk),
    .rst_n(rst_n)
);

assign out_base_r = s_inst[21:8];

    
endmodule