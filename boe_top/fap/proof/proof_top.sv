module proof_top(
input	clk_i,
input   arst_ni,
//axi rx if
(*mark_debug = "true"*) output  axi_ready_o,
(*mark_debug = "true"*) input   axi_valid_i,
(*mark_debug = "true"*) input   axi_tlast_i,
(*mark_debug = "true"*) input   [63:0]axi_tdata_i,
//proof res
(*mark_debug = "true"*) input   axi_ready_i,
(*mark_debug = "true"*) output  axi_valid_o,
(*mark_debug = "true"*) output  axi_tlast_o,
(*mark_debug = "true"*) output  [63:0]axi_tdata_o
);

parameter GROUP_ORDER=256'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001;
parameter GORDER_SUB2=256'h30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffffff;
parameter FILED_ORDER=256'h30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;
parameter PREU_GROUP =256'h54a47462623a04a7ab074a58680730147144852009e880ae620703a6be1de925;
parameter PREU_FILED =256'h54a47462623a04a7ab074a5868073013ae965e1767cd4c086f3aed8a19bf90e5;

//dotP fsm
parameter ST_PIDLE=4'h0;  //idle
parameter ST_RLSRS=4'h1;  //read ls/rs 
parameter ST_BKSTR=4'h2;  //start one block hash256
parameter ST_CBUSY=4'h4;  //one block text hash256 busy
parameter ST_HSEND=4'h5;  //all block text hash256 end
parameter ST_CMODP=4'h6;  //hash256 res mod(P)
parameter ST_CMULT=4'h7;  //other=other*challenges
parameter ST_CEXP1=4'h8;  //t1=challenges(i)**2
parameter ST_CEXP2=4'h9;  //t2=challenges(i)**n(n=GORDER_SUB2)
parameter ST_CEXP3=4'ha;  //t3=t2**2
parameter ST_PMULT=4'hb;  //P1=t1.*ls P2=t3.*rs
parameter ST_PADD1=4'hc;  //P3=P1+P2
parameter ST_PADD2=4'hd;  //P=P+P3
parameter ST_PWAIT=4'he;  //wait for otherexpos end
parameter ST_DPEND=4'hf;  //dotP end
//otherexpos fsm
parameter ST_OIDLE=3'h0;  //idle
parameter ST_OMUAB=3'h1;  //a*b
parameter ST_OEXP1=3'h2;  //t1=otherexpos[0]**GORDER_SUB2
parameter ST_OREDY=3'h3;  //ready:i,j,ci=logn-1-j
parameter ST_OEXPO=3'h4;  //t1=challenges**2
parameter ST_OMULT=3'h5;  //t2=t1*challenges
//dotT fsm
parameter ST_TIDLE=4'h0;  //idle
parameter ST_RGSHS=4'h1;  //read gs/hs 
parameter ST_GHMUL=4'h2;  //t1=gs.*otherexpos（雅克比坐标�? t2=hs.*otherexpos（雅克比坐标�?
parameter ST_GHADD=4'h3;  //gt=gt.+t1（仿射坐标，�?要坐标转换） ht=ht.+t2（仿射坐标，�?要坐标转换）
parameter ST_MULAB=4'h4;  //gt=gt.*a（仿射坐标，�?要坐标转换） ht=ht.*b（雅克比坐标�?
parameter ST_UMULT=4'h5;  //t3=u.*ab（雅克比坐标�? t5=gt.+ht（仿射坐标，�?要坐标转换）
parameter ST_TADD6=4'h6;  //t6=t5.+t3（仿射坐标，�?要坐标转换）
parameter ST_TENDP=4'h7;  //dotT end

reg [3:0]dotp_state;
reg [2:0]oexp_state;
reg [3:0]dott_state;
reg [3:0]rlsrs_cnt;
reg [3:0]rgshs_cnt;
reg [5:0]ghmul_cnt;
reg block_cnt;  
reg [2:0]challenges_cnt;  //5/6
reg [255:0]challenges[5:0];
reg [5:0]otherexpos_cnt;  //32/64
reg [255:0]otherexpos[63:0];
reg [3:0][63:0]p1_x;
reg [3:0][63:0]p1_y;
reg [3:0][63:0]p2_x;
reg [3:0][63:0]p2_y;
(*mark_debug = "true"*) reg [3:0][63:0]p_x;
(*mark_debug = "true"*) reg [3:0][63:0]p_y;
reg [255:0]mul_ab;
reg [1087:0]text;
reg pmul1_end;
reg pmul2_end;
reg dotp_busy;
reg dott_busy;
reg [7:0]proof_res;

