//Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2017.4.1 (win64) Build 2117270 Tue Jan 30 15:32:00 MST 2018
//Date        : Mon Mar 26 19:59:02 2018
//Host        : mayt-PC running 64-bit Service Pack 1  (build 7601)
//Command     : 
//Design      : boe_eth
//Purpose     : top module
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module boe_eth
(
	input           sclkpi,
	input           sclkni,
	input           sgmii_rxpi	,
	input           sgmii_rxni	,
	output          sgmii_txpo	,
	output          sgmii_txno	,
					
    output  [3:0]   ledo
);
wire [31:0] gpo;
wire        clk62m;
wire        rst;
wire        clk;
wire        clk200m;
wire [3:0] axis_tready_llc2user;
wire [3:0] axis_tvalid_llc2user;
wire [3:0] axis_tlast_llc2user;
wire [7:0] axis_tkeep_llc2user[3:0];
wire [63:0]axis_tdata_llc2user[3:0];

wire [3:0] axis_tready_user2llc;
wire [3:0] axis_tvalid_user2llc;
wire [3:0] axis_tlast_user2llc;
wire [7:0] axis_tkeep_user2llc[3:0];
wire [63:0]axis_tdata_user2llc[3:0];

wire [11:0]ramif_addr;
wire       ramif_clk;
wire [31:0]ramif_din;
wire [31:0]ramif_dout;
wire       ramif_en;
wire       ramif_rst;
wire [3:0] ramif_we;

wire [31:0] eth_alarm;

	eth u_eth
	(
		.sclk_pi				(sclkpi),
		.sclk_ni				(sclkni),
		.rsto					(rst),
		.clko	     			(clk),
		.clk62mo                (clk62m),
		.clk200mo				(clk200m),
		
		.sgmii_rxp_i			(sgmii_rxpi),
		.sgmii_rxn_i			(sgmii_rxni),
		.sgmii_txp_o			(sgmii_txpo),
		.sgmii_txn_o			(sgmii_txno),

		.axis_tready_llc2user	(axis_tready_llc2user	),
		.axis_tvalid_llc2user	(axis_tvalid_llc2user	),
		.axis_tlast_llc2user	(axis_tlast_llc2user	),
		.axis_tkeep_llc2user	(axis_tkeep_llc2user	),
		.axis_tdata_llc2user	(axis_tdata_llc2user	),

		.axis_tready_user2llc	(axis_tready_user2llc	),
		.axis_tvalid_user2llc	(axis_tvalid_user2llc	),
		.axis_tlast_user2llc	(axis_tlast_user2llc	),
		.axis_tkeep_user2llc	(axis_tkeep_user2llc	),
		.axis_tdata_user2llc	(axis_tdata_user2llc	),
		.alarmo                 (eth_alarm              )
	);
	
	assign axis_tready_llc2user[3:2] = {1'b0,1'b0};
	assign axis_tvalid_user2llc[3:2] = {1'b0,1'b0};
	assign axis_tlast_user2llc[3:2]  = {1'b0,1'b0};
	assign axis_tkeep_user2llc[3:2]  = {8'b0,8'b0};
	assign axis_tdata_user2llc[3:2]  = {64'b0,64'b0};
	
	arm_core u_arm
   	(
    	.AXI_STR_RXD_tdata 		( axis_tdata_llc2user[0]  	),
    	.AXI_STR_RXD_tkeep 		( axis_tkeep_llc2user[0]  	),
    	.AXI_STR_RXD_tlast 		( axis_tlast_llc2user[0]  	),
    	.AXI_STR_RXD_tready		( axis_tready_llc2user[0] 	),
    	.AXI_STR_RXD_tvalid		( axis_tvalid_llc2user[0] 	),
    	.AXI_STR_TXD_tdata 		( axis_tdata_user2llc[0]  	),
    	.AXI_STR_TXD_tkeep 		( axis_tkeep_user2llc[0]  	),
    	.AXI_STR_TXD_tlast 		( axis_tlast_user2llc[0]  	),
    	.AXI_STR_TXD_tready		( axis_tready_user2llc[0] 	),
    	.AXI_STR_TXD_tvalid		( axis_tvalid_user2llc[0] 	),
    	.GPO_tri_o      		( gpo						),
        .RAMIF_addr             ( ramif_addr                ),
        .RAMIF_clk              ( ramif_clk                 ),
        .RAMIF_din              ( ramif_din                 ),
        .RAMIF_dout             ( ramif_dout                ),
        .RAMIF_en               ( ramif_en                  ),
        .RAMIF_rst              ( ramif_rst                 ),
        .RAMIF_we               ( ramif_we                  ),
    	.aclk              		( clk	  			        ),
    	.aresetn           		( ~rst			  	        )
    );

assign ledo = gpo[3:0];

    fap u_fap(
		.rsti  					(rst						),
		.clki					(clk						),
		.clk62mi                (clk62m                     ),
		.mclki					(clk                        ), //clk200m					),
  		.axis_rxd_tdata			(axis_tdata_llc2user[1] 	), 
  		.axis_rxd_tkeep			(axis_tkeep_llc2user[1] 	), 
  		.axis_rxd_tlast			(axis_tlast_llc2user[1] 	), 
  		.axis_rxd_tready		(axis_tready_llc2user[1]	),
  		.axis_rxd_tvalid		(axis_tvalid_llc2user[1]	),
  		.axis_txd_tdata			(axis_tdata_user2llc[1] 	), 
  		.axis_txd_tkeep			(axis_tkeep_user2llc[1] 	), 
  		.axis_txd_tlast			(axis_tlast_user2llc[1] 	), 
  		.axis_txd_tready		(axis_tready_user2llc[1]	),
  		.axis_txd_tvalid		(axis_tvalid_user2llc[1]	)
    );

    register u_register(
        .addr      ( ramif_addr     ),
        .clk       ( ramif_clk      ),
        .din       ( ramif_din      ),
        .dout      ( ramif_dout     ),
        .en        ( ramif_en       ),
        .rst       ( ramif_rst      ),
        .we        ( ramif_we       ),
        .alarm_in1 ( eth_alarm      )
       );
endmodule
