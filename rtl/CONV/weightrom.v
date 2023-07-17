//created by Duanjiali on 2023.07.10
//
//
module weightrom#(
  parameter FC_NUM_WIDTH    =   7,
  parameter LRAM_DATA_WIDTH =   8,
  parameter LRAM_ADDR_WIDTH =   8,
  parameter BRAM_DATA_WIDTH =   9,
  parameter BRAM_ADDR_WIDTH =  10,
  parameter DATA_WIDTH      = 392,
  parameter BASE_ADDRB      = 512
)(
  input  wire                     clk        ,
  input  wire                     rst_n      ,
  
  input  wire                     fc_start   ,
  input  wire                     fc_clear   ,
  input  wire [FC_NUM_WIDTH -1:0] fc_accu_num,
  output  reg                     data_valid ,
  output  reg [  DATA_WIDTH -1:0] weight_data
);

reg  [FC_NUM_WIDTH    -1:0] fc_accu_cnt;
reg                         addr_add_en, addr_add_en_dly;

reg  [BRAM_ADDR_WIDTH -1:0] addra0 , addra10, addrb0 , addrb10; 
reg  [BRAM_ADDR_WIDTH -1:0] addra1 , addra11, addrb1 , addrb11;
reg  [BRAM_ADDR_WIDTH -1:0] addra2 , addra12, addrb2 , addrb12;
reg  [BRAM_ADDR_WIDTH -1:0] addra3 , addra13, addrb3 , addrb13;
reg  [BRAM_ADDR_WIDTH -1:0] addra4 , addra14, addrb4 , addrb14;
reg  [BRAM_ADDR_WIDTH -1:0] addra5 , addra15, addrb5 , addrb15;
reg  [BRAM_ADDR_WIDTH -1:0] addra6 , addra16, addrb6 , addrb16;
reg  [BRAM_ADDR_WIDTH -1:0] addra7 , addra17, addrb7 , addrb17;
reg  [BRAM_ADDR_WIDTH -1:0] addra8 , addra18, addrb8 , addrb18;
reg  [BRAM_ADDR_WIDTH -1:0] addra9 , addra19, addrb9 , addrb19;
reg  [BRAM_ADDR_WIDTH -1:0] addra20, addra21, addrb20, addrb21;
wire [LRAM_ADDR_WIDTH -1:0] addr45 , addr46 , addr47 , addr48 ;

wire [LRAM_DATA_WIDTH-1:0] lram_data0, lram_data10, lram_data20, lram_data30, lram_data40; 
wire [LRAM_DATA_WIDTH-1:0] lram_data1, lram_data11, lram_data21, lram_data31, lram_data41;
wire [LRAM_DATA_WIDTH-1:0] lram_data2, lram_data12, lram_data22, lram_data32, lram_data42;
wire [LRAM_DATA_WIDTH-1:0] lram_data3, lram_data13, lram_data23, lram_data33, lram_data43;
wire [LRAM_DATA_WIDTH-1:0] lram_data4, lram_data14, lram_data24, lram_data34, lram_data44;
wire [LRAM_DATA_WIDTH-1:0] lram_data5, lram_data15, lram_data25, lram_data35, lram_data45;
wire [LRAM_DATA_WIDTH-1:0] lram_data6, lram_data16, lram_data26, lram_data36, lram_data46;
wire [LRAM_DATA_WIDTH-1:0] lram_data7, lram_data17, lram_data27, lram_data37, lram_data47;
wire [LRAM_DATA_WIDTH-1:0] lram_data8, lram_data18, lram_data28, lram_data38, lram_data48;
wire [LRAM_DATA_WIDTH-1:0] lram_data9, lram_data19, lram_data29, lram_data39;

