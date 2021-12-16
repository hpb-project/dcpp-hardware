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

module fap
(
	input          	rsti  			,
	input			clki			,
	input           clk62mi         ,
	input			mclki			,
	input	[63:0]	axis_rxd_tdata	,
	input	[7:0]	axis_rxd_tkeep	,
	input			axis_rxd_tlast	,
	input			axis_rxd_tvalid	,
	output			axis_rxd_tready	,
	output	[63:0]	axis_txd_tdata	,
	output	[7:0]	axis_txd_tkeep	,
	output			axis_txd_tlast	,
	output			axis_txd_tvalid	,
	input			axis_txd_tready	
);
(*mark_debug = "true"*)	wire	[63:0]	prof_rx_tdata;
(*mark_debug = "true"*)	wire	[7:0]	prof_rx_tkeep;
(*mark_debug = "true"*)	wire			prof_rx_tlast;
(*mark_debug = "true"*)	wire			prof_rx_tvalid;
(*mark_debug = "true"*)	wire			prof_rx_tready;
(*mark_debug = "true"*)	wire	[63:0]	prof_tx_tdata;
(*mark_debug = "true"*)	wire	[7:0]	prof_tx_tkeep;
(*mark_debug = "true"*)	wire			prof_tx_tlast;
(*mark_debug = "true"*)	wire			prof_tx_tvalid;
(*mark_debug = "true"*)	wire			prof_tx_tready;
(*mark_debug = "true"*)	wire	[63:0]	vrfy_rx_tdata;
(*mark_debug = "true"*)	wire	[7:0]	vrfy_rx_tkeep;
(*mark_debug = "true"*)	wire			vrfy_rx_tlast;
(*mark_debug = "true"*)	wire			vrfy_rx_tvalid;
(*mark_debug = "true"*)	wire			vrfy_rx_tready;
(*mark_debug = "true"*)	wire	[63:0]	vrfy_tx_tdata;
(*mark_debug = "true"*)	wire	[7:0]	vrfy_tx_tkeep;
(*mark_debug = "true"*)	wire			vrfy_tx_tlast;
(*mark_debug = "true"*)	wire			vrfy_tx_tvalid;
(*mark_debug = "true"*)	wire			vrfy_tx_tready;
(*mark_debug = "true"*)	wire	[63:0]	prbs_rx_tdata;
(*mark_debug = "true"*)	wire	[7:0]	prbs_rx_tkeep;
(*mark_debug = "true"*)	wire			prbs_rx_tlast;
(*mark_debug = "true"*)	wire			prbs_rx_tvalid;
(*mark_debug = "true"*)	wire			prbs_rx_tready;
(*mark_debug = "true"*)	wire	[63:0]	prbs_tx_tdata;
(*mark_debug = "true"*)	wire	[7:0]	prbs_tx_tkeep;
(*mark_debug = "true"*)	wire			prbs_tx_tlast;
(*mark_debug = "true"*)	wire			prbs_tx_tvalid;
(*mark_debug = "true"*)	wire			prbs_tx_tready;
(*mark_debug = "true"*)	wire	[63:0]	prbs1_rx_tdata;
(*mark_debug = "true"*)	wire	[7:0]	prbs1_rx_tkeep;
(*mark_debug = "true"*)	wire			prbs1_rx_tlast;
(*mark_debug = "true"*)	wire			prbs1_rx_tvalid;
(*mark_debug = "true"*)	wire			prbs1_rx_tready;
(*mark_debug = "true"*)	wire	[63:0]	prbs1_tx_tdata;
(*mark_debug = "true"*)	wire	[7:0]	prbs1_tx_tkeep;
(*mark_debug = "true"*)	wire			prbs1_tx_tlast;
(*mark_debug = "true"*)	wire			prbs1_tx_tvalid;
(*mark_debug = "true"*)	wire			prbs1_tx_tready;
	
	tsu u_tsu(
		.rsti				(rsti			),
		.clk62mi            (clk62mi        ),
		.clki				(clki			),
		.axis_rxd_tdata		(axis_rxd_tdata	),
		.axis_rxd_tkeep		(axis_rxd_tkeep	),
		.axis_rxd_tlast		(axis_rxd_tlast	),
		.axis_rxd_tready	(axis_rxd_tready),
		.axis_rxd_tvalid	(axis_rxd_tvalid),
		.axis_txd_tdata		(axis_txd_tdata	),
		.axis_txd_tkeep		(axis_txd_tkeep	),
		.axis_txd_tlast		(axis_txd_tlast	),
		.axis_txd_tready	(axis_txd_tready),
		.axis_txd_tvalid	(axis_txd_tvalid),
  	
		.prbs_rx_tdatao	    (prbs_rx_tdata	),
		.prbs_rx_tkeepo     (prbs_rx_tkeep  ),
		.prbs_rx_tlasto     (prbs_rx_tlast  ),
		.prbs_rx_tvalido    (prbs_rx_tvalid ),
		.prbs_rx_treadyi    (prbs_rx_tready ),
		.prbs_tx_tdatai     (prbs_tx_tdata  ),
		.prbs_tx_tkeepi     (prbs_tx_tkeep  ),
		.prbs_tx_tlasti     (prbs_tx_tlast  ),
		.prbs_tx_tvalidi    (prbs_tx_tvalid ),
		.prbs_tx_treadyo    (prbs_tx_tready ),
		 
		.prbs1_rx_tdatao	(prbs1_rx_tdata	),
		.prbs1_rx_tkeepo    (prbs1_rx_tkeep ),
		.prbs1_rx_tlasto    (prbs1_rx_tlast ),
		.prbs1_rx_tvalido   (prbs1_rx_tvalid),
		.prbs1_rx_treadyi   (prbs1_rx_tready),
		.prbs1_tx_tdatai    (prbs1_tx_tdata ),
		.prbs1_tx_tkeepi    (prbs1_tx_tkeep ),
		.prbs1_tx_tlasti    (prbs1_tx_tlast ),
		.prbs1_tx_tvalidi   (prbs1_tx_tvalid),
		.prbs1_tx_treadyo   (prbs1_tx_tready),
		 
		.vrfy_rx_tdatao		(vrfy_rx_tdata	),
		.vrfy_rx_tkeepo		(vrfy_rx_tkeep	),
		.vrfy_rx_tlasto		(vrfy_rx_tlast	),
		.vrfy_rx_tvalido	(vrfy_rx_tvalid	),
		.vrfy_rx_treadyi	(vrfy_rx_tready	),
		.vrfy_tx_tdatai		(vrfy_tx_tdata	),
		.vrfy_tx_tkeepi		(vrfy_tx_tkeep	),
		.vrfy_tx_tlasti		(vrfy_tx_tlast	),
		.vrfy_tx_tvalidi	(vrfy_tx_tvalid	),
		.vrfy_tx_treadyo	(vrfy_tx_tready	),
		 
		.prof_rx_tdatao		(prof_rx_tdata	),
		.prof_rx_tkeepo		(prof_rx_tkeep	),
		.prof_rx_tlasto		(prof_rx_tlast	),
		.prof_rx_tvalido	(prof_rx_tvalid	),
		.prof_rx_treadyi	(prof_rx_tready	),
		.prof_tx_tdatai		(prof_tx_tdata	),
		.prof_tx_tkeepi		(prof_tx_tkeep	),
		.prof_tx_tlasti		(prof_tx_tlast	),
		.prof_tx_tvalidi	(prof_tx_tvalid	),
		.prof_tx_treadyo	(prof_tx_tready	)
	);

		prof u_prof(
			.rsti				(rsti           ),
			.clki				(clki           ),
			.prof_rx_tdatai		(prof_rx_tdata  ),
			.prof_rx_tkeepi		(prof_rx_tkeep  ),
			.prof_rx_tlasti		(prof_rx_tlast  ),
			.prof_rx_tvalidi	(prof_rx_tvalid ),
			.prof_rx_treadyo	(prof_rx_tready ),
			.prof_tx_tdatao		(prof_tx_tdata  ),
			.prof_tx_tkeepo		(prof_tx_tkeep  ),
			.prof_tx_tlasto		(prof_tx_tlast  ),
			.prof_tx_tvalido	(prof_tx_tvalid ),
			.prof_tx_treadyi	(prof_tx_tready )
		);
