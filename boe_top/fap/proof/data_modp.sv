/**************************data mod(P)**************************/
module data_modp(
input   clk_i,
input   arst_ni,
input   dstr_i,
input	[255:0]modp_i,
input   [255:0]data_i,      
output  dend_o,
output  derr_o,
output  [255:0]dmod_o      
);

reg  busy,dend_d;
reg  [255:0]a,b,dmod;

wire dend;
wire [256:0]sum;


//**********************************************************//
assign dend_o=dend_d;
assign dmod_o=dmod;

//*********************************************************//

//****************for sim********************************//
reg [255:0]t;

//synthesis translate_off
assign derr_o=dend_d&(dmod!=t);

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	    t=0;
	else if(dstr_i)
	begin
		t=data_i;
		while(t>=modp_i)
			t=t-modp_i;
	end
end
//synthesis translate_on			

//*******************************************************//
assign dend=busy&sum[256];

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		dend_d<=0;
		dmod<=0;
	end
	else 
	begin
		dend_d<=dend;
		dmod<=dend?a:dmod;
	end
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		busy<=0;
	else if(dstr_i)
		busy<=1;
	else if(dend)
		busy<=0;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		a<=0;
		b<=0;
	end
	else if(dstr_i) 
	begin
		a<=data_i;
		b<=modp_i;
	end
	else if(busy)
	begin
		a<=sum[255:0];
		b<=b;
	end
end

assign sum=a-b;

endmodule
			