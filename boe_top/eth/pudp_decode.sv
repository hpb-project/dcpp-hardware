module pudp_decode
(
input	    clki,
input       rsti,
input       s_axis_tvalid,
input       s_axis_tlast,
input [7:0] s_axis_tdata,
input [3:0] m_axis_tready,
output[3:0] m_axis_tvalid,
output[3:0] m_axis_tlast,
output[7:0] m_axis_tkeep[3:0],
output[63:0] m_axis_tdata[3:0]
);

reg [1:0] byte_cnt;
reg [7:0] type_reg;
reg [7:0] s_axis_tdata_reg;
reg [7:0] checksum;

always @(posedge clki or posedge rsti)
begin
	if(rsti)
		byte_cnt<=0;
	else if (s_axis_tvalid==1'b1)begin
	   if(s_axis_tlast==1'b1)
		  byte_cnt<=0;
	   else if(byte_cnt<3) 
		  byte_cnt<=byte_cnt + 1'b1;
	end
end


always @(posedge clki or posedge rsti)
begin
	if(rsti)
		type_reg<=8'b0;
	else if (s_axis_tvalid==1'b1 && byte_cnt==0)
		type_reg<=s_axis_tdata;
end


always @(posedge clki or posedge rsti)
begin
	if(rsti)
		s_axis_tdata_reg<=8'b0;
	else if (s_axis_tvalid==1'b1)
		s_axis_tdata_reg<=s_axis_tdata;
end


always @(posedge clki or posedge rsti)
begin
	if(rsti)
		checksum<=8'b0;
	else if (s_axis_tvalid==1'b1) begin
	   if(s_axis_tlast==1'b1)
	       checksum<=0;
	   else
		   checksum<= checksum ^ s_axis_tdata;
	end
end


//------------------------------------
wire       s_axis_tvalid_mid      ;
wire       s_axis_tlast_mid       ;
wire       s_axis_pkt_err         ;
wire [7:0] s_axis_tdata_mid       ; 

wire [3:0] s_axis_tvalid_fifo     ;  
wire [3:0] s_axis_tlast_fifo     ;  
wire [7:0] s_axis_tdata_fifo [3:0]    ;  

wire [3:0] m_axis_tvalid_mid      ;   
wire [3:0] m_axis_tready_mid      ;   
wire [3:0] m_axis_tlast_mid       ;   
wire [7:0] m_axis_tdata_mid[3:0];   

assign s_axis_tvalid_mid = (s_axis_tvalid==1'b1 && byte_cnt>=2) ? 1'b1 : 1'b0 ;
assign s_axis_tlast_mid  = (s_axis_tvalid==1'b1 && byte_cnt>=2 && s_axis_tlast==1'b1) ? 1'b1 : 1'b0 ;
assign s_axis_pkt_err    = (s_axis_tvalid==1'b1 && byte_cnt>=2 && s_axis_tlast==1'b1 && checksum!=s_axis_tdata ) ? 1'b1 : 1'b0 ;
assign s_axis_tdata_mid  = s_axis_tdata_reg ;

genvar var_i;
generate
   for (var_i=0 ; var_i<=3; var_i=var_i+1)  begin: gen_fifo

assign s_axis_tvalid_fifo[var_i] = (s_axis_tvalid_mid==1'b1 && type_reg==var_i) ? 1'b1: 1'b0;
assign s_axis_tlast_fifo[var_i]  = s_axis_tlast_mid;
assign s_axis_tdata_fifo[var_i]  = s_axis_tdata_mid;

axis_data_fifo_0 u_fifo(
  .s_axis_aresetn    ( ~rsti  ),
  .s_axis_aclk       ( clki  ),
  .s_axis_tvalid     ( s_axis_tvalid_fifo[var_i]  ),
  .s_axis_tready     (   ),
  .s_axis_tdata      ( s_axis_tdata_fifo[var_i]  ),
  .s_axis_tlast      ( s_axis_tlast_fifo[var_i]  ),
  .m_axis_tvalid     ( m_axis_tvalid_mid[var_i]  ),
  .m_axis_tready     ( m_axis_tready_mid[var_i]  ),
  .m_axis_tdata      ( m_axis_tdata_mid[var_i]   ),
  .m_axis_tlast      ( m_axis_tlast_mid[var_i]   ),
  .axis_data_count   (   ),
  .axis_wr_data_count(   ),
  .axis_rd_data_count(   )
);

axis_dwidth_converter_0 u_axis_dwidth_conv(
  .aclk           ( clki ),
  .aresetn        ( ~rsti ),
  .s_axis_tvalid  ( m_axis_tvalid_mid[var_i] ),
  .s_axis_tready  ( m_axis_tready_mid[var_i] ),
  .s_axis_tdata   ( m_axis_tdata_mid[var_i] ),
  .s_axis_tkeep   ( 1'b1  ),
  .s_axis_tlast   ( m_axis_tlast_mid[var_i] ),
  .m_axis_tvalid  ( m_axis_tvalid[var_i]  ),
  .m_axis_tready  ( m_axis_tready[var_i] ),
  .m_axis_tdata   ( m_axis_tdata[var_i]  ),
  .m_axis_tkeep   ( m_axis_tkeep[var_i]  ),
  .m_axis_tlast   ( m_axis_tlast[var_i]  )
);
   end
endgenerate
			
			


endmodule
