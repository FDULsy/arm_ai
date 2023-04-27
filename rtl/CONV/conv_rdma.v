module crdma #(parameter DW=64,
                         IW=32,
                         IN = 6     ,
                         IPW = IN*DW ,
                         ID = 4'h0 
) (
    //input [IW-1 : 0]  inst_m_data,
    //input             inst_m_valid,
    //output            inst_m_ready,

    output [IW-1 : 0] inst_s_data,
    output            inst_s_valid,
    input             inst_s_ready,

    input [DW-1 : 0]  clm0_m_data,
    input             clm0_m_first,
    input             clm0_m_last,
    input             clm0_m_valid,
    output            clm0_m_ready,
    output [DW-1 : 0] clm0_s_data,
    output            clm0_s_valid,
    input             clm0_s_ready,

    input [DW-1 : 0]  clm1_m_data,
    input             clm1_m_first,
    input             clm1_m_last,
    input             clm1_m_valid,
    output            clm1_m_ready,
    output [DW-1 : 0] clm1_s_data,
    output            clm1_s_valid,
    input             clm1_s_ready,

    input clk,
    input rst_n
);

wire inst_m_data;
wire inst_m_valid;
wire inst_m_ready;

wire [IPW-1:0] local_inst;
reg  [IPW-1:0] local_inst_r;
wire [1:0] start_prior;
wire start_valid;
reg start_ready;

inst_fetch i_inst_fetch(
    .instgen_s_data(inst_m_data),
    .instgen_s_valid(inst_m_valid),
    .instgen_s_ready(inst_m_ready),
    .clk(clk),
    .rst_n(rst_n)
);

inst_parse i_inst_parse(
    .inst_m_data(inst_m_data),
    .inst_m_valid(inst_m_valid),
    .inst_m_ready(inst_m_ready),

    .inst_s_data(),
    .inst_s_valid(),
    .inst_s_ready()

    .local_inst(local_inst),
    .start_prior(start_prior),
    .start_valid(start_valid),
    .start_ready(start_ready),

    .clk(clk),
    .rst_n(rst_n)
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        start_ready <=1'b1;
        local_inst_r<=0;
    end
    else if(start_valid) begin
        
    end
end


axi_frs #(.DW(IW)) i_axi_frs(
    .m_data(inst_m_data),
    .m_valid(inst_m_valid),
    .m_ready(inst_m_ready),

    .s_data()
)




    
endmodule