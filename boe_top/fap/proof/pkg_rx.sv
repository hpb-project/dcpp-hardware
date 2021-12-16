module pkg_rx(
input	clk_i,
input   arst_ni,
input	proof_end_i,
input   [7:0]proof_res_i,
//axi rx if
output  axi_ready_o,
input   axi_valid_i,
input   axi_tlast_i,
input   [63:0]axi_tdata_i,
//proof res out
input   axi_ready_i,
output  axi_valid_o,
output  axi_tlast_o,
output  [63:0]axi_tdata_o,
//axi out hs if
output  hs_valid_o,
output  hs_tlast_o,
output  [63:0]hs_tdata_o,
input	hs_ready_i,
//axi out ls if
output  ls_valid_o,
output  ls_tlast_o,
output  [63:0]ls_tdata_o,
input	ls_ready_i,
//axi out rs if
output  rs_valid_o,
output  rs_tlast_o,
output  [63:0]rs_tdata_o,
input	rs_ready_i,
//output others
output  [  7:0]pmod_o,
output	[255:0]salt_o,
output  [255:0]ux_o,
output  [255:0]uy_o,
output  [255:0]px_o,
output  [255:0]py_o,
output  [255:0]a_o,
output  [255:0]b_o
);

reg axi_ready;
reg [9:0]rx_len;
reg [  7:0]pmod;
reg [ 31:0]pseq;
reg	[255:0]salt;
reg [255:0]ux;
reg [255:0]uy;
reg [255:0]px;
reg [255:0]py;
reg [255:0]a;
reg [255:0]b;
reg axi_valid;
reg axi_tlast;
reg [63:0]axi_tdata;
//wire
wire buff_rstn;
wire is_ls;
wire is_rs;
wire is_hs;
wire ls_valid;
wire ls_tlast;
wire rs_valid;
wire rs_tlast;
wire hs_valid;
wire hs_tlast; 

//*********************************************************************//
assign pmod_o=pmod;
assign salt_o=salt;
assign ux_o  =ux;
assign uy_o  =uy;
assign px_o  =px;
assign py_o  =py;
assign a_o   =a;
assign b_o   =b;
assign axi_ready_o=axi_ready;
assign axi_valid_o=axi_valid;
assign axi_tlast_o=axi_tlast;
assign axi_tdata_o=axi_tdata;

//*********************************************************************//

//axi_ready
always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		axi_ready<=1;
	else if(axi_tlast_i)
		axi_ready<=0;
	else if(proof_end_i)
		axi_ready<=1;
end

//rx_len
always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		rx_len<=0;
	else if(axi_tlast_i&axi_ready_o)
		rx_len<=0;
	else if(axi_valid_i&axi_ready_o)
		rx_len<=rx_len+1;
end

//others
always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		pmod<=0;
		pseq<=0;
		salt<=0;
		ux<=0;
		uy<=0;
		px<=0;
		py<=0;
		a<=0;
		b<=0;
	end
	else if(proof_end_i)
	begin
		pmod<=0;
		pseq<=0;
		salt<=0;
		ux<=0;
		uy<=0;
		px<=0;
		py<=0;
		a<=0;
		b<=0;
	end
	else if(axi_valid_i&axi_ready_o)
	begin
		pmod<=(rx_len==0)?axi_tdata_i[63:56]:pmod;
		pseq<=(rx_len==0)?axi_tdata_i[31: 0]:pseq;
		if((rx_len>=1)&(rx_len<=4))
			salt<={salt[191:0],axi_tdata_i};
		else if((rx_len>=5)&(rx_len<=8))
			a<={a[191:0],axi_tdata_i};
		else if((rx_len>=9)&(rx_len<=12))
			b<={b[191:0],axi_tdata_i};
		else if((rx_len>=13)&(rx_len<=16))
			ux<={ux[191:0],axi_tdata_i};
		else if((rx_len>=17)&(rx_len<=20))
			uy<={uy[191:0],axi_tdata_i};
		else if((rx_len>=21)&(rx_len<=24))
			px<={px[191:0],axi_tdata_i};
		else if((rx_len>=25)&(rx_len<=28))
			py<={py[191:0],axi_tdata_i};
	end
end	

//*******************************buff******************************//
assign buff_rstn=arst_ni&(~proof_end_i);
assign is_ls=(pmod==0)?((rx_len>=29)&(rx_len<=68)):((rx_len>=29)&(rx_len<=76));
assign ls_valid=axi_valid_i&axi_ready_o&is_ls;
assign ls_tlast=(pmod==0)?(axi_valid_i&axi_ready_o&(rx_len==68)):(axi_valid_i&axi_ready_o&(rx_len==76));
assign is_rs=(pmod==0)?((rx_len>=69)&(rx_len<=108)):((rx_len>=77)&(rx_len<=124));
assign rs_valid=axi_valid_i&axi_ready_o&is_rs;
assign rs_tlast=(pmod==0)?(axi_valid_i&axi_ready_o&(rx_len==108)):(axi_valid_i&axi_ready_o&(rx_len==124));
assign is_hs=(pmod==0)?((rx_len>=109)&(rx_len<=364)):((rx_len>=125)&(rx_len<=636));
assign hs_valid=axi_valid_i&axi_ready_o&is_hs;
assign hs_tlast=(pmod==0)?(axi_valid_i&axi_ready_o&(rx_len==364)):(axi_valid_i&axi_ready_o&(rx_len==636));

sync_buff ls_buff(   
	.arst_ni(buff_rstn),                  
	.axi_clock_i(clk_i),
	.axi_valid_i(ls_valid),        			
	.axi_tlast_i(ls_tlast),               
	.axi_tdata_i(axi_tdata_i),			      
	.axi_ready_o(),            
	.axi_ready_i(ls_ready_i),             
	.axi_valid_o(ls_valid_o),        		
	.axi_tlast_o(ls_tlast_o),        		
	.axi_tdata_o(ls_tdata_o) 			  
);

sync_buff rs_buff(   
	.arst_ni(buff_rstn),                  
	.axi_clock_i(clk_i),
	.axi_valid_i(rs_valid),        			
	.axi_tlast_i(rs_tlast),               
	.axi_tdata_i(axi_tdata_i),			      
	.axi_ready_o(),            
	.axi_ready_i(rs_ready_i),             
	.axi_valid_o(rs_valid_o),        		
	.axi_tlast_o(rs_tlast_o),        		
	.axi_tdata_o(rs_tdata_o) 			  
);

sync_buff hs_buff(   
	.arst_ni(buff_rstn),                  
	.axi_clock_i(clk_i),
	.axi_valid_i(hs_valid),        			
	.axi_tlast_i(hs_tlast),               
	.axi_tdata_i(axi_tdata_i),			      
	.axi_ready_o(),            
	.axi_ready_i(hs_ready_i),             
	.axi_valid_o(hs_valid_o),        		
	.axi_tlast_o(hs_tlast_o),        		
	.axi_tdata_o(hs_tdata_o) 			  
);

//*******************proof out****************************/

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		axi_valid<=0;
		axi_tlast<=0;
		axi_tdata<=0;
	end
	else if(proof_end_i)
	begin
		axi_valid<=1;
		axi_tlast<=1;
		axi_tdata<={pmod,proof_res_i,16'd0,pseq};
	end
	else if(axi_ready_i)
	begin
		axi_valid<=0;
		axi_tlast<=0;
		axi_tdata<=0;
	end
end

endmodule





