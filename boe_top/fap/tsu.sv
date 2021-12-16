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

module tsu
   (
	input          	rsti  			,
	input			clki			,
	input           clk62mi         ,
  	input	[63:0]	axis_rxd_tdata	,
  	input	[7:0]	axis_rxd_tkeep	,
  	input			axis_rxd_tlast	,
  	input			axis_rxd_tvalid	,
  	output			axis_rxd_tready	,
  	output	[63:0]	axis_txd_tdata	,
  	output	[7:0]	axis_txd_tkeep	,
  	output			axis_txd_tlast	,
  	output			axis_txd_tvalid	,
  	input			axis_txd_tready	,
  	
	output	[63:0]	prof_rx_tdatao	,
	output	[7:0]	prof_rx_tkeepo	,
	output			prof_rx_tlasto	,
	output			prof_rx_tvalido	,
	input			prof_rx_treadyi	,
	input	[63:0]	prof_tx_tdatai	,
	input	[7:0]	prof_tx_tkeepi	,
	input			prof_tx_tlasti	,
	input			prof_tx_tvalidi	,
	output			prof_tx_treadyo	,
  	
	output	[63:0]	vrfy_rx_tdatao	,
	output	[7:0]	vrfy_rx_tkeepo	,
	output			vrfy_rx_tlasto	,
	output			vrfy_rx_tvalido	,
	input			vrfy_rx_treadyi	,
	input	[63:0]	vrfy_tx_tdatai	,
	input	[7:0]	vrfy_tx_tkeepi	,
	input			vrfy_tx_tlasti	,
	input			vrfy_tx_tvalidi	,
	output			vrfy_tx_treadyo	,
	
    output  [63:0]   prbs_rx_tdatao    ,
    output  [7:0]    prbs_rx_tkeepo    ,
    output           prbs_rx_tlasto    ,
    output           prbs_rx_tvalido    ,
    input            prbs_rx_treadyi    ,
    input    [63:0]  prbs_tx_tdatai    ,
    input    [7:0]   prbs_tx_tkeepi    ,
    input            prbs_tx_tlasti    ,
    input            prbs_tx_tvalidi    ,
    output           prbs_tx_treadyo    ,
	
    output   [63:0]   prbs1_rx_tdatao    ,
    output   [7:0]    prbs1_rx_tkeepo    ,
    output            prbs1_rx_tlasto    ,
    output            prbs1_rx_tvalido    ,
    input             prbs1_rx_treadyi    ,
    input    [63:0]   prbs1_tx_tdatai    ,
    input    [7:0]    prbs1_tx_tkeepi    ,
    input             prbs1_tx_tlasti    ,
    input             prbs1_tx_tvalidi    ,
    output            prbs1_tx_treadyo    
);
	
	reg		[7:0]	count;
	wire	[1:0]	axis_rxd_tdest;
	
	assign vrfy_rx_tkeepo = 8'hff;
	assign prbs_rx_tkeepo = 8'hff;
	assign prbs1_rx_tkeepo = 8'hff;
	assign prof_rx_tkeepo = 8'hff;
	assign axis_txd_tkeep = 8'hff;
	
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			count <= 'd0;
		end
		else if(axis_rxd_tvalid & axis_rxd_tready)begin
			if(axis_rxd_tlast)begin
				count <= 'd0;
			end
			else begin
				 count <= count + 1;
			end
		end
	end
 
	wire [1:0] axis_rxd_tdest_comb;
	reg  [1:0] axis_rxd_tdest_reg;

	always@(posedge rsti or posedge clki)
    begin
        if(rsti)begin
            axis_rxd_tdest_reg <= 'd0;
		end else if(axis_rxd_tvalid && count == 0 & !axis_rxd_tlast)begin
			axis_rxd_tdest_reg <= axis_rxd_tdest_comb;
		end
	end

