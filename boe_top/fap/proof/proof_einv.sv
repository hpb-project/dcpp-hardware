module proof_einv
//参数定义
#(  
	parameter BMAX=256
) 
//端口声明  
(
input   clk_i,
input   arst_ni,
input   istr_i,
input   [BMAX-1:0]modp_i,
input   [BMAX-1:0]inew_i,
input   [BMAX-1:0]icof_i,
output  busy_o,
output  vlid_o,
output  ierr_o,
output  [BMAX-1:0]einv_o      
);

reg 	[BMAX-1:0]iu;
reg 	[BMAX-1:0]iv;
reg 	[BMAX:0]x1;
reg 	[BMAX:0]x2;
reg     busy;
reg     vlid;
reg     [BMAX-1:0]einv;
reg 	[BMAX:0]p256;

wire    [BMAX:0]cpuv;
wire    [BMAX:0]clu1;
wire    [BMAX:0]clu2;
wire    [BMAX:0]clu3;
wire    [BMAX:0]clu4;
wire    iend;

//*****************************************************************************//
assign vlid_o=vlid;
assign einv_o=einv;
assign busy_o=busy;

//*****************************************************************************//

//*************************for sim**************************************//
//synthesis translate_off
reg  [255:0]inew;
wire  [511:0]t1;
wire  [255:0]q;
wire  [511:0]t2;
wire  [511:0]mod;

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		inew<=0;
	else if(istr_i)
		inew<=inew_i;
end

assign t1=inew*einv;
assign q=t1/p256;
assign t2=q*p256;
assign mod=t1-t2;
assign ierr_o=vlid&(mod!=1);
//synthesis translate_on

//**********************************************************************//
assign iend=busy&((iu==1)|(iv==1));
assign cpuv=iu-iv;  //相减后如果最高位为1说明产生借位,因此iu<iv,否则iu>=iv
assign clu1=x1+p256;
assign clu2=x1[BMAX:1]+p256;
assign clu3=x2+p256;
assign clu4=x2[BMAX:1]+p256;

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		busy<=1'd0;
	else if(istr_i)
		busy<=1'd1;
	else if(iend)
		busy<=1'd0;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		p256<=0;
	else if(istr_i)
		p256<=modp_i;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		iu<={BMAX{1'd0}};
		iv<={BMAX{1'd0}};
		x1<={BMAX{1'd0}};
		x2<={BMAX{1'd0}};
	end
	else if(istr_i)
	begin
		iu<=inew_i;
		iv<=modp_i;
		x1<=icof_i;
		x2<={BMAX{1'd0}};
	end
	else if(busy)
	begin
		//iu为偶数时循环更新iu和x1
		if(iu[0]==0)  
		begin
			iu<=iu[BMAX-1:1]; 
			if(x1[BMAX]==1)  //x1为负
			begin				
			    if(x1[0]==0)
			    	x1<=clu2[BMAX-1:0];
			    else
			    	x1<=clu1[BMAX-1:1];
			end
			else  //x1为正
			begin				
			    if(x1[0]==0)
			    	x1<=x1[BMAX-1:1];
			    else
			    	x1<=clu1[BMAX:1];
			end
		end
		//iv为偶数时循环更新iv和x2
		else if(iv[0]==0)  
		begin
			iv<=iv[BMAX-1:1]; 
			if(x2[BMAX]==1)  //x2为负
			begin				
			    if(x2[0]==0)
			    	x2<=clu4[BMAX-1:0];
			    else
			    	x2<=clu3[BMAX-1:1];
			end
			else  //x2为正
			begin				
			    if(x2[0]==0)
			    	x2<=x2[BMAX-1:1];
			    else
			    	x2<=clu3[BMAX:1];
			end
		end
		//iu和iv都为奇数时更新iu、iv、x1、x2
		else if(iu[0]&iv[0])
		begin
			if(cpuv[BMAX]==0)
			begin
				iu<=iu-iv;
				x1<=x1-x2;
			end
			else
			begin
				iv<=iv-iu;
				x2<=x2-x1;
			end
		end
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		vlid<=1'd0;
		einv<={BMAX{1'd0}};
	end
	else 
	begin
		vlid<=iend;
		if(iend)
		begin
			if(iu==1)
				einv<=x1[BMAX-1:0];
			else
				einv<=x2[BMAX-1:0];
		end
	end
end

endmodule


	