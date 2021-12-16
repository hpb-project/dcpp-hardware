module proof_add_sub(
input   clk_i,
input   arst_ni,
input   dstr_i,
input   mode_i,
input	[255:0]modp_i,
input   [255:0]data_i,  
input   [255:0]datb_i,      
output  dend_o,
output  derr_o,
output  [255:0]datc_o      
);

reg  add,dend,mode,busy;
reg  [256:0]a,b,datc;
reg  [1:0]step;

wire [256:0]sum;


//**********************************************************//
assign dend_o=dend;
assign datc_o=datc[255:0];

//*********************************************************//

//****************for sim********************************//
reg [256:0]t;

//synthesis translate_off
assign derr_o=dend&(datc!=t[255:0]);

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	    t=0;
	else if(dstr_i)
	begin
		if(mode_i==0)
		begin
			t=data_i+datb_i;
			if(t>=modp_i)
				t=t-modp_i;
		end
		else
		begin
			if(data_i>=datb_i)
				t=data_i-datb_i;
			else 
				t=modp_i+data_i-datb_i;
		end
	end
end
//synthesis translate_on			

//*******************************************************//

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
		step<=0;
	else if(dstr_i)
		step<=1;
	else if(dend)
		step<=0;
	else if(busy)
		step<=step+1;
end

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
	begin
		a<=0;
		b<=0;
		add<=0;
		datc<=0;
		dend<=0;
		mode<=0;
	end
	else if(dstr_i)  //a+b/a-b
	begin
		a<=data_i;
		b<=datb_i;
		add<=~mode_i;
		mode<=mode_i;
		datc<=0;
		dend<=0;
	end
	else if(dend)
	begin
		a<=0;
		b<=0;
		add<=0;
		dend<=0;
	end
	else if(step==1)  
	begin
		if(mode==0)  //sum=a+b,则计算sum-modp
		begin
			a<=sum;  
			b<=modp_i;
			add<=0;
		end
		else if(c==1)//sum=a-b，且sum<0,则计算sum+modp
		begin
			a<=sum;
			b<=modp_i;
			add<=1;
		end
		else //sum=a-b,切sum>=0，则计算sum+0
		begin
			a<=sum;
			b<=0;
			add<=1;
		end
	end
	else if(step==2)
	begin
		if(mode==0) //sum-modp
		begin
			if(c==1) //sum-modp<0
			begin
				a<=0;  
				b<=0;
				add<=0;
				dend<=1;
				datc<=a;
			end
			else  //sum-modp>=0
			begin
				a<=0;
				b<=0;
				add<=0;
				dend<=1;
				datc<=sum;
			end
		end
		else //a-b
		begin
			a<=0;
			b<=0;
			add<=0;
			dend<=1;
			datc<=sum;
		end
	end
end

assign sum=add?(a+b):(a-b);
assign c=sum[256];

endmodule
			