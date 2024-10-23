
`timescale 1ns / 1ps



module Synch_FIFO_tb();
reg  rst,clk,en,push_in,pop_in;
reg  [3:0] threshold;
reg  [7:0] din;
wire empty,full,overrun,underrun,thre_trigger;
wire [7:0] dout;

integer i;

initial begin
rst = 0;
clk = 0;
en  = 0;
din = 0;
end

Synchronous_FIFO dut_fifo(rst,clk,en,push_in,pop_in,threshold,din,empty,full,overrun,underrun,thre_trigger,dout);
 
always #5 clk = ~clk;
 
initial begin
rst = 1'b1;
repeat(5)@(posedge clk);

// Write
for(i=0;i<20;i=i+1)
begin
rst       = 1'b0;
push_in   = 1'b1;
din       = $urandom();
pop_in    = 1'b0;
en        = 1'b1;
threshold = 4'ha;
@(posedge clk);
end

// Read
for(i=0;i<20;i=i+1)
begin
rst       = 1'b0;
push_in   = 1'b0;
din       = 0;
pop_in    = 1'b1;
en        = 1'b1;
threshold = 4'ha;
@(posedge clk);
end

end
endmodule