wire  [255:0]a;
wire  [255:0]b;
wire  [255:0]ux;
wire  [255:0]uy;
wire  [255:0]px;
wire  [255:0]py;
wire  [  7:0]pmod;
wire  [3:0][63:0]salt;
wire  [3:0][63:0]dmod;
wire  [2:0]challenges_num;
wire  [7:0]otherexpos_num;
wire  rxpkg_end;  //收包结束
wire  rlsrs_end;  //读取rs+ls坐标结束
wire  block_str;  //1088bit哈希起始
wire  block_one;  //首个5112bit文本指示
wire  block_end;  //�?个文本块hash256结束
wire  cmodp_str;
wire  cmodp_end;
wire  oexpo_str;
wire  expmu_str;
wire  expmu_end;
wire  cmult_end;
wire  cexp1_end;
wire  cexp2_end;
wire  cexp3_end;
wire  pmult_end;
wire  padd1_end;
(*mark_debug = "true"*) wire  padd2_end;
wire  oexp1_end;
wire  oexpo_end;
wire  omult_end;
wire  dotpp_end;
wire  proof_end;
wire  hs_valid;
wire  hs_tlast;
wire  [63:0]hs_tdata;
wire  ls_valid;
wire  ls_tlast;
wire  [63:0]ls_tdata;
wire  rs_valid;
wire  rs_tlast;
wire  [63:0]rs_tdata;
wire  gs_valid;
wire  [63:0]gs_tdata;
wire  ls_ready,rs_ready,hs_ready,gs_ready;
wire  [255:0]dexp;
//curve signal
(*mark_debug = "true"*) reg   [255:0]gt[1:0];
reg   dstra,opera,denda,cenba;
reg   [255:0]kinta;
reg   [255:0]dotpa[1:0];
reg   [255:0]dotqa[2:0];
reg   [255:0]dotja[2:0];
wire   cstra,cenda,zeroa;
(*mark_debug = "true"*)reg   [255:0]ht[1:0];
reg   dstrb,operb,dendb,cenbb;
reg   [255:0]kintb;
reg   [255:0]dotpb[1:0];
reg   [255:0]dotqb[2:0];
reg   [255:0]dotjb[2:0];
wire  cstrb,cendb,zerob;

/******************************************************************************/

/************************************pkg rx************************************/
assign rxpkg_end=axi_tlast_i&axi_ready_o;
assign ls_ready=(rlsrs_cnt<=7)&(dotp_state==ST_RLSRS)&ls_valid;
assign rs_ready=(rlsrs_cnt<=7)&(dotp_state==ST_RLSRS)&rs_valid;

pkg_rx pkg_rx(
	.clk_i(clk_i),
	.arst_ni(arst_ni),
	.proof_end_i(proof_end),
	.proof_res_i(proof_res),
	.axi_ready_o(axi_ready_o),
	.axi_valid_i(axi_valid_i),
	.axi_tlast_i(axi_tlast_i),
	.axi_tdata_i(axi_tdata_i),
	.axi_ready_i(axi_ready_i),
	.axi_valid_o(axi_valid_o),
	.axi_tlast_o(axi_tlast_o),
	.axi_tdata_o(axi_tdata_o),
	.hs_valid_o(hs_valid),
	.hs_tlast_o(hs_tlast),
	.hs_tdata_o(hs_tdata),
	.hs_ready_i(hs_ready),
	.ls_valid_o(ls_valid),
	.ls_tlast_o(ls_tlast),
	.ls_tdata_o(ls_tdata),
	.ls_ready_i(ls_ready),
	.rs_valid_o(rs_valid),
	.rs_tlast_o(rs_tlast),
	.rs_tdata_o(rs_tdata),
	.rs_ready_i(rs_ready),
	.pmod_o(pmod),
	.salt_o(salt),
	.ux_o(ux),
	.uy_o(uy),
	.px_o(px),
	.py_o(py),
	.a_o(a),
	.b_o(b)
);

gs_rom gs_rom(
	.clk_i(clk_i),
	.arst_ni(arst_ni),
	.srst_i(rxpkg_end),
	.ready_i(gs_ready),
	.valid_o(gs_valid),
	.tdata_o(gs_tdata)
);


