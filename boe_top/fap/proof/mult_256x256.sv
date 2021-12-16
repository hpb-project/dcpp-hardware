module mult_256x256(
input   clk_i,
input   arst_ni,
input   mstr_i,
input   [255:0]mmda_i,
input   [255:0]mmdb_i,
output  merr_o,
output  mend_o,
output  [511:0]mult_o
);

parameter MPPX=5;  //乘法器pipeline延迟

reg  busy;
reg  [255:0]mmda;
reg  [255:0]mmdb;
reg  [  4:0]step;
reg  [255:0]aa1;
reg  [255:0]ab1;
reg  [255:0]aa2;
reg  [255:0]ab2;
reg  [255:0]sum_hgh;
reg  [255:0]sum_low;
reg  [2:0]cry_low;

//wire
wire mend;
wire [ 63:0]da[15:0];
wire [ 63:0]db[15:0];
wire [ 63:0]ma;
wire [ 63:0]mb;
wire [127:0]mc;
wire [255:0]sum1;  			//加法器求和输�?
wire [255:0]sum2;  			//加法器求和输�?
wire co1;                   //加法器进位输�?
wire co2;          			//加法器进位输�?
wire [511:0]mult;


//**********************************************************************************//
assign mend_o=mend;
assign mult_o=mult;

//************************************仿真比较***************************************//

//synthesis translate_off
reg [511:0]c_t;
assign merr_o=mend&(mult!=c_t);

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		c_t<=0;
	else if(mstr_i)
		c_t<=mmda_i*mmdb_i;
end
//synthesis translate_on

//***************************************************************************//
assign mend=(step==MPPX+16)?1:0;

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		mmda<=0;
		mmdb<=0;
	end
	else if(mstr_i)
	begin
		mmda<=mmda_i;
		mmdb<=mmdb_i;
	end	
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		step<=0;
	else if(mstr_i)
		step<=0;
	else if(busy)
		step<=step+1;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		busy<=0;
	else if(mstr_i)
		busy<=1;
	else if(mend)
		busy<=0;
end

//*****************************乘法器控�?******************************//
assign da[ 0]=mmda[ 63:  0];
assign db[ 0]=mmdb[ 63:  0];
assign da[ 1]=mmda[ 63:  0];
assign db[ 1]=mmdb[127: 64];
assign da[ 2]=mmda[ 63:  0];
assign db[ 2]=mmdb[191:128];
assign da[ 3]=mmda[ 63:  0];
assign db[ 3]=mmdb[255:192];
assign da[ 4]=mmda[127: 64];
assign db[ 4]=mmdb[ 63:  0];
assign da[ 5]=mmda[127: 64];
assign db[ 5]=mmdb[127: 64];
assign da[ 6]=mmda[127: 64];
assign db[ 6]=mmdb[191:128];
assign da[ 7]=mmda[127: 64];
assign db[ 7]=mmdb[255:192];
assign da[ 8]=mmda[191:128];
assign db[ 8]=mmdb[ 63:  0];
assign da[ 9]=mmda[191:128];
assign db[ 9]=mmdb[127: 64];
assign da[10]=mmda[191:128];
assign db[10]=mmdb[191:128];
assign da[11]=mmda[191:128];
assign db[11]=mmdb[255:192];
assign da[12]=mmda[255:192];
assign db[12]=mmdb[ 63:  0];
assign da[13]=mmda[255:192];
assign db[13]=mmdb[127: 64];
assign da[14]=mmda[255:192];
assign db[14]=mmdb[191:128];
assign da[15]=mmda[255:192];
assign db[15]=mmdb[255:192];
assign ma=(step<=15)?da[step]:0;
assign mb=(step<=15)?db[step]:0;

mult_gen_0 mult_gen_1(
	.CLK(clk_i),
	.A(ma),
	.B(mb),
	.P(mc)
);

//*************************************加法器控�?***********************************//	
assign mult={sum_hgh,sum_low};
	
always @(*)
begin
	case(step)
		MPPX :begin
			aa1=sum_hgh;
			ab1=0;  
			aa2=sum_low;
			ab2=mc;
		end
		MPPX+1 :begin
			aa1=sum_hgh;
			ab1=0;
			aa2=sum_low;
			ab2={mc,64'd0};
		end
		MPPX+2 :begin
			aa1=sum_hgh;
			ab1=0;
			aa2=sum_low;
			ab2={mc,128'd0};
		end
		MPPX+3 :begin
			aa1=sum_hgh;
			ab1=mc[127:64];
			aa2=sum_low;
			ab2={mc[63:0],192'd0};
		end
		MPPX+4 :begin
			aa1=sum_hgh;
			ab1=0;
			aa2=sum_low;
			ab2={mc,64'd0};
		end
		MPPX+5 :begin
		    aa1=sum_hgh;
			ab1=0;
			aa2=sum_low;
			ab2={mc,128'd0};
		end
		MPPX+6 :begin
			aa1=sum_hgh;
			ab1=mc[127:64];
			aa2=sum_low;
			ab2={mc[63:0],192'd0};
		end 
		MPPX+7 :begin
			aa1=sum_hgh;
			ab1=mc;
			aa2=sum_low;
			ab2=0;
		end
		MPPX+8 :begin
			aa1=sum_hgh;
			ab1=0;
			aa2=sum_low;
			ab2={mc,128'd0};
		end
		MPPX+9 :begin
			aa1=sum_hgh;
			ab1=mc[127:64];
			aa2=sum_low;
			ab2={mc[63:0],192'd0};
		end
		MPPX+10:begin
			aa1=sum_hgh;
			ab1=mc;
			aa2=sum_low;
			ab2=0;
		end
		MPPX+11:begin
			aa1=sum_hgh;
			ab1={mc,64'd0};
			aa2=sum_low;
			ab2=0;
		end
		MPPX+12:begin
			aa1=sum_hgh;
			ab1=mc[127:64];
			aa2=sum_low;
			ab2={mc[63:0],192'd0};
		end
		MPPX+13:begin
			aa1=sum_hgh;
			ab1=mc;
			aa2=sum_low;
			ab2=0;
		end
		MPPX+14:begin
			aa1=sum_hgh;
			ab1={mc,64'd0};
			aa2=sum_low;
			ab2=0;
		end
		MPPX+15:begin
			aa1=sum_hgh;
			ab1={mc,128'd0}+cry_low;
			aa2=sum_low;
			ab2=0;
		end
		default:begin
			aa1=0;
			ab1=0;
			aa2=0;
			ab2=0;
		end
	endcase
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		sum_hgh<=0;
		sum_low<=0;
		cry_low<=0;
	end
	else if(mstr_i)
	begin
		sum_hgh<=0;
		sum_low<=0;
		cry_low<=0;
	end
	else if((step>=MPPX)&(step<=MPPX+15))
	begin
		sum_hgh<=sum1;
		sum_low<=sum2;
		cry_low<=cry_low+co2;
	end
end


addsub addsub1(
  .A(aa1),      // input wire [255 : 0] A
  .B(ab1),      // input wire [255 : 0] B
  .ADD(1),  	// input wire ADD
  .C_IN(0),  	//carry in
  .C_OUT(co1),
  .S(sum1)      // output wire [255 : 0] S
);

addsub addsub2(
  .A(aa2),      // input wire [255 : 0] A
  .B(ab2),      // input wire [255 : 0] B
  .ADD(1),  	// input wire ADD
  .C_IN(0),  	//carry in
  .C_OUT(co2),
  .S(sum2)      // output wire [255 : 0] S
);

endmodule