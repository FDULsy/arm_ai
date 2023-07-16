module camera2sdram #(
    parameter H_WIDTH      = 112,
    parameter V_WIDTH      = 112,
    parameter P_LINE_WIDTH = 7 
)(
    //camera interface
    input  wire        PCLK       ,
    input  wire        RSTn       ,
    input  wire        VSYNC      ,
    input  wire        HREF       ,
    input  wire [ 7:0] PIC_DATA   ,
    //  to ai core interface
    output  reg        data_valid ,
    output wire [15:0] data_out   ,
    input  wire        r_clk      ,
    input  wire        rd_ready 
);

reg [ 1:0] curr_state  , next_state   ;
reg        RSTn_dly    , RSTn_dly2    ;
reg        rst_n_dly   , rst_n_dly2   ;
reg        rd_ready_dly, rd_ready_dly2;
reg [15:0] wr_data                    ;
reg        wr_en_tmp   , wr_en        ;
reg        rd_en       , HREF_dly     ;
wire       empty_flag  , HREF_neg     ;
wire       wr_line_end ;

reg [P_LINE_WIDTH - 1: 0] p_line_cnt; 
//================================================
//    state      |          description
//================================================
//   IDLE        | waitting for write picture data     
//   WR_PIC      | write data to fifo
//   WR_PIC_END  | complect one pic store
//================================================
localparam IDLE       = 2'h0;
localparam WR_PIC     = 2'h1;
localparam WR_PIC_END = 2'h3;
//================================================
//  rst delay 2
//================================================
always@(posedge PCLK)begin
  RSTn_dly  <= RSTn    ;
  RSTn_dly2 <= RSTn_dly;
end

always @(posedge r_clk) begin
  rst_n_dly  <= RSTn     ;
  rst_n_dly2 <= rst_n_dly;
end

always@(posedge PCLK or negedge RSTn_dly2)begin
  if(RSTn_dly2 == 1'b0)
    HREF_dly <= 1'b0;
  else
    HREF_dly <= HREF;
end
assign HREF_neg = HREF_dly & ~HREF;
//================================================
//  state transform
//================================================

always@(posedge PCLK or negedge RSTn_dly2)begin
  if(RSTn_dly2 == 1'b0)
    curr_state <= IDLE;
  else
    curr_state <= next_state;
end

always@(*)begin
  case(curr_state)
    IDLE       : next_state = ((VSYNC == 1'b1) && (rd_ready_dly2 == 1'b1)) ?  WR_PIC     : IDLE      ;
    WR_PIC     : next_state = (wr_line_end == 1'b1                       ) ?  WR_PIC_END : WR_PIC    ;
    WR_PIC_END : next_state = (rd_ready_dly2 == 1'b0                     ) ?  IDLE       : WR_PIC_END; 
    default    : next_state = IDLE;
  endcase
end

//===============================================
// p_line_cnt
//===============================================
always@(posedge PCLK or negedge RSTn_dly2)begin
  if(RSTn_dly2 == 1'b0)
    p_line_cnt <= 'h0;
  else if(p_line_cnt == V_WIDTH)
    p_line_cnt <= 'h0;
  else if( curr_state == WR_PIC)
    p_line_cnt <= (HREF_neg == 1'b1) ? p_line_cnt + 1'b1 : p_line_cnt;
  else
    p_line_cnt <= 'h0;
end
assign wr_line_end = (p_line_cnt == V_WIDTH) ? 1'b1 : 1'b0;
//===============================================
// rd_ready delay
//===============================================
always@(posedge PCLK or negedge RSTn_dly2)begin
  if(RSTn_dly2 == 1'b0)begin
    rd_ready_dly  <= 1'b0;
    rd_ready_dly2 <= 1'b0;
  end
  else begin
    rd_ready_dly  <= rd_ready    ;
    rd_ready_dly2 <= rd_ready_dly;
  end
end
//===============================================
// WR_FIFO write interface
//===============================================
always @(posedge PCLK or negedge RSTn_dly2) begin
  if(RSTn_dly2 == 1'b0)
    wr_en_tmp <= 1'b0;
  else if( (curr_state == WR_PIC) && (HREF == 1'b1) )
    wr_en_tmp <= ~wr_en_tmp;
end

always@(posedge PCLK or negedge RSTn_dly2)begin
  if(RSTn_dly2 == 1'b0)
    wr_en <= 1'b0;
  else
    wr_en <= wr_en_tmp;
end

always @(posedge PCLK or negedge RSTn_dly2) begin
  if(RSTn_dly2 == 1'b0)
    wr_data <= 16'h0;
  else if(curr_state == WR_PIC)
    wr_data <= (wr_en_tmp == 1'b0) ? {wr_data[15:8],PIC_DATA} : {PIC_DATA,wr_data[7:0]};
  else
    wr_data <= 16'h0;
end

//================================================
// wr_fifo read interface
//================================================
always @(posedge r_clk or negedge rst_n_dly2) begin
  if(rst_n_dly2 == 1'b0)
    rd_en <= 1'b0;
  else if(empty_flag == 1'b0)// fifo is not empty
    rd_en <= 1'b1;
  else
    rd_en <= 1'b0;
end

always @(posedge r_clk or negedge rst_n_dly2) begin
  if(rst_n_dly2 == 1'b0)
    data_valid <= 1'b0;
  else if(empty_flag == 1'b0)// fifo is not empty
    data_valid <= rd_en;
  else
    data_valid <= 1'b0;
end

wr_fifo u_wr_fifo(
   .rst        ( ~RSTn     ),
   .di         ( wr_data   ),
   .clkw       ( PCLK      ),
   .we         ( wr_en     ),
   .clkr       ( r_clk     ),
   .re         ( rd_en     ),
   .do         ( data_out  ),
   .empty_flag ( empty_flag)
);

endmodule