/***********************************point P ********************************/
assign challenges_num=pmod?6:5;
assign otherexpos_num=pmod?64:32;
assign rlsrs_end=(rlsrs_cnt==8)?1:0;
assign block_str=(dotp_state==ST_BKSTR)?1:0;
assign block_one=(block_cnt==0)?1:0;
assign cmodp_str=(dotp_state==ST_HSEND)?1:0;
assign pmult_end=pmul1_end&pmul2_end;
assign cmult_end=expmu_end&(dotp_state==ST_CMULT);
assign cexp1_end=expmu_end&(dotp_state==ST_CEXP1);
assign cexp2_end=expmu_end&(dotp_state==ST_CEXP2);
assign cexp3_end=expmu_end&(dotp_state==ST_CEXP3);
assign dotpp_end=(dotp_state==ST_DPEND)?1:0;

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		rlsrs_cnt<=0;
	else if(rxpkg_end|rlsrs_end)
		rlsrs_cnt<=0;
	else if(dotp_state==ST_RLSRS)
		rlsrs_cnt<=rlsrs_cnt+1;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		block_cnt<=0;
	else if(rxpkg_end|cmodp_end)
		block_cnt<=0;
	else if(block_end)
		block_cnt<=block_cnt+1;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		challenges_cnt<=0;
	else if(rxpkg_end)
		challenges_cnt<=0;
	else if(cmodp_end)
		challenges_cnt<=challenges_cnt+1;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		p1_x<=0;
		p1_y<=0;
	end
	else if(rxpkg_end)
	begin
		p1_x<=0;
		p1_y<=0;
	end
	else if(ls_ready&ls_valid)
	begin
		case(rlsrs_cnt)
			3'd0:begin p1_x[3]<=ls_tdata; end
			3'd1:begin p1_x[2]<=ls_tdata; end
			3'd2:begin p1_x[1]<=ls_tdata; end
			3'd3:begin p1_x[0]<=ls_tdata; end
			3'd4:begin p1_y[3]<=ls_tdata; end
			3'd5:begin p1_y[2]<=ls_tdata; end
			3'd6:begin p1_y[1]<=ls_tdata; end
			3'd7:begin p1_y[0]<=ls_tdata; end
			default:;
		endcase
	end
	else if(gs_ready&gs_valid)
	begin
		case(rgshs_cnt)
			3'd0:begin p1_x[3]<=gs_tdata; end
			3'd1:begin p1_x[2]<=gs_tdata; end
			3'd2:begin p1_x[1]<=gs_tdata; end
			3'd3:begin p1_x[0]<=gs_tdata; end
			3'd4:begin p1_y[3]<=gs_tdata; end
			3'd5:begin p1_y[2]<=gs_tdata; end
			3'd6:begin p1_y[1]<=gs_tdata; end
			3'd7:begin p1_y[0]<=gs_tdata; end
			default:;
		endcase
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		p2_x<=0;
		p2_y<=0;
	end
	else if(rxpkg_end)
	begin
		p2_x<=0;
		p2_y<=0;
	end
	else if(rs_ready&rs_valid)
	begin
		case(rlsrs_cnt)
			3'd0:begin p2_x[3]<=rs_tdata; end
			3'd1:begin p2_x[2]<=rs_tdata; end
			3'd2:begin p2_x[1]<=rs_tdata; end
			3'd3:begin p2_x[0]<=rs_tdata; end
			3'd4:begin p2_y[3]<=rs_tdata; end
			3'd5:begin p2_y[2]<=rs_tdata; end
			3'd6:begin p2_y[1]<=rs_tdata; end
			3'd7:begin p2_y[0]<=rs_tdata; end
			default:;
		endcase
	end
	else if(hs_ready&hs_valid)
	begin
		case(rgshs_cnt)
			3'd0:begin p2_x[3]<=hs_tdata; end
			3'd1:begin p2_x[2]<=hs_tdata; end
			3'd2:begin p2_x[1]<=hs_tdata; end
			3'd3:begin p2_x[0]<=hs_tdata; end
			3'd4:begin p2_y[3]<=hs_tdata; end
			3'd5:begin p2_y[2]<=hs_tdata; end
			3'd6:begin p2_y[1]<=hs_tdata; end
			3'd7:begin p2_y[0]<=hs_tdata; end
			default:;
		endcase
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		challenges[0]<=0;
		challenges[1]<=0;
		challenges[2]<=0;
		challenges[3]<=0;
		challenges[4]<=0;
		challenges[5]<=0;
	end
	else if(rxpkg_end)
	begin
		challenges[0]<=0;
		challenges[1]<=0;
		challenges[2]<=0;
		challenges[3]<=0;
		challenges[4]<=0;
		challenges[5]<=0;
	end
	else if(cmodp_end)
		challenges[challenges_cnt]<=dmod;
end

always @(*)
begin
	if(block_cnt==0) 
	begin
		text[1087:832]=(challenges_cnt==0)?salt:dmod;
		text[ 831:576]=p1_x;
		text[ 575:320]=p1_y;
		text[ 319: 64]=p2_x;
		text[  63:  0]=p2_y[3];
	end
	else
	begin
		text[1087:896]={p2_y[2],p2_y[1],p2_y[0]};
		text[ 895:888]=8'h01;
		text[ 887:  8]=0;
		text[   7:  0]=8'h80;
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		dotp_busy<=0;
	else if(rxpkg_end)
		dotp_busy<=1;
	else if(dotpp_end)
		dotp_busy<=0;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		pmul1_end<=0;
		pmul2_end<=0;
	end
	else if(pmult_end)
	begin
		pmul1_end<=0;
		pmul2_end<=0;
	end
	else 
	begin
		if((dotp_state==ST_PMULT)&cenda)  //�?要坐标转�?
			pmul1_end<=1;
		if((dotp_state==ST_PMULT)&dendb)  //不需坐标转换
			pmul2_end<=1;
	end
end