wire [BRAM_DATA_WIDTH-1:0] bram_data_a0 , bram_data_a10, bram_data_b0 , bram_data_b10; 
wire [BRAM_DATA_WIDTH-1:0] bram_data_a1 , bram_data_a11, bram_data_b1 , bram_data_b11;
wire [BRAM_DATA_WIDTH-1:0] bram_data_a2 , bram_data_a12, bram_data_b2 , bram_data_b12;
wire [BRAM_DATA_WIDTH-1:0] bram_data_a3 , bram_data_a13, bram_data_b3 , bram_data_b13;
wire [BRAM_DATA_WIDTH-1:0] bram_data_a4 , bram_data_a14, bram_data_b4 , bram_data_b14;
wire [BRAM_DATA_WIDTH-1:0] bram_data_a5 , bram_data_a15, bram_data_b5 , bram_data_b15;
wire [BRAM_DATA_WIDTH-1:0] bram_data_a6 , bram_data_a16, bram_data_b6 , bram_data_b16;
wire [BRAM_DATA_WIDTH-1:0] bram_data_a7 , bram_data_a17, bram_data_b7 , bram_data_b17;
wire [BRAM_DATA_WIDTH-1:0] bram_data_a8 , bram_data_a18, bram_data_b8 , bram_data_b18;
wire [BRAM_DATA_WIDTH-1:0] bram_data_a9 , bram_data_a19, bram_data_b9 , bram_data_b19;
wire [BRAM_DATA_WIDTH-1:0] bram_data_a20, bram_data_a21, bram_data_b20, bram_data_b21;

