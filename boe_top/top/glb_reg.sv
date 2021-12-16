//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.4.1 (win64) Build 2117270 Tue Jan 30 15:32:00 MST 2018
//Date        : Mon Mar 26 19:59:02 2018
//Host        : mayt-PC running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target boe_wrapper.bd
//Design      : boe_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module glb_reg
   (
	input	rsti  					,
	input	clki					,
	input	[31:0]	s_axil_awaddr	,
	input	[2:0]	s_axil_awprot	,
	input			s_axil_awvalid	,
	output			s_axil_awready	,
	input	[31:0]	s_axil_wdata	,
	input	[3:0]	s_axil_wstrb	,
	input			s_axil_wvalid	,
	output			s_axil_wready	,
	output			s_axil_bvalid	,
	output	[1:0]	s_axil_bresp	,
	input			s_axil_bready	,
	input	[31:0]	s_axil_araddr	,
	input	[2:0]	s_axil_arprot	,
	input			s_axil_arvalid	,
	output			s_axil_arready	,
	output	[31:0]	s_axil_rdata	,
	output	[1:0]	s_axil_rresp	,
	output			s_axil_rvalid	,
	input			s_axil_rready	,
		
	input			pcie_lnki		,
	output	[31:0]	ledo				
);

	wire			reg_rst;
	wire			reg_clk;
	wire			reg_en;
	wire	[3:0]	reg_we;
	wire	[15:0]	reg_ad;
	wire	[31:0]	reg_wd;
	reg		[31:0]	reg_rd;
	reg		[31:0]	gpo;
	
	assign ledo = gpo;
	
	reg_ctrl u_ctrl(
		.s_axi_aclk 		(clki						),
		.s_axi_aresetn 		(~rsti						),
		.s_axi_awaddr 		(s_axil_awaddr[15:0]		),
		.s_axi_awprot 		(s_axil_awprot				),
		.s_axi_awvalid 		(s_axil_awvalid				),
		.s_axi_awready 		(s_axil_awready				),
		.s_axi_wdata 		(s_axil_wdata				),
		.s_axi_wstrb 		(s_axil_wstrb				),
		.s_axi_wvalid 		(s_axil_wvalid				),
		.s_axi_wready 		(s_axil_wready				),
		.s_axi_bresp 		(s_axil_bresp				),
		.s_axi_bvalid 		(s_axil_bvalid				),
		.s_axi_bready 		(s_axil_bready				),
		.s_axi_araddr 		(s_axil_araddr[15:0]		),
		.s_axi_arprot 		(s_axil_arprot				),
		.s_axi_arvalid 		(s_axil_arvalid				),
		.s_axi_arready 		(s_axil_arready				),
		.s_axi_rdata 		(s_axil_rdata				),
		.s_axi_rresp 		(s_axil_rresp				),
		.s_axi_rvalid 		(s_axil_rvalid				),
		.s_axi_rready 		(s_axil_rready				),
		.bram_rst_a 		(reg_rst					),
		.bram_clk_a 		(reg_clk					),
		.bram_en_a 			(reg_en						),
		.bram_we_a 			(reg_we						),
		.bram_addr_a 		(reg_ad						),
		.bram_wrdata_a 		(reg_wd						),
		.bram_rddata_a 		(reg_rd						)
	);
	
	always@(posedge reg_rst or posedge reg_clk)
	begin
		if(reg_rst)begin
			reg_rd <= 32'd0;
		end
		else if(reg_en & !reg_we)begin
			case(reg_ad)
			16'h0000:	reg_rd <= 32'h88002019;
			16'h0001:	reg_rd <= 32'h04280000;
			16'h0020:	reg_rd <= gpo;
			default:	reg_rd <= 32'd0;
			endcase
		end
	end

	always@(posedge reg_rst or posedge reg_clk)
	begin
		if(reg_rst)begin
			gpo <= 32'd0;
		end
		else if(reg_en & reg_we)begin
			if(reg_ad ==16'h0020) gpo <= reg_wd;
		end
	end

endmodule