//dotP fsm
//parameter ST_PIDLE=4'h0;  //idle
//parameter ST_RLSRS=4'h1;  //read ls/rs 
//parameter ST_BKSTR=4'h2;  //start one block hash256
//parameter ST_CBUSY=4'h4;  //one block text hash256 busy
//parameter ST_HSEND=4'h5;  //all block text hash256 end
//parameter ST_CMODP=4'h6;  //hash256 res mod(P)
//parameter ST_CMULT=4'h7;  //other=other*challenges
//parameter ST_CEXP1=4'h8;  //t1=challenges(i)**2
//parameter ST_CEXP2=4'h9;  //t2=challenges(i)**n(n=GORDER_SUB2)
//parameter ST_CEXP3=4'ha;  //t3=t2**2
//parameter ST_PMULT=4'hb;  //P1(仿射坐标�?=t1.*ls(�?要坐标转换） P2（雅克比坐标�?=t3.*rs
//parameter ST_PADD1=4'hc;  //P3(雅克比坐标）=P1(仿射坐标�?+P2(雅克比坐�?)
//parameter ST_PADD2=4'hd;  //P（仿射坐标）=P(仿射坐标�?+P3（雅克比坐标�?(�?要坐标转换）
//parameter ST_PWAIT=4'he;  //wait for otherexpos end
//parameter ST_DPEND=4'hf;  //dotP end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		dotp_state<=ST_PIDLE;
	else 
	begin
		case(dotp_state)
			ST_PIDLE:begin
				if(rxpkg_end)
					dotp_state<=ST_RLSRS;
			end
			ST_RLSRS:begin
				if(rlsrs_end)
					dotp_state<=ST_BKSTR;
			end
			ST_BKSTR:begin
				dotp_state<=ST_CBUSY;
			end
			ST_CBUSY:begin
				if(block_end)
				begin
					if(block_cnt==1) 
						dotp_state<=ST_HSEND;
					else 
						dotp_state<=ST_BKSTR;
				end
			end
			ST_HSEND:begin
				dotp_state<=ST_CMODP;
			end
			ST_CMODP:begin
				if(cmodp_end)
					dotp_state<=ST_CMULT;
			end
			ST_CMULT:begin
				if(cmult_end)
					dotp_state<=ST_CEXP1;
			end
			ST_CEXP1:begin
				if(cexp1_end)
					dotp_state<=ST_CEXP2;
			end
			ST_CEXP2:begin
				if(cexp2_end)
					dotp_state<=ST_CEXP3;
			end
			ST_CEXP3:begin
				if(cexp3_end)
					dotp_state<=ST_PMULT;
			end
			ST_PMULT:begin
				if(pmult_end)
					dotp_state<=ST_PADD1;
			end
			ST_PADD1:begin
				if(padd1_end)
					dotp_state<=ST_PADD2;
			end
			ST_PADD2:begin
				if(padd2_end)
				begin
					if(challenges_cnt==challenges_num)
						dotp_state<=ST_PWAIT;
					else 
						dotp_state<=ST_RLSRS;
				end
			end
			ST_PWAIT:begin
				if(oexp_state==ST_OIDLE)
					dotp_state<=ST_DPEND;
			end
			ST_DPEND:begin
				dotp_state<=ST_PIDLE;
			end
			default:dotp_state<=ST_PIDLE;
		endcase
	end
end

/********************************otherexpos**************************************/
reg [4:0]oi;
reg [2:0]oj;
wire [2:0]ci;
wire oredy_end,omuab_end;
assign oexpo_str=cexp3_end&(challenges_cnt==challenges_num);
assign oexpo_end=expmu_end&(oexp_state==ST_OEXPO);
assign omult_end=expmu_end&(oexp_state==ST_OMULT);
assign ci=challenges_num-1-oj;
assign oexp1_end=(oexp_state==ST_OEXP1)&expmu_end;
assign oredy_end=(oexp_state==ST_OREDY)?1:0;
assign omuab_end=(oexp_state==ST_OMUAB)&expmu_end;

always @(*)
begin
	if(otherexpos_cnt[5])
	begin
		oj=5;
		oi=otherexpos_cnt[4:0];
	end
	else if(otherexpos_cnt[4])
	begin
		oj=4;
		oi=otherexpos_cnt[3:0];
	end
	else if(otherexpos_cnt[3])
	begin
		oj=3;
		oi=otherexpos_cnt[2:0];
	end
	else if(otherexpos_cnt[2])
	begin
		oj=2;
		oi=otherexpos_cnt[1:0];
	end
	else if(otherexpos_cnt[1])
	begin
		oj=1;
		oi=otherexpos_cnt[0];
	end
	else 
	begin
		oj=0;
		oi=0;
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		mul_ab<=0;
	else if(rxpkg_end)
		mul_ab<=0;
	else if(omuab_end)
		mul_ab<=dexp;
end
		
always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		otherexpos_cnt<=0;
	else if(rxpkg_end)
		otherexpos_cnt<=0;
	else if(oexp1_end|omult_end)
		otherexpos_cnt<=otherexpos_cnt+1;
end

integer i;
always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		for(i=0;i<64;i=i+1)
			otherexpos[i]<=0;
	end
	else if(rxpkg_end)
	begin
		otherexpos[0]<=1;
		for(i=1;i<64;i=i+1)
			otherexpos[i]<=0;
	end
	else if(cmult_end|oexp1_end)
		otherexpos[0]<=dexp;
	else if(omult_end&(otherexpos_cnt>0))
		otherexpos[otherexpos_cnt]<=dexp;
