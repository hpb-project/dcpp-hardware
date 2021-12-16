`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/03 14:36:47
// Design Name: 
// Module Name: register
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


module register(
input         rst,
input         clk,
input         en,
input [11:0]  addr,
input [3:0]   we,
input [31:0]  din,
output [31:0] dout,
input  [31:0] alarm_in1
   );
   
reg [31:0] rdata;   

	always@(posedge rst or posedge clk)
	begin
		if(rst)begin
			rdata <= 32'd0;
		end	else if(en & !we)begin
			case(addr)
				12'h000:	rdata <= 32'h00008000;
				12'h004:	rdata <= 32'h00020000;
				12'h0c0:    rdata <= alarm_in1;
				default:	rdata <= 32'd0;
			endcase
		end
	end
	

assign dout = rdata;
   
endmodule
