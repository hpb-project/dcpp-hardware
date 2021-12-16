/*************小系�?(m<=15)乘法运算(a*m)mod(modp_i)**********************************/
module proof_mcoef(
input   clk_i,
input   arst_ni,
input   mstr_i,
input	[ 3:0]coef_i,  //<=15
input   [255:0]modp_i,
input   [255:0]mdat_i,
output  mend_o,
output  merr_o,
output  [255:0]mult_o
);

parameter ST_IDLE=3'd0;
parameter ST_M2SP=3'd1;  //计算t*2-modp_i
parameter ST_ADD1=3'd2;  //计算t+a
parameter ST_CMPP=3'd3;  //计算t-modp_i
parameter ST_MEND=3'd4;  //计算完毕

wire fc,cbit,cend,mend;
wire [256:0]t;

reg [3:0]coef;
reg [1:0]curb;  //coef相乘运算当前使用的bit�?
reg [2:0]state;
reg add;
reg [255:0]mdat,mult;
reg [256:0]a,b;

//*********************************************************************************//
assign mend_o=(state==ST_MEND)?1:0;
assign mult_o=mult;

//********************************仿真比较****************************************//

//synthesis translate_off
reg [259:0]s;

assign merr_o=mend_o&(mult!=s);

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		s=0;
	else if(mstr_i)
	begin
		s=coef_i*mdat_i;
		while(s>modp_i)
			s=s-modp_i;
	end
end
//synthesis translate_on

//********************************coef(<=15)相乘计算*******************************//
assign fc=t[256];
assign cbit=coef[curb];
assign cend=((state==ST_M2SP)&(~cbit))|(state==ST_CMPP);
assign t=add?(a+b):(a-b);
assign mend=cend&(curb==0);

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		coef<=0;
		mdat<=0;
	end
	else if(mstr_i)
	begin
		coef<=coef_i;
		mdat<=mdat_i;
	end
end
	
always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		curb<=0;
	else if(mstr_i)
	begin
		if(coef_i>=8)
			curb<=2;
		else if(coef_i>=4)
			curb<=1;
		else
			curb<=0;
	end
	else if(cend)
		curb<=curb-1;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		mult<=0;
	else if(mstr_i)
	begin
		if(coef_i==1)
			mult<=mdat_i;
		else 
			mult<=0;
	end
	else if(mend)
	begin
		if(fc)
			mult<=a;
		else
			mult<=t;
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		a<=0;
		b<=0;
		add<=0;
	end
	else if(mstr_i)
	begin
		a<=mdat_i<<1;
		b<=modp_i;
		add<=0;
	end
	else if(state==ST_M2SP)
	begin
		if(fc)  //2t<modp_i:2t mod(modp_i)=2t
		begin
			if(cbit)  //准备计算t+a
			begin
				a<=a;
				b<=mdat;
				add<=1;
			end
			else  //准备计算2t-modp_i
			begin
				a<=a<<1;
				b<=modp_i;
				add<=0;
			end
		end
		else //2t>modp_i:2t mod(modp_i)=2t-modp_i
		begin
			if(cbit)  //准备计算t+a
			begin
				a<=t;
				b<=mdat;
				add<=1;
			end
			else  //准备计算2t-modp_i
			begin
				a<=t<<1;
				b<=modp_i;
				add<=0;
			end
		end
	end
	else if(state==ST_ADD1)  //准备计算t-modp_i
	begin
		a<=t;
		b<=modp_i;
		add<=0;
	end
	else if(state==ST_CMPP)  //准备计算2t-modp_i
	begin
		if(fc)  //t<modp_i:t mod(modp_i)=t
		begin
			a<=a<<1;
			b<=modp_i;
			add<=0;
		end
		else  //t>modp_i:t mod(modp_i)=t-modp_i
		begin
			a<=t<<1;
			b<=modp_i;
			add<=0;
		end
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		state<=ST_IDLE;
	else 
	begin
		case(state)
			ST_IDLE:begin
				if(mstr_i)
				begin
					if(coef_i<=1)
						state<=ST_MEND;
					else 
						state<=ST_M2SP;
				end
			end
			ST_M2SP:begin
				if(cbit)
					state<=ST_ADD1;
				else if(mend)
					state<=ST_MEND;
			end
			ST_ADD1:begin
				state<=ST_CMPP;
			end
			ST_CMPP:begin
				if(mend)
					state<=ST_MEND;
				else
					state<=ST_M2SP;
			end
			ST_MEND:begin
				state<=ST_IDLE;
			end
			default:state<=ST_IDLE;
		endcase
	end
end

endmodule