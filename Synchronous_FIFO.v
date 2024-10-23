`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.09.2024 03:15:55
// Design Name: 
// Module Name: Synchronous_FIFO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Synchronous_FIFO
(
input  rst,clk,en,push_in,pop_in,                    //Reset, Clock, Enable and Push-Pop control signals
input  [3:0] threshold,                              //Threshold limit, if pushed data to certain limit
input  [7:0] din,                                    //Input Data Bus
output reg empty,full,overrun,underrun,thre_trigger, //Status Flags
output [7:0] dout                                    //Output Data Bus
);

integer i;
reg  [7:0] mem [15:0]; //FIFO of size 8-bits and depth of 16-bits 
reg  [3:0] waddr = 0;  //Pointer for write address
wire push,pop ; 

// Logic for Empty Flag
always@(posedge clk, posedge rst)
begin
if(rst)
  empty <= 1'b0;
  else
    case({push, pop})
     2'b01: empty <= (~|(waddr)|~en );
     2'b10: empty <= 1'b0;
     default : ;
     endcase
end

// Logic for Full Flag
always@(posedge clk, posedge rst)
begin
if(rst)
  full <= 1'b0;
  else
    case({push, pop})
     2'b10: full <=  (&(waddr) | ~en );
     2'b01: full <= 1'b0;
     default : ;
     endcase
end

assign push = push_in & ~full;
assign pop  = pop_in  & ~empty;
assign dout = mem[0]; // read fifo --> always first element

// Write pointer updation
always@(posedge clk, posedge rst)
begin
if(rst)
            waddr <= 4'h0;
else
         case({push, pop})
         2'b10:
             if(waddr != 4'hf && full == 1'b0)
              waddr <= waddr + 1;
             else
              waddr <= waddr;
         2'b01:
              if(waddr != 0 && empty == 1'b0)
              waddr <= waddr - 1;
              else
              waddr <= waddr;       
         default: ;
         endcase
end

// Memory updation
always@(posedge clk)
begin
case({push, pop})
2'b00: ;
2'b01: begin
        for(i=0;i<14;i=i+1)
        mem[i] <= mem[i+1];
        mem[15] <= 8'h00;
end
2'b10:
       mem[waddr] <= din;
2'b11: begin
        for(i=0;i<14;i=i+1)
        mem[i] <= mem[i+1];
        mem[15] <= 8'h00;
        mem[waddr - 1] <= din;
end
endcase
end


// Logic for Underrun Flag (no read on empty fifo)
always@(posedge clk, posedge rst)
begin
if(rst)
  underrun <= 1'b0;
else if(pop_in == 1'b1 && empty == 1'b1)
  underrun <= 1'b1;
else
  underrun <= 1'b0;
end

// Logic for Overrun Flag (no write on full fifo)
always@(posedge clk, posedge rst)
begin
if(rst)
   overrun <= 1'b0;
  else if(push_in == 1'b1 && full == 1'b1)
   overrun <= 1'b1;
  else
   overrun <= 1'b0; 
end

// Logic for Threshold Flag (if pushed data to certain limit)
always@(posedge clk, posedge rst)
begin
if(rst)
  begin
  thre_trigger <= 1'b0;
  end
  else if(push ^ pop)
  begin
  thre_trigger <= (waddr >= threshold ) ? 1'b1 : 1'b0;
  end
end

endmodule
