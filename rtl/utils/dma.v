module dma #(parameter AW=11) (
    input [AW-1 : 0] base,
    input [AW-1 : 0] size,
    input [AW-1 : 0] step,
    input            start_valid,
    output           start_ready,

    output reg [AW-1 : 0] s_addr,
    output reg        s_first,
    output reg        s_last,   
    output reg        s_valid,
    input             s_ready,

    input             clk,
    input             rst_n     
);
    
reg [AW-1 : 0] cnt;
reg [AW-1 : 0] step_r;

assign start_ready = (~s_valid) || (s_ready && s_last);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        step_r <= 1'b0;
    else if(start_valid && start_ready) 
        step_r <= step;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        s_addr <= 0;
        cnt <= 0;
    end
    else if(start_valid && start_ready) begin
        s_addr <= base;
        cnt <= size;
    end
    else if(s_valid && s_ready) begin
        s_addr <= s_addr + step_r;
        cnt < cnt -1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_valid <= 1'b0;
    else if(start_valid && start_ready)
        s_valid <= 1'b1;
    else if(s_ready && (cnt==0))
        s_valid <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_first <= 1'b0;
    else if(start_valid && start_ready)
        s_first <= 1'b1;
    else if(s_ready)
        s_first <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        s_last <= 1'b0;
    else if(start_valid && start_ready && (size==0))
        s_last <= 1'b1;
    else if(s_ready && (cnt==1))
        s_last <= 1'b1;
    else if(s_ready)
        s_last <= 1'b0;
end

endmodule