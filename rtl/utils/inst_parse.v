module inst_parse #(parameter IW  = 36    ,
                              IN  = 3     ,
                              IRW = 30,
                              IPW = IRW*IN ,
                              ID = 2'b0  
) (
    //{run_1, id_2, inst_addr_2, res31}
    
    input [IW-1 : 0] inst_m_data,
    input            inst_m_valid,
    output           inst_m_ready,

    output [IW-1 : 0] inst_s_data,
    output            inst_s_valid,
    input             inst_s_ready,

    output [IPW-1 : 0] local_inst,
    //output reg [1:0]  start_prior,
    output reg        start_valid,
    input             start_ready,
    
    input             clk,
    input             rst_n
);

reg [IRW-1 : 0] local_inst_r [IN-1 : 0];

wire inst_run;
wire  inst_id;
wire [1:0] inst_addr;
//wire [1:0] inst_prior;
wire [27:0] inst_data;
wire inst_start_en;

wire [IW-1:0] inst_s0_data;
wire inst_s0_valid;
wire inst_s0_ready;
wire [IRW-1 : 0] inst_din;

//assign {inst_run, inst_id, inst_addr, inst_prior, inst_rfu, inst_din} = inst_m_data;
assign {inst_run, inst_id, inst_addr,  inst_din} = inst_m_data;
assign inst_start_en=(inst_id==ID) && inst_run;


assign inst_s0_data = inst_m_data;
assign inst_s0_valid = inst_m_valid && (inst_id!=ID);
axi_rs #(.DW(32)) i_axi_rs(
    .m_data(inst_s0_data),
    .m_valid(inst_s0_valid),
    .m_ready(inst_s0_ready),

    .s_data(inst_s_data),
    .s_valid(inst_s_valid),
    .s_ready(inst_s_ready),

    .clk(clk),
    .rst_n(rst_n)
);
assign inst_m_ready = (inst_id==ID) ? ~start_valid : inst_s0_ready;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        start_valid <= 0;
    else if(inst_start_en && inst_m_valid && inst_m_ready)
        start_valid <= 1'b1;
    else if(inst_m_ready)
        start_valid <= 1'b0;
end

// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n)
//         start_prior <= 0;
//     else if(inst_start_en && inst_m_valid && inst_m_ready)
//         start_prior <= inst_prior;
// end

genvar i;
generate
    for(i=0; i<IN;i=i+1) begin: local_inst_load
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n)
                local_inst_r[i] <= 0;
            else if(inst_addr==i) 
                local_inst_r[i] <= inst_din;
        end
        assign local_inst[IPW*i +: IPW] = local_inst_r[i];
    end
endgenerate

    
endmodule