end
		
//otherexpos fsm
//parameter ST_OIDLE=3'h0;  //idle
//parameter ST_OMUAB=3'h1;  //a*b
//parameter ST_OEXP1=3'h2;  //t1=otherexpos[0]**GORDER_SUB2
//parameter ST_OREDY=3'h3;  //ready:i,j,ci=logn-1-j
//parameter ST_OEXPO=3'h4;  //t1=challenges**2
//parameter ST_OMULT=3'h5;  //t2=t1*challenges

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		oexp_state<=ST_OIDLE;
	else 
	begin
		case(oexp_state)
			ST_OIDLE:begin
				if(oexpo_str)
					oexp_state<=ST_OMUAB;
			end
			ST_OMUAB:begin	
				if(omuab_end)
					oexp_state<=ST_OEXP1;
			end
			ST_OEXP1:begin	
				if(oexp1_end)
					oexp_state<=ST_OREDY;
			end
			ST_OREDY:begin
				oexp_state<=ST_OEXPO;
			end
			ST_OEXPO:begin
				if(oexpo_end)
					oexp_state<=ST_OMULT;
			end
			ST_OMULT:begin
				if(omult_end)
				begin
					if(otherexpos_cnt==otherexpos_num-1)
						oexp_state<=ST_OIDLE;
					else
						oexp_state<=ST_OREDY;
				end
			end
			default:oexp_state<=ST_OIDLE;
		endcase
	end
end

/***********************************point T********************************/
reg ghmu1_end,ghmu2_end,ghad1_end,ghad2_end,gthtp_end,muab1_end,muab2_end,umul1_end,umul2_end;
wire rgshs_end;
wire ghmul_end;
(*mark_debug = "true"*) wire ghadd_end;
wire mulab_end;
wire umult_end;
wire tadd6_end;
wire dottp_end;

assign gs_ready=(rgshs_cnt<=7)&(dott_state==ST_RGSHS)&gs_valid;
assign hs_ready=(rgshs_cnt<=7)&(dott_state==ST_RGSHS)&hs_valid;
assign rgshs_end=(rgshs_cnt==8)?1:0;
assign ghmul_end=ghmu1_end&ghmu2_end;
assign ghadd_end=ghad1_end&ghad2_end;
assign mulab_end=muab1_end&muab2_end;
assign umult_end=umul1_end&umul2_end;
assign tadd6_end=(dott_state==ST_TADD6)&cenda;
assign dottp_end=(dott_state==ST_TENDP)?1:0;

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		rgshs_cnt<=0;
	else if(rxpkg_end|rgshs_end)
		rgshs_cnt<=0;
	else if(dott_state==ST_RGSHS)
		rgshs_cnt<=rgshs_cnt+1;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		ghmul_cnt<=0;
	else if(rxpkg_end)
		ghmul_cnt<=0;
	else if(ghadd_end)
		ghmul_cnt<=ghmul_cnt+1;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		ghmu1_end<=0;
		ghmu2_end<=0;
	end
	else if(ghmul_end)
	begin
		ghmu1_end<=0;
		ghmu2_end<=0;
	end
	else 
	begin
		if((dott_state==ST_GHMUL)&denda)
			ghmu1_end<=1;
		if((dott_state==ST_GHMUL)&dendb)
			ghmu2_end<=1;
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		ghad1_end<=0;
		ghad2_end<=0;
	end
	else if(ghadd_end)
	begin
		ghad1_end<=0;
		ghad2_end<=0;
	end
	else 
	begin
		if((dott_state==ST_GHADD)&cenda)
			ghad1_end<=1;
		if((dott_state==ST_GHADD)&cendb)
			ghad2_end<=1;
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		gthtp_end<=0;
	else
		gthtp_end<=ghadd_end&(ghmul_cnt==otherexpos_num-1);
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		muab1_end<=0;
		muab2_end<=0;
	end
	else if(mulab_end)
	begin
		muab1_end<=0;
		muab2_end<=0;
	end
	else 
	begin
		if((dott_state==ST_MULAB)&cenda)
			muab1_end<=1;
		if((dott_state==ST_MULAB)&dendb)
			muab2_end<=1;
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		umul1_end<=0;
		umul2_end<=0;
	end
	else if(umult_end)
	begin
		umul1_end<=0;
		umul2_end<=0;
	end
	else 
	begin
		if((dott_state==ST_UMULT)&denda)
			umul1_end<=1;
		if((dott_state==ST_UMULT)&cendb)
			umul2_end<=1;
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		dott_busy<=0;
	else if(dotpp_end)
		dott_busy<=1;
	else if(dottp_end)
		dott_busy<=0;
end

