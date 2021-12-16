`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/17 12:07:22
// Design Name: 
// Module Name: sdp_ram
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


module sdp_ram
#(
  parameter ADDR_WIDTH = 9,
  parameter DATA_WIDTH = 32
  )
  (
  input  wire                     wr_clk,
  input  wire [(ADDR_WIDTH-1):0]  wr_addr,
  input  wire [DATA_WIDTH-1:0]    data_in,
  input  wire                     wr_allow,
  input  wire                     rd_clk,
  input  wire                     rd_sreset,
  input  wire [(ADDR_WIDTH-1):0]  rd_addr,
  output wire [DATA_WIDTH-1:0]    data_out,
  input  wire                     rd_allow);

  localparam RAM_DEPTH = 2 ** ADDR_WIDTH;
  reg [DATA_WIDTH-1:0] ram [RAM_DEPTH-1:0];

  wire [DATA_WIDTH-1:0] wr_data;
  reg  [DATA_WIDTH-1:0] rd_data;

  wire rd_allow_int;

  assign wr_data  = data_in;

  assign data_out = rd_data;

  // Block RAM must be enabled for synchronous reset to work.
  assign rd_allow_int = (rd_allow | rd_sreset);

//----------------------------------------------------------------------
 // Infer BRAMs and connect them
 // appropriately.
//--------------------------------------------------------------------//   

  always @(posedge wr_clk)
   begin
     if (wr_allow) begin
       ram[wr_addr] <= wr_data;
     end
   end

  always @(posedge rd_clk)
   begin
     if (rd_allow_int) begin
       if (rd_sreset) begin
         rd_data <= 0;
       end
       else begin
         rd_data <= ram[rd_addr];
       end
     end
   end

endmodule
