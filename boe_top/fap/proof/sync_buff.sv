module sync_buff
//global parameter define
#(
    parameter BUFF_DATA_BWID=64,   					        //缓存数据位宽
	parameter BUFF_DATA_DEEP=512,   					        //缓存数据深度
	parameter BUFF_ADDR_BWID=9 					            //缓存地址位宽
)   
//IO port define    
(   
	input  arst_ni,                                             //全局异步复位信号
	input  axi_clock_i,
	//write In port
	input  axi_valid_i,        						            //写入数据有效指示
	input  axi_tlast_i,                                         //数据结束指示
	input  [BUFF_DATA_BWID-1:0]axi_tdata_i,			                        //写入数据
	output axi_ready_o,                                         //写入接口准备好指示                                       //写入流控指示
	//read out port
	input  axi_ready_i,                                         //读出接口准备好指示
	output axi_valid_o,        						            //读出数据有效指示
	output axi_tlast_o,        						            //数据结束指示
	output [BUFF_DATA_BWID-1:0]axi_tdata_o 			            //读出数据
);

//reg
reg [BUFF_ADDR_BWID-1:0]buff_wadd;
reg [BUFF_ADDR_BWID-1:0]buff_radd;
reg buff_rbsy; 
reg axi_valid; 
reg [7:0]packg_cnt;                             
//wire  
wire buff_wren;
wire buff_wend;
wire buff_rstr;
wire buff_roths;
wire buff_rden;
wire buff_rend;
wire buff_vlid;
wire [BUFF_DATA_BWID:0]buff_wdat;	
wire [BUFF_DATA_BWID:0]buff_rdat;		

//***********************************************************************//
assign axi_ready_o=1;
assign axi_valid_o=axi_valid;
assign axi_tlast_o=axi_valid&buff_rdat[BUFF_DATA_BWID];
assign axi_tdata_o=buff_rdat[BUFF_DATA_BWID-1:0];
 
//*********************buff write*******************************//
assign buff_wren=axi_valid_i&axi_ready_o;
assign buff_wend=axi_tlast_i&axi_ready_o;
assign buff_wdat={buff_wend,axi_tdata_i};

//buff_wadd
always @(posedge axi_clock_i or negedge arst_ni)
begin
	if(~arst_ni)
		buff_wadd<=0;
	else if(buff_wren)
		buff_wadd<=buff_wadd+1;
end

always @(posedge axi_clock_i or negedge arst_ni)
begin
	if(~arst_ni)
		packg_cnt<=0;
	else if(buff_wend&(~buff_rend))
		packg_cnt<=packg_cnt+1;
	else if(buff_rend&(~buff_wend))
		packg_cnt<=packg_cnt-1;
end

//*****************************buff read***************************//
assign buff_vlid=(packg_cnt>0)?1:0;
assign buff_rstr=(~buff_rbsy)&buff_vlid;  //第一次读
assign buff_roths=buff_rbsy&buff_vlid&axi_ready_i&(~buff_rdat[BUFF_DATA_BWID]);  //其他连续数据读
assign buff_rden=buff_rstr|buff_roths;
assign buff_rend=buff_rbsy&axi_ready_i&buff_rdat[BUFF_DATA_BWID];

//buff_rbsy
always @(posedge axi_clock_i or negedge arst_ni)
begin
	if(~arst_ni)
		buff_rbsy<=0;
	else if(buff_rstr)
		buff_rbsy<=1;
	else if(buff_rend)
		buff_rbsy<=0;
end

//buff_radd
always @(posedge axi_clock_i or negedge arst_ni)
begin
	if(~arst_ni)
		buff_radd<=0;
	else if(buff_rden)
		buff_radd<=buff_radd+1;
end

//axi_valid
always @(posedge axi_clock_i or negedge arst_ni)
begin
	if(~arst_ni)
		axi_valid<=0;
	else if(buff_rden)
		axi_valid<=1;
	else if(axi_ready_i)
		axi_valid<=0;
end

//**************************buff ram*****************//

dpram512x65 dpram512x65_u(
  .clka(axi_clock_i), 
  .wea(buff_wren), 
  .addra(buff_wadd), 
  .dina(buff_wdat), 
  .clkb(axi_clock_i), 
  .enb(buff_rden), 
  .addrb(buff_radd), 
  .doutb(buff_rdat) 
);

endmodule



    
	