//parameter ST_TIDLE=4'h0;  //idle
//parameter ST_RHSGS=4'h1;  //read hs/gs 
//parameter ST_GHMUL=4'h2;  //t1=gs.*otherexpos（雅克比坐标�? t2=hs.*otherexpos（雅克比坐标�?
//parameter ST_GHADD=4'h3;  //gt=gt.+t1（仿射坐标，�?要坐标转换） ht=ht.+t2（仿射坐标，�?要坐标转换）
//parameter ST_MULAB=4'h4;  //gt=gt.*a（仿射坐标，�?要坐标转换） ht=ht.*b（雅克比坐标�?
//parameter ST_UMULT=4'h5;  //t3=u.*ab（雅克比坐标�? t5=gt.+ht（仿射坐标，�?要坐标转换）
//parameter ST_TADD6=4'h6;  //t6=t5.+t3（仿射坐标，�?要坐标转换）
//parameter ST_TENDP=4'h7;  //dotT end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		dott_state<=ST_TIDLE;
	else 
	begin
		case(dott_state)
			ST_TIDLE:begin
				if(dotpp_end)
					dott_state<=ST_RGSHS;
			end
			ST_RGSHS:begin
				if(rgshs_end)
					dott_state<=ST_GHMUL;
			end
			ST_GHMUL:begin
				if(ghmul_end)
					dott_state<=ST_GHADD;
			end
			ST_GHADD:begin
				if(ghadd_end)
				begin
					if(ghmul_cnt==otherexpos_num-1) 
						dott_state<=ST_MULAB;
					else 
						dott_state<=ST_RGSHS;
				end
			end
			ST_MULAB:begin
				if(mulab_end)
				dott_state<=ST_UMULT;
			end
			ST_UMULT:begin
				if(umult_end)
					dott_state<=ST_TADD6;
			end
			ST_TADD6:begin
				if(tadd6_end)
					dott_state<=ST_TENDP;
			end
			ST_TENDP:begin
				dott_state<=ST_TIDLE;
			end
			default:dott_state<=ST_TIDLE;
		endcase
	end
end

/**********************************hash256****************************/	
(*mark_debug = "true"*) wire [255:0]hash;
(*mark_debug = "true"*) wire [255:0]hash256;
		
/*sha256_core sha256(
    .clk_i(clk_i),
	.arst_ni(arst_ni),
	.start_i(block_str),  
	.first_i(block_one),  
	.valid_i(valid), 
    .text_i(text),
	.hend_o(block_end),
	.busy_o(),
    .hash_o(hash)
); */

keccak256 keccak256(
	.clk_i(clk_i),
	.arst_ni(arst_ni),
	.kstart_i(block_str),
	.bfirst_i(block_one),
    .kblock_i(text),
	.finish_o(block_end),
    .kec256_o(hash256)
);

//`ifdef SIM_EN
//always @(*)
//begin
//	if(challenges_cnt==0)
//		hash256=256'h5335b8325be171b134646245f43b9807a3db820019fccc6ae5d2275969557447;
//	else if(challenges_cnt==1)
//		hash256=256'h74b8e8860a2f24885bd655a936c006add6f347b9bb98bed1e065e1c2d6c9b9b1;
//	else if(challenges_cnt==2)
//		hash256=256'hd47deb466c8789fa11bb96469226882eace56385ab7c4579f3f5ac697435e298;
//	else if(challenges_cnt==3)
//		hash256=256'hfa195572ae85d561a6bf9958040376a11de873ff65db43d3f52fcecd68946b66;
//	else
//		hash256=256'h4e3162ed6c78cec01d10c4cc7f3ac23f5f0d9a6e4f9daa0157d3fd3e565451cd;
//end
//`else
//always @(*)
//begin
//	hash256=hash;
//end
//`endif

/****************************modP********************************/
	
data_modp data_modp(
	.clk_i(clk_i),
	.arst_ni(arst_ni),
	.dstr_i(cmodp_str),
	.modp_i(GROUP_ORDER),
	.data_i(hash256),      
	.dend_o(cmodp_end),
	.derr_o(),
	.dmod_o(dmod)      
);

//**********************************field caculate******************************//
reg  mode;
reg  [255:0]data,datb;

assign expmu_str=cmodp_end|cmult_end|cexp1_end|cexp2_end|oexpo_str|omuab_end|oredy_end|oexpo_end|dotpp_end;

always @(*)
begin
	if(cmodp_end) //otherexpos[0]=otherexpos[0]*challenges[i]
	begin
		mode=1; 
		data=dmod;
		datb=otherexpos[0];
	end
	else if(cmult_end)  //t1=challenges(i)**2
	begin
		mode=1;
		data=dmod;
		datb=dmod;
	end
	else if(cexp1_end)  //t2=challenges(i)**n(n=GORDER_SUB2)
	begin
		mode=0;
		data=dmod;
		datb=GORDER_SUB2;
	end
	else if(cexp2_end)  //t3=t2**2
	begin
		mode=1;
		data=dexp;
		datb=dexp;
	end
	else if(oexpo_str)  //a*b
	begin
		mode=1;
		data=a;
		datb=b;
	end
	else if(omuab_end)  //otherexpos[0]**GORDER_SUB2
	begin
		mode=0;
		data=otherexpos[0];
		datb=GORDER_SUB2;
	end
	else if(oredy_end)  //t=challenges**2
	begin
		mode=1;
		data=challenges[ci];
		datb=challenges[ci];
	end
	else if(oexpo_end)  //t*otherexpos
	begin
		mode=1;
		data=dexp;
		datb=otherexpos[oi];
	end
	else
	begin
		mode=0;
		data=0;
		datb=0;
	end
