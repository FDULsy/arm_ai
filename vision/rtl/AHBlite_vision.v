module AHBlite_vision #(parameter CLAS = 5,
                              MODI = 6,
                              MODN = CLAS*MODI,//30
                              ADDW = 14
)(
    //AHB
    input               HSEL            ,
    input   [31:0]      HADDR           ,
    input   [1:0]       HTRANS          ,
    input   [2:0]       HSIZE           ,
    input   [3:0]       HPROT           ,
    input               HWRITE          ,
    input   [31:0]      HWDATA          ,
    input               HREADY          ,

    output  [31:0]      HRDATA          ,
    output              HREADYOUT       ,
    output              HRESP           ,

    //camera
    input               pic_store_valid ,//图片存储完成
    input   [255:0]     data_in         ,
    output  [10:0]      addr            ,
    output              read_finish     ,//图片读出完成



    //resout
    output  reg         ask             ,
    // output  [5:0]       res             , 
    // output              res_gen_done    ,//计算完成，向M0发起请求
    // input               res_get_done    ,//M0成功接走数据

    //sys
    input               clk             ,
    input               rst_n
);

//wire read_en;
//assign read_en=HSEL&HTRANS[1]&(~HWRITE)&HREADY;
assign HREADYOUT = 1'b1;
assign HRESP = 1'b0;

reg pic_store_valid_r1,pic_store_valid_r2;

reg [1:0] state;//00:idel 01：读前16行 10：读后
reg [1:0] state_r1,state_r2,state_r3;

wire [9:0] addr0,addr1;
wire [15:0] binary;

wire [MODN*16-1 : 0] mod_bus;
wire [MODN*4-1  : 0] diff_bus;

wire [MODN*ADDW-1 :0] cnt_bus;

wire [2:0] res;
reg [31:0] rdata_r;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        pic_store_valid_r1 <= 0;
        pic_store_valid_r2 <= 0;
    end
    else begin
        pic_store_valid_r1 <= pic_store_valid;
        pic_store_valid_r2 <= pic_store_valid_r1;
    end
end

//reg res_update;
//
// always @(posedge clk or negedge rst_n) begin
//     if(!rst_n)
//         res_update <= 0;
//     else if(read_en)
//         res_update <= 1'b1;
//     else 
//         res_update <= 1'b0;
// end
//fms
wire pic_store_valid_pose;
assign pic_store_valid_pose = ~pic_store_valid_r2 & pic_store_valid_r1;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        state <= 2'b00;
    else if((state== 2'b00 && pic_store_valid_pose) || (state==2'b11 && pic_store_valid_pose))
        state <= 2'b01;
    else if((state==2'b01 && addr0==10'b0001111111))
        state <= 2'b10; 
    else if(state==2'b10 && addr==11'b11111111110)
        state <= 2'b11;
    else
        state <= state;  
end

assign read_finish = state==2'b11;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_r1 <= 0;
        state_r2 <= 0;
        state_r3 <= 0;
    end
    else begin
        state_r1 <= state;
        state_r2 <= state_r1;
        state_r3 <= state_r2;
    end
end


pic_dma i_pic_dma(
    .state(state),
    .addr(addr),
    .clk(clk),
    .rst_n(rst_n)
);

mod_dma i_mod_dma(
    .state(state),
    .addr0(addr0),//直接自增
    .addr1(addr1),//等待16行

    .clk(clk),
    .rst_n(rst_n)
);

modmem_top i_modmem_top(
    .addr0(addr0),
    .addr1(addr1),
    .mod_bus(mod_bus),
    .clk(clk),
    .rst_n(rst_n)
);


rgb2b i_rgb2b(
    .data_in(data_in),
    .binary(binary)
);

feature_cmp_top #(.MODN(MODN)) i_feature_cmp_top(
    .state(state),
    .data(binary),
    .mod_bus(mod_bus),
    .diff_bus(diff_bus),
    .clk(clk),
    .rst_n(rst_n)
);//2pai



acc_top #(.MODN(MODN),.ADDW(ADDW))i_acc_top(
    .state(state),
    .state_r3(state_r3),
    .diff_bus(diff_bus),
    .cnt_bus(cnt_bus),

    .clk(clk),
    .rst_n(rst_n)
);//1pai

min_diff_cmp i_min_diff_cmp(
    .state(state),
    .cnt_bus(cnt_bus),
    .res(res),

    .clk(clk),
    .rst_n(rst_n)
);//1pai

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rdata_r <= 0;
    else if(state==2'b11 && state_r3==2'b11)
        rdata_r <= {29'b0,res};
    else 
        rdata_r <= rdata_r;
end

assign HRDATA = rdata_r;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ask <= 0;
    else if(state_r3==2'b10 && state_r2==2'b11 && res != 3'b111)
        ask <= 1'b1;
    else 
        ask <= 0;
end


endmodule