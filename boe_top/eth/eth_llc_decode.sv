module eth_llc_decode
#(
	parameter LOCAL_MAC=48'h7FFFFFFFFFFF,
	parameter PROCT_TYP=16'hFF00
)
(
input	clki,
input   rsti,
//mac if
(*mark_debug = "true"*)input   [7:0]s_axis_tdata,
(*mark_debug = "true"*)input        s_axis_tvalid,
(*mark_debug = "true"*)input        s_axis_tlast,
//pudp if
(*mark_debug = "true"*)output  [3:0]m_axis_tvalid,
(*mark_debug = "true"*)output  [3:0]m_axis_tlast,
(*mark_debug = "true"*)output  [7:0]m_axis_tdata[3:0],
//remote mac if 
output        remote_mac_en_o,
output  [47:0]remote_mac_o
);


reg      m_axis_tvalid_mid;
reg      m_axis_tlast_mid;  
reg [7:0]m_axis_tdata_mid;

(*mark_debug = "true"*)reg  [47:0] src_mac;
(*mark_debug = "true"*)reg  [47:0] des_mac;
(*mark_debug = "true"*)reg  [15:0] len_typ;
(*mark_debug = "true"*)reg  [ 7:0] pkg_cmd;
(*mark_debug = "true"*)reg  [ 3:0] head_len;
(*mark_debug = "true"*)reg  [ 7:0] dat_len;
(*mark_debug = "true"*)wire  payload_en;

//*****************************************************************//
always @(posedge clki or posedge rsti)
begin
	if(rsti)
		head_len<=0;
	else if (s_axis_tvalid==1'b1)begin
	   if(s_axis_tlast==1'b1)
		  head_len<=0;
	   else if(head_len<15)
		  head_len<=head_len+1;
	end
end


always @(posedge clki or posedge rsti)
begin
	if(rsti)begin
		des_mac<=0;
		src_mac<=0;
		len_typ<=0;
	end	else if(s_axis_tvalid)	begin
		case(head_len)
			4'h0:des_mac[47:40]<=s_axis_tdata;
			4'h1:des_mac[39:32]<=s_axis_tdata;
			4'h2:des_mac[31:24]<=s_axis_tdata;
			4'h3:des_mac[23:16]<=s_axis_tdata;
			4'h4:des_mac[15: 8]<=s_axis_tdata;
			4'h5:des_mac[ 7: 0]<=s_axis_tdata;
			4'h6:src_mac[47:40]<=s_axis_tdata;
			4'h7:src_mac[39:32]<=s_axis_tdata;
			4'h8:src_mac[31:24]<=s_axis_tdata;
			4'h9:src_mac[23:16]<=s_axis_tdata;
			4'ha:src_mac[15: 8]<=s_axis_tdata;
			4'hb:src_mac[ 7: 0]<=s_axis_tdata;
			4'hc:len_typ[15: 8]<=s_axis_tdata;
			4'hd:len_typ[ 7: 0]<=s_axis_tdata;
			default:;
		endcase
	end
end

assign payload_en = ((head_len>=14) && (des_mac==LOCAL_MAC) && ({len_typ[15:2],2'b00}==PROCT_TYP)) ? 1'b1 : 1'b0;

always @(posedge clki or posedge rsti)
begin
	if(rsti) begin
		m_axis_tvalid_mid<=0;
		m_axis_tlast_mid<=0;
		m_axis_tdata_mid<=0;
	end	else begin
		m_axis_tvalid_mid<=s_axis_tvalid & payload_en;
		m_axis_tlast_mid <=s_axis_tvalid & payload_en & s_axis_tlast;
		m_axis_tdata_mid <=s_axis_tvalid ? s_axis_tdata : m_axis_tdata_mid;
	end
end


genvar var_i;
generate
   for (var_i=0 ; var_i<=3; var_i=var_i+1)  begin: gen_fifo
            assign m_axis_tvalid[var_i] = (m_axis_tvalid_mid==1'b1 && len_typ[1:0]==var_i) ? 1'b1 : 1'b0;
            assign m_axis_tlast[var_i]  = m_axis_tlast_mid;
            assign m_axis_tdata[var_i]  = m_axis_tdata_mid;
   end
endgenerate





assign remote_mac_en_o=payload_en;
assign remote_mac_o=src_mac;


endmodule
