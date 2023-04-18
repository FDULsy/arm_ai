module axi_rs #(parameter DW='d64) (
    input  [DW-1 : 0] m_data,
    input             m_valid,
    output            m_ready,

    output reg [DW-1 : 0] s_data,
    output reg            s_valid,
    input                 s_ready,

    input                 clk,
    input                 rst_n
);

wire [DW-1 : 0] s0_data;
wire            s0_valid;
wire            s0_ready;

avr_frs #(.DW(DW)) i_avr_frs(
    .m_data(m_data),
    .m_valid(m_valid),
    .m_ready(m_ready),

    .s_data(s0_data),
    .s_valid(s0_valid),
    .s_ready(s0_ready),

    .clk(clk),
    .rst_n(rst_n)
)

avr_brs #(.DW(DW)) i_avr_brs(
    .m_data(s0_data),
    .m_valid(s0_valid),
    .m_ready(s0_ready),

    .s_data(s_data),
    .s_valid(s_valid),
    .s_ready(s_ready),

    .clk(clk),
    .rst_n(rst_n)
)
    
endmodule