//==========================================
//  addr add en
//==========================================
always@(posedge clk or negedge rst_n)begin
  if(rst_n == 1'b0)
    addr_add_en <= 1'b0;
  else if(fc_start == 1'b1)
    addr_add_en <= 1'b1;
  else if(fc_accu_cnt == fc_accu_num -1)
    addr_add_en <= 1'b0;
end

always@(posedge clk or negedge rst_n)begin
  if(rst_n == 1'b0)begin
    addr_add_en_dly <= 1'b0;
    data_valid      <= 1'b0;
  end
  else begin
    addr_add_en_dly <= addr_add_en    ;
    data_valid      <= addr_add_en_dly;
  end
end

//=========================================
// fc_accu_cnt
// ========================================
always@(posedge clk or negedge rst_n)begin
  if(rst_n == 1'b0)
    fc_accu_cnt <= 'h0;
  else if(fc_accu_cnt == fc_accu_num)
    fc_accu_cnt <= 'h0;
  else if(addr_add_en == 1'b1)
    fc_accu_cnt <= fc_accu_cnt + 1'b1;
end
//========================================
//addr add
//========================================
always@(posedge clk or negedge rst_n)begin
  if(rst_n == 1'b0)begin
    addra0  <= 'h0;   addrb0  <= 'h200; 
    addra1  <= 'h0;   addrb1  <= 'h200;
    addra2  <= 'h0;   addrb2  <= 'h200;
    addra3  <= 'h0;   addrb3  <= 'h200;
    addra4  <= 'h0;   addrb4  <= 'h200;
    addra5  <= 'h0;   addrb5  <= 'h200;
    addra6  <= 'h0;   addrb6  <= 'h200;
    addra7  <= 'h0;   addrb7  <= 'h200;
    addra8  <= 'h0;   addrb8  <= 'h200;
    addra9  <= 'h0;   addrb9  <= 'h200;
    addra10 <= 'h0;   addrb10 <= 'h200;
    addra11 <= 'h0;   addrb11 <= 'h200;
    addra12 <= 'h0;   addrb12 <= 'h200;
    addra13 <= 'h0;   addrb13 <= 'h200;
    addra14 <= 'h0;   addrb14 <= 'h200;
    addra15 <= 'h0;   addrb15 <= 'h200;
    addra16 <= 'h0;   addrb16 <= 'h200;
    addra17 <= 'h0;   addrb17 <= 'h200;
    addra18 <= 'h0;   addrb18 <= 'h200;
    addra19 <= 'h0;   addrb19 <= 'h200;
    addra20 <= 'h0;   addrb20 <= 'h200;
    addra21 <= 'h0;   addrb21 <= 'h200;
  end
  else if( fc_clear == 1'b1 )begin
    addra0  <= 'h0;   addrb0  <= 'h200; 
    addra1  <= 'h0;   addrb1  <= 'h200;
    addra2  <= 'h0;   addrb2  <= 'h200;
    addra3  <= 'h0;   addrb3  <= 'h200;
    addra4  <= 'h0;   addrb4  <= 'h200;
    addra5  <= 'h0;   addrb5  <= 'h200;
    addra6  <= 'h0;   addrb6  <= 'h200;
    addra7  <= 'h0;   addrb7  <= 'h200;
    addra8  <= 'h0;   addrb8  <= 'h200;
    addra9  <= 'h0;   addrb9  <= 'h200;
    addra10 <= 'h0;   addrb10 <= 'h200;
    addra11 <= 'h0;   addrb11 <= 'h200;
    addra12 <= 'h0;   addrb12 <= 'h200;
    addra13 <= 'h0;   addrb13 <= 'h200;
    addra14 <= 'h0;   addrb14 <= 'h200;
    addra15 <= 'h0;   addrb15 <= 'h200;
    addra16 <= 'h0;   addrb16 <= 'h200;
    addra17 <= 'h0;   addrb17 <= 'h200;
    addra18 <= 'h0;   addrb18 <= 'h200;
    addra19 <= 'h0;   addrb19 <= 'h200;
    addra20 <= 'h0;   addrb20 <= 'h200;
    addra21 <= 'h0;   addrb21 <= 'h200;
  end
  else if( addr_add_en == 1'b1 )begin
    addra0  <= addra0  + 1'b1;   addrb0  <= addrb0  + 1'b1; 
    addra1  <= addra1  + 1'b1;   addrb1  <= addrb1  + 1'b1;
    addra2  <= addra2  + 1'b1;   addrb2  <= addrb2  + 1'b1;
    addra3  <= addra3  + 1'b1;   addrb3  <= addrb3  + 1'b1;
    addra4  <= addra4  + 1'b1;   addrb4  <= addrb4  + 1'b1;
    addra5  <= addra5  + 1'b1;   addrb5  <= addrb5  + 1'b1;
    addra6  <= addra6  + 1'b1;   addrb6  <= addrb6  + 1'b1;
    addra7  <= addra7  + 1'b1;   addrb7  <= addrb7  + 1'b1;
    addra8  <= addra8  + 1'b1;   addrb8  <= addrb8  + 1'b1;
    addra9  <= addra9  + 1'b1;   addrb9  <= addrb9  + 1'b1;
    addra10 <= addra10 + 1'b1;   addrb10 <= addrb10 + 1'b1;
    addra11 <= addra11 + 1'b1;   addrb11 <= addrb11 + 1'b1;
    addra12 <= addra12 + 1'b1;   addrb12 <= addrb12 + 1'b1;
    addra13 <= addra13 + 1'b1;   addrb13 <= addrb13 + 1'b1;
    addra14 <= addra14 + 1'b1;   addrb14 <= addrb14 + 1'b1;
    addra15 <= addra15 + 1'b1;   addrb15 <= addrb15 + 1'b1;
    addra16 <= addra16 + 1'b1;   addrb16 <= addrb16 + 1'b1;
    addra17 <= addra17 + 1'b1;   addrb17 <= addrb17 + 1'b1;
    addra18 <= addra18 + 1'b1;   addrb18 <= addrb18 + 1'b1;
    addra19 <= addra19 + 1'b1;   addrb19 <= addrb19 + 1'b1;
    addra20 <= addra20 + 1'b1;   addrb20 <= addrb20 + 1'b1;
    addra21 <= addra21 + 1'b1;   addrb21 <= addrb21 + 1'b1;
  end
end
//========================================================
// LRAM ADDR
//========================================================
assign addr0 = addra0;
assign addr1 = addra1;
assign addr2 = addra2;
assign addr3 = addra3;
assign addr4 = addra4;

//========================================================
// output select
//========================================================

always@(posedge clk or negedge rst_n)begin
  if(rst_n == 1'b0)
    weight_data <= 'h0;
  else if(addra0[9:8] != 2'h0)begin
    weight_data[391 :384] = lram_data48; 
    weight_data[383 :376] = lram_data47;
    weight_data[375 :368] = lram_data46;
    weight_data[367 :360] = lram_data45;
    weight_data[359 :352] = lram_data44;
    weight_data[351 :344] = lram_data43;
    weight_data[343 :336] = lram_data42;
    weight_data[335 :328] = lram_data41;
    weight_data[327 :320] = lram_data40;
    weight_data[319 :312] = lram_data39;
    weight_data[311 :304] = lram_data38;
    weight_data[303 :296] = lram_data37;
    weight_data[295 :288] = lram_data36;
    weight_data[287 :280] = lram_data35;
    weight_data[279 :272] = lram_data34;
    weight_data[271 :264] = lram_data33;
    weight_data[263 :256] = lram_data32;
    weight_data[255 :248] = lram_data31;
    weight_data[247 :240] = lram_data30;
    weight_data[239 :232] = lram_data29;
    weight_data[231 :224] = lram_data28;
    weight_data[223 :216] = lram_data27;
    weight_data[215 :208] = lram_data26; 
    weight_data[207 :200] = lram_data25;
    weight_data[199 :192] = lram_data24; 
    weight_data[191 :184] = lram_data23;
    weight_data[183 :176] = lram_data22;
    weight_data[175 :168] = lram_data21;
    weight_data[167 :160] = lram_data20;
    weight_data[159 :152] = lram_data19;
    weight_data[151 :144] = lram_data18;
    weight_data[143 :136] = lram_data17;
    weight_data[135 :128] = lram_data16;
    weight_data[127 :120] = lram_data15;
    weight_data[119 :112] = lram_data14;
    weight_data[111 :104] = lram_data13;
    weight_data[103 : 96] = lram_data12;
    weight_data[ 95 : 88] = lram_data11;
    weight_data[ 87 : 80] = lram_data10;
    weight_data[ 79 : 72] = lram_data9 ; 
    weight_data[ 71 : 64] = lram_data8 ; 
    weight_data[ 63 : 56] = lram_data7 ;
    weight_data[ 55 : 48] = lram_data6 ;
    weight_data[ 47 : 40] = lram_data5 ;
    weight_data[ 39 : 32] = lram_data4 ;
    weight_data[ 31 : 24] = lram_data3 ;
    weight_data[ 23 : 16] = lram_data2 ;
    weight_data[ 15 :  8] = lram_data1 ;
    weight_data[  7 :  0] = lram_data0 ;
  end
  else begin
    weight_data[391 :384] = {bram_data_b21[7:3],bram_data_a21[7:3]}; 
    weight_data[383 :376] = {bram_data_b21[2:0],bram_data_b20[8:4]};
    weight_data[375 :368] = {bram_data_b20[3:0],bram_data_b19[8:5]};
    weight_data[367 :360] = {bram_data_b19[4:0],bram_data_b18[8:6]};
    weight_data[359 :352] = {bram_data_b18[5:0],bram_data_b17[8:7]};
    weight_data[351 :344] = {bram_data_b17[6:0],bram_data_b16[  8]};
    weight_data[343 :336] =  bram_data_b16[7:0]                    ;
    weight_data[335 :328] =  bram_data_b15[8:1]                    ;
    weight_data[327 :320] = {bram_data_b15[  0],bram_data_b14[8:2]};
    weight_data[319 :312] = {bram_data_b14[1:0],bram_data_b13[8:3]};
    weight_data[311 :304] = {bram_data_b13[2:0],bram_data_b12[8:4]};
    weight_data[303 :296] = {bram_data_b12[3:0],bram_data_b11[8:5]};
    weight_data[295 :288] = {bram_data_b11[4:0],bram_data_b10[8:6]};
    weight_data[287 :280] = {bram_data_b10[5:0],bram_data_b9 [8:7]};
    weight_data[279 :272] = {bram_data_b9 [6:0],bram_data_b8 [  8]};
    weight_data[271 :264] =  bram_data_b8 [7:0]                    ;
    weight_data[263 :256] =  bram_data_b7 [8:1]                    ;
    weight_data[255 :248] = {bram_data_b7 [  0],bram_data_b6[8:2]} ;
    weight_data[247 :240] = {bram_data_b6 [1:0],bram_data_b5[8:3]} ;
    weight_data[239 :232] = {bram_data_b5 [2:0],bram_data_b4[8:4]} ;
    weight_data[231 :224] = {bram_data_b4 [3:0],bram_data_b3[8:5]} ;
    weight_data[223 :216] = {bram_data_b3 [4:0],bram_data_b2[8:6]} ;
    weight_data[215 :208] = {bram_data_b2 [5:0],bram_data_b1[8:7]} ; 
    weight_data[207 :200] = {bram_data_b1 [6:0],bram_data_b0[  8]} ;
    weight_data[199 :192] =  bram_data_b0 [7:0]                    ; 
    weight_data[191 :184] = {bram_data_a21[2:0],bram_data_a20[8:4]};
    weight_data[183 :176] = {bram_data_a20[3:0],bram_data_a19[8:5]};
    weight_data[175 :168] = {bram_data_a19[4:0],bram_data_a18[8:6]};
    weight_data[167 :160] = {bram_data_a18[5:0],bram_data_a17[8:7]};
    weight_data[159 :152] = {bram_data_a17[6:0],bram_data_a16[  8]};
    weight_data[151 :144] =  bram_data_a16[7:0]                    ;
    weight_data[143 :136] =  bram_data_a15[8:1]                    ;
    weight_data[135 :128] = {bram_data_a15[  0],bram_data_a14[8:2]};
    weight_data[127 :120] = {bram_data_a14[1:0],bram_data_a13[8:3]};
    weight_data[119 :112] = {bram_data_a13[2:0],bram_data_a12[8:4]};
    weight_data[111 :104] = {bram_data_a12[3:0],bram_data_a11[8:5]};
    weight_data[103 : 96] = {bram_data_a11[4:0],bram_data_a10[8:6]};
    weight_data[ 95 : 88] = {bram_data_a10[5:0],bram_data_a9 [8:7]};
    weight_data[ 87 : 80] = {bram_data_a9 [6:0],bram_data_a8 [  8]};
    weight_data[ 79 : 72] =  bram_data_a8 [7:0]                    ; 
    weight_data[ 71 : 64] =  bram_data_a7 [8:1]                    ; 
    weight_data[ 63 : 56] = {bram_data_a7 [  0],bram_data_a6[8:2]} ;
    weight_data[ 55 : 48] = {bram_data_a6 [1:0],bram_data_a5[8:3]} ;
    weight_data[ 47 : 40] = {bram_data_a5 [2:0],bram_data_a4[8:4]} ;
    weight_data[ 39 : 32] = {bram_data_a4 [3:0],bram_data_a3[8:5]} ;
    weight_data[ 31 : 24] = {bram_data_a3 [4:0],bram_data_a2[8:6]} ;
    weight_data[ 23 : 16] = {bram_data_a2 [5:0],bram_data_a1[8:7]} ;
    weight_data[ 15 :  8] = {bram_data_a1 [6:0],bram_data_a0[  8]} ;
    weight_data[  7 :  0] =  bram_data_a0 [7:0]                    ;
  end
end

endmodule
