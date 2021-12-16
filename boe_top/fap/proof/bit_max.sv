module bit_max(
input   clk_i,
input   arst_ni,
input   dstr_i,
input   [255:0]data_i,
output  dend_o,
output  [7:0]bmax_o
);

wire [15:0][15:0]data;
reg [4:0]dmax[16];
reg [7:0]bmax;
reg [1:0]dstr_d2;

//******************************************************************************//
assign dend_o=dstr_d2[1];
assign bmax_o=bmax;

//******************************************************************************//
assign data=data_i;

generate
	genvar i;
	for(i=0;i<16;i=i+1) 
	begin:dmax16	
		always @(posedge clk_i or negedge arst_ni)
		begin
			if(~arst_ni)
				dmax[i]<=0;
			else if(dstr_i)
			begin
				if(data[i][15])
					dmax[i]<=16;
				else if(data[i][14])
					dmax[i]<=15;
				else if(data[i][13])
					dmax[i]<=14;
				else if(data[i][12])
					dmax[i]<=13;
				else if(data[i][11])
					dmax[i]<=12;
				else if(data[i][10])
					dmax[i]<=11;
				else if(data[i][9])
					dmax[i]<=10;
				else if(data[i][8])
					dmax[i]<=9;
				else if(data[i][7])
					dmax[i]<=8;
				else if(data[i][6])
					dmax[i]<=7;
				else if(data[i][5])
					dmax[i]<=6;
				else if(data[i][4])
					dmax[i]<=5;
				else if(data[i][3])
					dmax[i]<=4;
				else if(data[i][2])
					dmax[i]<=3;
				else if(data[i][1])
					dmax[i]<=2;
				else if(data[i][0])
					dmax[i]<=1;
				else 
					dmax[i]<=0;
			end
		end
	end
endgenerate

always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		dstr_d2<=0;
	else
		dstr_d2<={dstr_d2[0],dstr_i};
end
	
always @(posedge clk_i or negedge arst_ni)
begin
	if(~arst_ni)
		bmax<=0;
	else if(dstr_i)
		bmax<=0;
	else if(dstr_d2[0])
	begin
		if(dmax[15])
			bmax<=(15<<4)+(dmax[15]-1);
		else if(dmax[14])
			bmax<=(14<<4)+(dmax[14]-1);
		else if(dmax[13])
			bmax<=(13<<4)+(dmax[13]-1);
		else if(dmax[12])
			bmax<=(12<<4)+(dmax[12]-1);
		else if(dmax[11])
			bmax<=(11<<4)+(dmax[11]-1);
		else if(dmax[10])
			bmax<=(10<<4)+(dmax[10]-1);
		else if(dmax[9])
			bmax<=(9<<4)+(dmax[9]-1);
		else if(dmax[8])
			bmax<=(8<<4)+(dmax[8]-1);
		else if(dmax[7])
			bmax<=(7<<4)+(dmax[7]-1);
		else if(dmax[6])
			bmax<=(6<<4)+(dmax[6]-1);
		else if(dmax[5])
			bmax<=(5<<4)+(dmax[5]-1);
		else if(dmax[4])
			bmax<=(4<<4)+(dmax[4]-1);
		else if(dmax[3])
			bmax<=(3<<4)+(dmax[3]-1);
		else if(dmax[2])
			bmax<=(2<<4)+(dmax[2]-1);
		else if(dmax[1])
			bmax<=(1<<4)+(dmax[1]-1);
		else
			bmax<=dmax[0]-1;
	end
end

endmodule
		
		

