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

module toe
   (
	input          	rsti  			,
	input			clki			,
  	input	[127:0]	axis_rxd_tdata	,
  	input	[15:0]	axis_rxd_tkeep	,
  	input			axis_rxd_tlast	,
  	output			axis_rxd_tready	,
  	input			axis_rxd_tvalid	,
  	output	[127:0]	axis_txd_tdata	,
  	output	[15:0]	axis_txd_tkeep	,
  	output			axis_txd_tlast	,
  	input			axis_txd_tready	,
  	output			axis_txd_tvalid	,
  	
  	input			gmii_rxci		,
  	input	[7:0]	gmii_rxdi		,
  	input			gmii_rxdvi		,
  	input			gmii_rxeri		,
  	output			gmii_txco		,
  	output	[7:0]	gmii_txdo		,
  	output			gmii_txeno		,
  	output			gmii_txero		
);

	assign axis_rxd_tready = 1'd0;
	assign axis_txd_tdata  = 128'd0;
	assign axis_txd_tkeep  = 16'd0;
	assign axis_txd_tvalid = 1'd0;


endmodule