end

proof_exp_mul proof_exp_mul(
	.clk_i(clk_i),
	.arst_ni(arst_ni),
	.estr_i(expmu_str),
	.mode_i(mode),  //0:exp 1:mul
	.modp_i(GROUP_ORDER),
	.preu_i(PREU_GROUP),
	.data_i(data),
	.expo_i(datb),
	.eend_o(expmu_end),
	.eerr_o(),
	.dexp_o(dexp)
);

/***********************curve caculate A*****************************/

assign cstra=denda&cenba;
assign padd1_end=(dotp_state==ST_PADD1)&denda;
assign padd2_end=(dotp_state==ST_PADD2)&cendb;
assign zeroa=(dott_state==ST_GHADD)&(ghmul_cnt==0);

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		gt[1]<=0;
		gt[0]<=0;
	end
	else if(dotpp_end)
	begin
		gt[1]<=0;
		gt[0]<=0;
	end
	else if(ghadd_end)
	begin
		gt[1]<=dotja[2];
		gt[0]<=dotja[1];
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		cenba<=0;
	else if(cenda)
		cenba<=0;
	else if(cexp1_end|ghmul_end|gthtp_end|umult_end)
		cenba<=1;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		dstra<=0;
	else 
		dstra<=cexp1_end|pmult_end|rgshs_end|ghmul_end|gthtp_end|mulab_end|umult_end;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		opera<=0;
		kinta<=0;
		dotpa[1]<=0;
		dotpa[0]<=0;
		dotqa[2]<=0;
		dotqa[1]<=0; 
		dotqa[0]<=0;
	end	
	else if(cexp1_end)  //计算P1(仿射坐标)=t1.*ls(�?要坐标转换）
	begin
		opera<=0;
		kinta<=dexp;
		dotpa[1]<=p1_x;
		dotpa[0]<=p1_y;
		dotqa[2]<=0;
		dotqa[1]<=0; 
		dotqa[0]<=1;
	end
	else if(pmult_end)  //计算P3(雅克比坐标）=P1(仿射坐标�?+P2(雅克比坐�?)
	begin
		opera<=1;
		kinta<=0;
		dotpa[1]<=dotja[2];
		dotpa[0]<=dotja[1];
		dotqa[2]<=dotjb[2];
		dotqa[1]<=dotjb[1]; 
		dotqa[0]<=dotjb[0];
	end
	else if(rgshs_end)  //计算t1(雅克比坐标）=gs.*otherexpos(i)
	begin
		opera<=0;
		kinta<=otherexpos[ghmul_cnt];
		dotpa[1]<=p1_x;
		dotpa[0]<=p1_y;
		dotqa[2]<=0;
		dotqa[1]<=0; 
		dotqa[0]<=1;
	end
	else if(ghmul_end)  //计算gt=gt.+t1（仿射坐标，�?要坐标转换）
	begin
		opera<=1;
		kinta<=0;
		dotpa[1]<=gt[1];
		dotpa[0]<=gt[0];
		dotqa[2]<=dotja[2];
		dotqa[1]<=dotja[1]; 
		dotqa[0]<=dotja[0];
	end
	else if(gthtp_end)  //计算gt=gt.*a（仿射坐标，�?要坐标转换）
	begin
		opera<=0;
		kinta<=a;
		dotpa[1]<=gt[1];
		dotpa[0]<=gt[0];
		dotqa[2]<=0;
		dotqa[1]<=0; 
		dotqa[0]<=1;
	end
	else if(mulab_end)  //计算t3=u.*ab（雅克比坐标�?
	begin
		opera<=0;
		kinta<=mul_ab;
		dotpa[1]<=ux;
		dotpa[0]<=uy;
		dotqa[2]<=0;
		dotqa[1]<=0; 
		dotqa[0]<=1;
	end
	else if(umult_end)  //计算t6=t5.+t3（仿射坐标，�?要坐标转换）
	begin
		opera<=1;
		kinta<=0;
		dotpa[1]<=dotjb[2];
		dotpa[0]<=dotjb[1];
		dotqa[2]<=dotja[2];
		dotqa[1]<=dotja[1]; 
		dotqa[0]<=dotja[0];
	end
end

curve_operate curve_operateA(
	.clk_i(clk_i),
	.arst_ni(arst_ni),
	.cstr_i(cstra),  				//坐标转换操作启动
	.dstr_i(dstra),  				//点乘/点加操作启动
	.oper_i(opera),  				//点操作模式：0点乘 1点加
	.zero_i(zeroa),  				//零点指示
	.kint_i(kinta),               	//点乘操作整数输入
	.dotp_i(dotpa),       			//点P的仿射坐�?(x,y)
	.dotq_i(dotqa),       			//点Q的雅克比坐标(x,y,z)
	.modp_i(FILED_ORDER),
	.preu_i(PREU_FILED),
	.dend_o(denda),
	.cend_o(cenda),
	.busy_o(),
	.dotJ_o(dotja)       			//点操作的坐标
);

