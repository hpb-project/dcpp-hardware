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

module arm
   (
	input          	rsti  			,
	input			clki			,
  	input	[63:0]	axis_rxd_tdata	,
  	input	[7:0]	axis_rxd_tkeep	,
  	input			axis_rxd_tlast	,
  	output			axis_rxd_tready	,
  	input			axis_rxd_tvalid	,
  	output	[63:0]	axis_txd_tdata	,
  	output	[7:0]	axis_txd_tkeep	,
  	output			axis_txd_tlast	,
  	input			axis_txd_tready	,
  	output			axis_txd_tvalid	
);

	arm_core arm_core(
  		.aresetn				(~rsti				),
  		.aclk					(clki				),
  		.AXI_STR_RXD_tdata		(axis_rxd_tdata	 	),
  		.AXI_STR_RXD_tkeep		(axis_rxd_tkeep	 	),
  		.AXI_STR_RXD_tlast		(axis_rxd_tlast	 	),
  		.AXI_STR_RXD_tready		(axis_rxd_tready	),
  		.AXI_STR_RXD_tvalid		(axis_rxd_tvalid	),
  		.AXI_STR_TXD_tdata		(axis_txd_tdata	 	),
  		.AXI_STR_TXD_tkeep		(axis_txd_tkeep	 	),
  		.AXI_STR_TXD_tlast		(axis_txd_tlast	 	),
  		.AXI_STR_TXD_tready		(axis_txd_tready	),
  		.AXI_STR_TXD_tvalid		(axis_txd_tvalid	)
	);

endmodule
