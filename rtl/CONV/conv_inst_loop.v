module conv_inst_loop #(
    parameter IRW=30,IN=3,AW=14   
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

wire fc;
assign fc= m_inst[0];
wire [AW-1 : 0] inst_base;
wire [   6 : 0] inst_dim0_size;
wire [AW-1 : 0] out_base;
wire [AW-1 : 0] next_base;
reg  [   6 : 0] base_add1 ;
reg  [   6 : 0] base_add2 ;


always @(*) begin
    case(cnt)
        0: base_add1 <= 0;
    endcase
end

always @(*) begin
    case(cnt)
        0: base_add2 <= 0;
        1: base_add2 <= 7'b0000001;
        2: base_add2 <= 7'b0000001;
        3: base_add2 <= inst_dim0_size;
        4: base_add2 <= 7'b0000001;
        5: base_add2 <= 7'b0000001;
        6: base_add2 <= inst_dim0_size;
        7: base_add2 <= 7'b0000001;
        8: base_add2 <= 7'b0000001;
        default: base_add2 <= 0;
    endcase
end

assign next_base = 


reg    [3:0] cnt    ;
wire m1_vlaid;
wire m1_ready
assign m_ready = (~s_valid) | (cnt=4'b0 && m1_ready);



always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        m1_vlaid <= 1'b0;
    else if(m_valid && m_ready)
        m1_vlaid <= 1'b1;
    else if((cnt != 4'b0) && fc )
        m1_vlaid <= 1'b1;
    else
        m1_vlaid <= 0; 
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 0;
    else if(m_valid && m_ready && fc)
        cnt <= 4'b9;
    else if(s_ready && fc)
        cnt <= cnt - 1'b1;
    else if(!fc)
        cnt <= 0;
    else
        cnt <= cnt;
end


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