/*
		assign vrfy_rx_tready = 1'b1;
		assign vrfy_tx_tlast  = 1'b0;
		assign vrfy_tx_tvalid = 1'b0;
		assign vrfy_tx_tkeep  = 4'hf;
		assign vrfy_tx_tdata  = 64'd0;
		
		assign prbs_rx_tready = 1'b1;
		assign prbs_tx_tlast  = 1'b0;
		assign prbs_tx_tvalid = 1'b0;
		assign prbs_tx_tkeep  = 4'hf;
		assign prbs_tx_tdata  = 64'd0;
		
		assign prbs1_rx_tready = 1'b1;
		assign prbs1_tx_tlast  = 1'b0;
		assign prbs1_tx_tvalid = 1'b0;
		assign prbs1_tx_tkeep  = 4'hf;
		assign prbs1_tx_tdata  = 64'd0;
*/		

		vrfy u_vrfy(
			.rsti				(rsti           ),
			.clki				(clki           ),
			.mclki				(mclki          ),
			.vrfy_rx_tdatai		(vrfy_rx_tdata  ),
			.vrfy_rx_tkeepi		(vrfy_rx_tkeep  ),
			.vrfy_rx_tlasti		(vrfy_rx_tlast  ),
			.vrfy_rx_tvalidi	(vrfy_rx_tvalid ),
			.vrfy_rx_treadyo	(vrfy_rx_tready ),
			.vrfy_tx_tdatao		(vrfy_tx_tdata  ),
			.vrfy_tx_tkeepo		(vrfy_tx_tkeep  ),
			.vrfy_tx_tlasto		(vrfy_tx_tlast  ),
			.vrfy_tx_tvalido	(vrfy_tx_tvalid ),
			.vrfy_tx_treadyi	(vrfy_tx_tready )
		);
	
    prbs u_prbs(
        .rsti               (rsti           ),
        .clki               (clk62mi        ),
        .prbs_rx_tdatai     (prbs_rx_tdata  ),
        .prbs_rx_tkeepi     (prbs_rx_tkeep  ),
        .prbs_rx_tlasti     (prbs_rx_tlast  ),
        .prbs_rx_tvalidi    (prbs_rx_tvalid ),
        .prbs_rx_treadyo    (prbs_rx_tready ),
        .prbs_tx_tdatao     (prbs_tx_tdata  ),
        .prbs_tx_tkeepo     (prbs_tx_tkeep  ),
        .prbs_tx_tlasto     (prbs_tx_tlast  ),
        .prbs_tx_tvalido    (prbs_tx_tvalid ),
        .prbs_tx_treadyi    (prbs_tx_tready )
    );
	
    prbs1 u_prbs1(
        .rsti               (rsti           ),
        .clki               (clk62mi        ),
        .prbs_rx_tdatai     (prbs1_rx_tdata ),
        .prbs_rx_tkeepi     (prbs1_rx_tkeep ),
        .prbs_rx_tlasti     (prbs1_rx_tlast ),
        .prbs_rx_tvalidi    (prbs1_rx_tvalid),
        .prbs_rx_treadyo    (prbs1_rx_tready),
        .prbs_tx_tdatao     (prbs1_tx_tdata ),
        .prbs_tx_tkeepo     (prbs1_tx_tkeep ),
        .prbs_tx_tlasto     (prbs1_tx_tlast ),
        .prbs_tx_tvalido    (prbs1_tx_tvalid),
        .prbs_tx_treadyi    (prbs1_tx_tready)
    );

endmodule
