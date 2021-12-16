`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/04 20:24:35
// Design Name: 
// Module Name: eth_llc_encode
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


module eth_llc_encode
#(
	parameter LOCAL_MAC=48'h7FFFFFFFFFFF,
	parameter PROCT_TYP=16'hFF00
)
(
input	clki,
input   rsti,
//pudp rx
output       s_axis_tready,
input        s_axis_tvalid,
input        s_axis_tlast,
input   [7:0]s_axis_tdata,
input   [1:0]s_axis_tid,
//mac if
input        m_axis_tready,
output       m_axis_tvalid,
output       m_axis_tlast,
output  [7:0]m_axis_tdata,
//remote mac if 
input        remote_mac_en_i,
input  [47:0]remote_mac_i
);

reg  [1:0] rmt_mac_en_dly;
reg  [47:0]rmt_mac;

reg  [6:0] byte_cnt;
reg  [7:0] eth_data;

wire [47:0]des_mac;
wire [47:0]src_mac;
wire [15:0]len_typ;


//*****************************************************************//
always @(posedge clki or posedge rsti)
begin
	if(rsti)
		rmt_mac_en_dly<=0;
	else
		rmt_mac_en_dly<={rmt_mac_en_dly[0],remote_mac_en_i};
end

always @(posedge clki or posedge rsti)
begin
	if(rsti)
		rmt_mac<=0;
	else if(rmt_mac_en_dly[1]==1'b0 && rmt_mac_en_dly[0]==1'b1)
		rmt_mac<=remote_mac_i;
end

always @(posedge clki or posedge rsti)
begin
	if(rsti)
		byte_cnt<=0;
	else if(m_axis_tready==1'b1 && m_axis_tvalid==1'b1) begin
	   if(m_axis_tlast==1'b1)
	       byte_cnt<=0;
	   else if(byte_cnt<14)
	       byte_cnt<=byte_cnt+1;
	end
end


assign des_mac=rmt_mac;
assign src_mac=LOCAL_MAC;
assign len_typ={ PROCT_TYP[15:2] , s_axis_tid };


always @(*)
begin
	case(byte_cnt)
		7'd0 :eth_data=des_mac[47:40];
		7'd1 :eth_data=des_mac[39:32];
		7'd2 :eth_data=des_mac[31:24];
		7'd3 :eth_data=des_mac[23:16];
		7'd4 :eth_data=des_mac[15: 8];
		7'd5 :eth_data=des_mac[ 7: 0];
		7'd6 :eth_data=src_mac[47:40];
		7'd7 :eth_data=src_mac[39:32];
		7'd8 :eth_data=src_mac[31:24];
		7'd9 :eth_data=src_mac[23:16];
		7'd10:eth_data=src_mac[15: 8];
		7'd11:eth_data=src_mac[ 7: 0];
		7'd12:eth_data=len_typ[15: 8];
		7'd13:eth_data=len_typ[ 7: 0];
		default:eth_data=s_axis_tdata;
	endcase
end

assign s_axis_tready = (byte_cnt>=14) ? m_axis_tready : 1'b0;
assign m_axis_tvalid = s_axis_tvalid;
assign m_axis_tlast  = (byte_cnt>=14) ? s_axis_tlast : 1'b0 ;
assign m_axis_tdata  = eth_data;


endmodule
