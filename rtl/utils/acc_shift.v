module acc_shift #(parameter
    DW=22
) (
    input  signed     [DW-1 : 0]      m_data1     ,
    input  signed     [DW-1 : 0]      m_data2     ,
    input             [2    : 0]      m_shift_n   ,
    output signed     [DW-1 : 0]      s_data1     ,
    output signed     [DW-1 : 0]      s_data2     
);

reg  signed   [DW-1 : 0]   d1_r,d2_r   ;


always@(*) begin
    d1_r <= m_data1 >>> m_shift_n;
    d2_r <= m_data2 >>> m_shift_n;
end

// always@(*) begin
//     case(m_shift_n):
//         0:begin
//             d1_r    <= m_data1  ;
//             d2_r    <= m_data2  ;
//         end
//         1:begin
//             d1_r    <= {m_data1[DW],m_data1[1 +: DW-1]};
//             d2_r    <= {m_data2[DW],m_data2[1 +: DW-1]};
//         end
//         2:begin
//             d1_r    <= {2{m_data1[DW]},m_data1[2 +: DW-2]};
//             d2_r    <= {2{m_data2[DW]},m_data2[2 +: DW-2]};
//         end
//         3:begin
//             d1_r    <= {3{m_data1[DW]},m_data1[3 +: DW-3]};
//             d2_r    <= {3{m_data2[DW]},m_data2[3 +: DW-3]};
//         end
//         4:begin
//             d1_r    <= {4{m_data1[DW]},m_data1[4 +: DW-4]};
//             d2_r    <= {4{m_data2[DW]},m_data2[4 +: DW-4]};
//         end
//         5:begin
//             d1_r    <= {5{m_data1[DW]},m_data1[5 +: DW-5]};
//             d2_r    <= {5{m_data2[DW]},m_data2[5 +: DW-5]};
//         end
//         6:begin
//             d1_r    <= {6{m_data1[DW]},m_data1[6 +: DW-6]};
//             d2_r    <= {6{m_data2[DW]},m_data2[6 +: DW-6]};
//         end
//         7:begin
//             d1_r    <= {7{m_data1[DW]},m_data1[7 +: DW-7]};
//             d2_r    <= {7{m_data2[DW]},m_data2[7 +: DW-7]};
//         end
//     endcase
// end   

assign s_data1 = d1_r;
assign s_data2 = d2_r;

endmodule