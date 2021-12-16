`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/04 17:16:53
// Design Name: 
// Module Name: axis_4to1_wapper
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


module axis_4to1_wapper(
 input clki,
 input rsti,
 input [3:0]  s_axis_tvalid,
 output[3:0]  s_axis_tready,
 input [3:0]  s_axis_tlast ,
 input [7:0]  s_axis_tkeep[3:0],
 input [63:0] s_axis_tdata[3:0],
 output        m_axis_tvalid,
 input         m_axis_tready,
 output        m_axis_tlast ,
 output [7:0]  m_axis_tdata,
 output [1:0]  m_axis_tid
    );
wire rstn;

assign rstn = ~rsti;    
    
axis_4to1 u_axis_4to1 (
      .ACLK(clki),                                  // input wire ACLK
      .ARESETN(rstn),                            // input wire ARESETN
      .S00_AXIS_ACLK(clki),                // input wire S00_AXIS_ACLK
      .S01_AXIS_ACLK(clki),                // input wire S01_AXIS_ACLK
      .S02_AXIS_ACLK(clki),                // input wire S02_AXIS_ACLK
      .S03_AXIS_ACLK(clki),                // input wire S03_AXIS_ACLK
      .S00_AXIS_ARESETN(rstn),          // input wire S00_AXIS_ARESETN
      .S01_AXIS_ARESETN(rstn),          // input wire S01_AXIS_ARESETN
      .S02_AXIS_ARESETN(rstn),          // input wire S02_AXIS_ARESETN
      .S03_AXIS_ARESETN(rstn),          // input wire S03_AXIS_ARESETN
      .S00_AXIS_TVALID(s_axis_tvalid[0]),            // input wire S00_AXIS_TVALID
      .S01_AXIS_TVALID(s_axis_tvalid[1]),            // input wire S01_AXIS_TVALID
      .S02_AXIS_TVALID(s_axis_tvalid[2]),            // input wire S02_AXIS_TVALID
      .S03_AXIS_TVALID(s_axis_tvalid[3]),            // input wire S03_AXIS_TVALID
      .S00_AXIS_TREADY(s_axis_tready[0]),            // output wire S00_AXIS_TREADY
      .S01_AXIS_TREADY(s_axis_tready[1]),            // output wire S01_AXIS_TREADY
      .S02_AXIS_TREADY(s_axis_tready[2]),            // output wire S02_AXIS_TREADY
      .S03_AXIS_TREADY(s_axis_tready[3]),            // output wire S03_AXIS_TREADY
      .S00_AXIS_TDATA(s_axis_tdata[0]),              // input wire [63 : 0] S00_AXIS_TDATA
      .S01_AXIS_TDATA(s_axis_tdata[1]),              // input wire [63 : 0] S01_AXIS_TDATA
      .S02_AXIS_TDATA(s_axis_tdata[2]),              // input wire [63 : 0] S02_AXIS_TDATA
      .S03_AXIS_TDATA(s_axis_tdata[3]),              // input wire [63 : 0] S03_AXIS_TDATA
      .S00_AXIS_TKEEP(s_axis_tkeep[0]),              // input wire [7 : 0] S00_AXIS_TKEEP
      .S01_AXIS_TKEEP(s_axis_tkeep[1]),              // input wire [7 : 0] S01_AXIS_TKEEP
      .S02_AXIS_TKEEP(s_axis_tkeep[2]),              // input wire [7 : 0] S02_AXIS_TKEEP
      .S03_AXIS_TKEEP(s_axis_tkeep[3]),              // input wire [7 : 0] S03_AXIS_TKEEP
      .S00_AXIS_TLAST(s_axis_tlast[0]),              // input wire S00_AXIS_TLAST
      .S01_AXIS_TLAST(s_axis_tlast[1]),              // input wire S01_AXIS_TLAST
      .S02_AXIS_TLAST(s_axis_tlast[2]),              // input wire S02_AXIS_TLAST
      .S03_AXIS_TLAST(s_axis_tlast[3]),              // input wire S03_AXIS_TLAST
      .S00_AXIS_TID(2'b00),                  // input wire [1 : 0] S00_AXIS_TID
      .S01_AXIS_TID(2'b01),                  // input wire [1 : 0] S01_AXIS_TID
      .S02_AXIS_TID(2'b10),                  // input wire [1 : 0] S02_AXIS_TID
      .S03_AXIS_TID(2'b11),                  // input wire [1 : 0] S03_AXIS_TID
      .M00_AXIS_ACLK(clki),                // input wire M00_AXIS_ACLK
      .M00_AXIS_ARESETN(rstn),          // input wire M00_AXIS_ARESETN
      .M00_AXIS_TVALID(m_axis_tvalid),            // output wire M00_AXIS_TVALID
      .M00_AXIS_TREADY(m_axis_tready),            // input wire M00_AXIS_TREADY
      .M00_AXIS_TDATA (m_axis_tdata),              // output wire [7 : 0] M00_AXIS_TDATA
      .M00_AXIS_TKEEP (            ),              // output wire [0 : 0] M00_AXIS_TKEEP
      .M00_AXIS_TLAST (m_axis_tlast),              // output wire M00_AXIS_TLAST
      .M00_AXIS_TID   (m_axis_tid),                  // output wire [1 : 0] M00_AXIS_TID
      .S00_ARB_REQ_SUPPRESS(1'b0),  // input wire S00_ARB_REQ_SUPPRESS
      .S01_ARB_REQ_SUPPRESS(1'b0),  // input wire S01_ARB_REQ_SUPPRESS
      .S02_ARB_REQ_SUPPRESS(1'b0),  // input wire S02_ARB_REQ_SUPPRESS
      .S03_ARB_REQ_SUPPRESS(1'b0)  // input wire S03_ARB_REQ_SUPPRESS
    );
    // INST_TAG_END ------ End INSTANTIATION Template ---------
    
    
    
    
    
    
    
    
    
endmodule