/***********************curve caculate B*****************************/
assign cstrb=dendb&cenbb;
assign zerob=(dott_state==ST_GHADD)&(ghmul_cnt==0);

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		ht[1]<=0;
		ht[0]<=0;
	end
	else if(dotpp_end)
	begin
		ht[1]<=0;
		ht[0]<=0;
	end
	else if(ghadd_end)
	begin
		ht[1]<=dotjb[2];
		ht[0]<=dotjb[1];
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		cenbb<=0;
	else if(cendb)
		cenbb<=0;
	else if(padd1_end|ghmul_end|mulab_end)
		cenbb<=1;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		dstrb<=0;
	else 
		dstrb<=cexp3_end|padd1_end|rgshs_end|ghmul_end|gthtp_end|mulab_end;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		operb<=0;
		kintb<=0;
		dotpb[1]<=0;
		dotpb[0]<=0;
		dotqb[2]<=0;
		dotqb[1]<=0; 
		dotqb[0]<=0;
	end	
	else if(cexp3_end)  //计算P2（雅克比坐标�?=t3.*rs
	begin
		operb<=0;
		kintb<=dexp;
		dotpb[1]<=p2_x;
		dotpb[0]<=p2_y;
		dotqb[2]<=0;
		dotqb[1]<=0; 
		dotqb[0]<=1;
	end
	else if(padd1_end)  //计算P(仿射坐标�?=P(仿射坐标�?+P3(雅克比坐�?) (�?要坐标转换）
	begin
		operb<=1;
		kintb<=0;
		dotpb[1]<=p_x;
		dotpb[0]<=p_y;
		dotqb[2]<=dotja[2];
		dotqb[1]<=dotja[1]; 
		dotqb[0]<=dotja[0];
	end
	else if(rgshs_end)  //计算t2=hs.*otherexpos(n-1-i)（雅克比坐标�?
	begin
		operb<=0;
		kintb<=otherexpos[otherexpos_num-1-ghmul_cnt];
		dotpb[1]<=p2_x;
		dotpb[0]<=p2_y;
		dotqb[2]<=0;
		dotqb[1]<=0; 
		dotqb[0]<=1;
	end
	else if(ghmul_end)  //计算ht=ht.+t2（仿射坐标，�?要坐标转换）
	begin
		operb<=1;
		kintb<=0;
		dotpb[1]<=ht[1];
		dotpb[0]<=ht[0];
		dotqb[2]<=dotjb[2];
		dotqb[1]<=dotjb[1]; 
		dotqb[0]<=dotjb[0];
	end
	else if(gthtp_end)  //计算ht=ht.*b（雅克比坐标�?
	begin
		operb<=0;
		kintb<=b;
		dotpb[1]<=ht[1];
		dotpb[0]<=ht[0];
		dotqb[2]<=0;
		dotqb[1]<=0; 
		dotqb[0]<=1;
	end
	else if(mulab_end)  //计算t5=gt.+ht（仿射坐标，�?要坐标转换）
	begin
		operb<=1;
		kintb<=0;
		dotpb[1]<=dotja[2];
		dotpb[0]<=dotja[1];
		dotqb[2]<=dotjb[2];
		dotqb[1]<=dotjb[1]; 
		dotqb[0]<=dotjb[0];
	end
end

curve_operate curve_operateB(
	.clk_i(clk_i),
	.arst_ni(arst_ni),
	.cstr_i(cstrb),  				//坐标转换操作启动
	.dstr_i(dstrb),  				//点乘/点加操作启动
	.oper_i(operb),  				//点操作模式：0点乘 1点加
	.zero_i(zerob),  				//零点指示
	.kint_i(kintb),               	//点乘操作整数输入
	.dotp_i(dotpb),       			//点P的仿射坐�?(x,y)
	.dotq_i(dotqb),       			//点Q的雅克比坐标(x,y,z)
	.modp_i(FILED_ORDER),
	.preu_i(PREU_FILED),
	.dend_o(dendb),
	.cend_o(cendb),
	.busy_o(),
	.dotJ_o(dotjb)       			//点操作的坐标
);

/****************************P/T点坐�?***********************************/
assign proof_end=(dott_state==ST_TENDP)?1:0;

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		p_x<=0;
		p_y<=0;
	end
	else if(rxpkg_end)
	begin
		p_x<=px;
		p_y<=py;
	end
	else if(padd2_end)
	begin
		p_x<=dotjb[2];
		p_y<=dotjb[1];
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		proof_res<=0;
	else if(rxpkg_end)
		proof_res<=0;
	else if(tadd6_end)
		proof_res=(p_x!=dotja[2])|(p_y!=dotja[1]);
end

endmodule