assign axis_rxd_tdest_comb = (axis_rxd_tdata[39:32]==8'h01)?2'd1:		//fid == 1			prbs
							 (axis_rxd_tdata[39:32]==8'h02)?2'd0:		//fid == 2			ecdsa
							 (axis_rxd_tdata[39:32]==8'h03)?2'd2:		//fid == 3			prbs1
							  2'd3;		                                //fid == others		proof
assign axis_rxd_tdest = (count==0) 	? axis_rxd_tdest_comb : axis_rxd_tdest_reg;
	
	axis_demux u_demux(
		.ACLK						(clki),
		.ARESETN					(~rsti),
		.S00_AXIS_ACLK				(clki),
		.S00_AXIS_ARESETN			(~rsti),
		.S00_AXIS_TVALID			(axis_rxd_tvalid),
		.S00_AXIS_TREADY			(axis_rxd_tready),
		.S00_AXIS_TDATA				(axis_rxd_tdata),
		.S00_AXIS_TLAST				(axis_rxd_tlast),
		.S00_AXIS_TDEST				(axis_rxd_tdest),
		.M00_AXIS_ACLK				(clki),
		.M01_AXIS_ACLK				(clk62mi),
		.M02_AXIS_ACLK				(clk62mi),
		.M03_AXIS_ACLK				(clki),
		.M00_AXIS_ARESETN			(~rsti),
		.M01_AXIS_ARESETN			(~rsti),
		.M02_AXIS_ARESETN			(~rsti),
		.M03_AXIS_ARESETN			(~rsti),
		.M00_AXIS_TVALID			(vrfy_rx_tvalido),
		.M01_AXIS_TVALID			(prbs_rx_tvalido),
		.M02_AXIS_TVALID			(prbs1_rx_tvalido),
		.M03_AXIS_TVALID			(prof_rx_tvalido),
		.M00_AXIS_TREADY			(vrfy_rx_treadyi),
		.M01_AXIS_TREADY			(prbs_rx_treadyi),
		.M02_AXIS_TREADY			(prbs1_rx_treadyi),
		.M03_AXIS_TREADY			(prof_rx_treadyi),
		.M00_AXIS_TDATA				(vrfy_rx_tdatao),
		.M01_AXIS_TDATA				(prbs_rx_tdatao),
		.M02_AXIS_TDATA				(prbs1_rx_tdatao),
		.M03_AXIS_TDATA				(prof_rx_tdatao),
		.M00_AXIS_TLAST				(vrfy_rx_tlasto),
		.M01_AXIS_TLAST				(prbs_rx_tlasto),
		.M02_AXIS_TLAST				(prbs1_rx_tlasto),
		.M03_AXIS_TLAST				(prof_rx_tlasto),
		.M00_AXIS_TDEST				(),
		.M01_AXIS_TDEST				(),
		.M02_AXIS_TDEST				(),
		.M03_AXIS_TDEST				(),
		.S00_DECODE_ERR				(),
//		.M00_SPARSE_TKEEP_REMOVED	(),
		.M01_SPARSE_TKEEP_REMOVED	(),
		.M02_SPARSE_TKEEP_REMOVED	(),
		.M03_SPARSE_TKEEP_REMOVED	(),
		.M00_FIFO_DATA_COUNT		(),
		.M01_FIFO_DATA_COUNT		(),
		.M02_FIFO_DATA_COUNT		(),
		.M03_FIFO_DATA_COUNT		()
	);

	axis_mux u_mux(
		.ACLK						(clki),
		.ARESETN					(~rsti),
		.S00_AXIS_ACLK				(clki),
		.S01_AXIS_ACLK				(clk62mi),
		.S02_AXIS_ACLK				(clk62mi),
		.S03_AXIS_ACLK				(clki),
		.S00_AXIS_ARESETN			(~rsti),
		.S01_AXIS_ARESETN			(~rsti),
		.S02_AXIS_ARESETN			(~rsti),
		.S03_AXIS_ARESETN			(~rsti),
		.S00_AXIS_TVALID			(vrfy_tx_tvalidi),
		.S01_AXIS_TVALID			(prbs_tx_tvalidi),
		.S02_AXIS_TVALID			(prbs1_tx_tvalidi),
		.S03_AXIS_TVALID			(prof_tx_tvalidi),
		.S00_AXIS_TREADY			(vrfy_tx_treadyo),
		.S01_AXIS_TREADY			(prbs_tx_treadyo),
		.S02_AXIS_TREADY			(prbs1_tx_treadyo),
		.S03_AXIS_TREADY			(prof_tx_treadyo),
		.S00_AXIS_TDATA				(vrfy_tx_tdatai),
		.S01_AXIS_TDATA				(prbs_tx_tdatai),
		.S02_AXIS_TDATA				(prbs1_tx_tdatai),
		.S03_AXIS_TDATA				(prof_tx_tdatai),
		.S00_AXIS_TLAST				(vrfy_tx_tlasti),
		.S01_AXIS_TLAST				(prbs_tx_tlasti),
		.S02_AXIS_TLAST				(prbs1_tx_tlasti),
		.S03_AXIS_TLAST				(prof_tx_tlasti),
		.M00_AXIS_ACLK				(clki),
		.M00_AXIS_ARESETN			(~rsti),
		.M00_AXIS_TVALID			(axis_txd_tvalid),
		.M00_AXIS_TREADY			(axis_txd_tready),
		.M00_AXIS_TDATA				(axis_txd_tdata),
		.M00_AXIS_TLAST				(axis_txd_tlast),
		.S00_ARB_REQ_SUPPRESS		(1'd0),
		.S01_ARB_REQ_SUPPRESS		(1'd0),
		.S02_ARB_REQ_SUPPRESS		(1'd0),
		.S03_ARB_REQ_SUPPRESS		(1'd0),
		.S00_FIFO_DATA_COUNT		(),
		.S01_FIFO_DATA_COUNT		(),
		.S02_FIFO_DATA_COUNT		(),
		.S03_FIFO_DATA_COUNT		()
	);

endmodule