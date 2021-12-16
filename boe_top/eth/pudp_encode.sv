`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/05 14:29:27
// Design Name: 
// Module Name: pudp_encode
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


module pudp_encode(
input	    clki,
input       rsti,
output      s_axis_tready,
input       s_axis_tvalid,
input       s_axis_tlast,
input [7:0] s_axis_tdata,
input [1:0] s_axis_tid,
input       m_axis_tready,
output      m_axis_tvalid,
output      m_axis_tlast,
output[7:0] m_axis_tdata 
);

parameter FSMIdle = 2'b00;
parameter FSMSendType = 2'b01;
parameter FSMSendData = 2'b10;
parameter FSMSendCheckSum = 2'b11;

reg [1:0] fsm;

reg [1:0] byte_cnt;
reg [7:0] type_reg;
reg [7:0] s_axis_tdata_reg;
reg [7:0] checksum;

always @(posedge clki or posedge rsti)
begin
	if(rsti)
		fsm<=FSMIdle;
	else begin
         case (fsm)
         FSMIdle  : 
         begin
            if (s_axis_tvalid==1'b1) 
                fsm<=FSMSendType   ;
         end
         FSMSendType  : 
         begin
            if (m_axis_tvalid==1'b1 && m_axis_tready==1'b1)
                fsm<=FSMSendData;
         end  
         FSMSendData  : 
         begin
            if (m_axis_tvalid==1'b1 && m_axis_tready==1'b1 && s_axis_tlast==1'b1)
                fsm<=FSMSendCheckSum;
         end
         FSMSendCheckSum  : 
         begin
            if (m_axis_tvalid==1'b1 && m_axis_tready==1'b1)
             fsm<=FSMIdle;
         end
         default: 
         begin
            fsm<=FSMIdle;
         end
         endcase
                   
	end
end


always @(posedge clki or posedge rsti)
begin
	if(rsti)
		checksum<=8'b0;
	else if (m_axis_tvalid==1'b1 && m_axis_tready==1'b1)begin
	   if(m_axis_tlast==1'b1)
	       checksum<=0;
	   else
		   checksum<= checksum ^ m_axis_tdata;
	end
end


assign s_axis_tready = (fsm==FSMSendData) ? m_axis_tready : 1'b0;
assign m_axis_tvalid = (fsm==FSMSendData) ? s_axis_tvalid : (fsm==FSMSendType || fsm==FSMSendCheckSum) ? 1'b1 : 1'b0;
assign m_axis_tlast  = (fsm==FSMSendCheckSum) ? 1'b1 : 1'b0;
assign m_axis_tdata  = (fsm==FSMSendType)     ? {6'b0,s_axis_tid}  :
                       (fsm==FSMSendData)     ? s_axis_tdata       : 
                       (fsm==FSMSendCheckSum) ? checksum           :      8'b0;



endmodule
