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

module mac
   (
	input          	rsti  			,
	input			clki			,
	input           drpclki         ,
	output          gtrefclk        ,

	input           sgmii_refclkpi	,
	input           sgmii_refclkni	,
	input           sgmii_rxdpi		,
	input           sgmii_rxdni		,
	output          sgmii_txdpo		,
	output          sgmii_txdno		,
	
	output			pma_reset		,
	output			mmcm_locked		,
	output			resetdone		,
	output			cplllock		,
					
  	output	[63:0]	ge_rx_tdatao	,
  	output			ge_rx_tlasto	,
  	output			ge_rx_tvalido	,	
  	input			ge_rx_treadyi	,
  	input	[63:0]	ge_tx_tdatai	,
  	input			ge_tx_tvalidi	,
  	input			ge_tx_tlasti	,
  	output			ge_tx_treadyo	
);

(*mark_debug = "true"*)		wire	[7:0]	gmii_txd,gmii_rxd;
(*mark_debug = "true"*)		wire			gmii_tx_en,gmii_rx_dv;
(*mark_debug = "true"*)		wire			gmii_tx_er,gmii_rx_er;
(*mark_debug = "true"*)		wire	[15:0]  status_vector;
	
(*mark_debug = "true"*)			reg    [1:0]   	cnt;
	wire   [15:0]  an_adv_config_vector;
	wire   [4:0]   configuration_vector;
  
    
  gig_ethernet_pcs_pma_0_example_design dut
       (
        .independent_clock      (drpclki),
        .gtrefclk               (gtrefclk),
        .gtrefclk_p             (sgmii_refclkpi),
        .gtrefclk_n             (sgmii_refclkni),
        .rxuserclk2             (rxuserclk2),
        .txp                    (sgmii_txdpo),
        .txn                    (sgmii_txdno),
        .rxp                    (sgmii_rxdpi),
        .rxn                    (sgmii_rxdni),
        .sgmii_clk              (gmii_rx_clk),
        .gmii_txd               (gmii_txd),
        .gmii_tx_en             (gmii_tx_en),
        .gmii_tx_er             (gmii_tx_er),
        .gmii_rxd               (gmii_rxd),
        .gmii_rx_dv             (gmii_rx_dv),
        .gmii_rx_er             (gmii_rx_er),
        .configuration_vector   (configuration_vector),
        .an_interrupt           (an_interrupt),
        .an_adv_config_vector   (an_adv_config_vector),
        .an_restart_config      (an_restart_config),
        .speed_is_10_100        (speed_is_10_100),
        .speed_is_100           (speed_is_100),
        .status_vector          (status_vector),
        .cplllock               (cplllock),
        .pma_reset              (pma_reset),
        .resetdone              (resetdone),
        .reset                  (rsti),
        .signal_detect          (signal_detect)
        );

	assign gmii_txd   = gmii_rxd;
	assign gmii_tx_en = gmii_rx_dv;
	assign gmii_tx_er = gmii_rx_er;
	
	assign speed_is_10_100      = 1'b0;
	assign speed_is_100         = 1'b0;
	assign configuration_vector = 5'b00000;
	assign an_adv_config_vector = 16'b0000000000100001;
	assign an_restart_config    = 1'b0;
	assign signal_detect        = 1'b1;
/*	
	tmac u_mac(
		.gtx_clk					(gtrefclk),
		
		.glbl_rstn					(~rsti),
		.rx_axi_rstn				(~rsti),
		.tx_axi_rstn				(~rsti),
		
		.rx_statistics_vector		(),
		.rx_statistics_valid		(),
		
		.rx_mac_aclk				(rclk),
		.rx_reset					(rrst),
		.rx_axis_mac_tdata			(rx_tdata),
		.rx_axis_mac_tvalid			(rx_tvalid),
		.rx_axis_mac_tlast			(rx_tlast),
		.rx_axis_mac_tuser			(rx_tuser),
		
		.tx_ifg_delay				(8'd16),
		.tx_statistics_vector		(),
		.tx_statistics_valid		(),
		
		.tx_mac_aclk				(tclk),
		.tx_reset					(trst),
		.tx_axis_mac_tdata			(tx_tdata),
		.tx_axis_mac_tvalid			(tx_tvalid),
		.tx_axis_mac_tlast			(tx_tlast),
		.tx_axis_mac_tuser			(tx_tuser),
		.tx_axis_mac_tready			(tx_tready),
		
		.pause_req					(pause_req),
		.pause_val					(pause_val),
		
		.clk_enable					(1'd1),
		.speedis100					(),
		.speedis10100				(),
		
		.gmii_txd					(gmii_txd),
		.gmii_tx_en					(gmii_tx_en),
		.gmii_tx_er					(gmii_tx_er),
		.gmii_rxd					(gmii_rxd),
		.gmii_rx_dv					(gmii_rx_dv),
		.gmii_rx_er					(gmii_rx_er),
		
		.rx_configuration_vector	(80'd0),
		.tx_configuration_vector	(80'd0)
	);
	
	eth_rx eth_rx(
		.mac_rx_clk_i				(rclk),
		.arst_ni					(rrst),
		.remote_mac_en_o			(remote_mac_en),
		.remote_mac_o				(remote_mac),
		.mac_rx_tdata_i				(rx_tdata),
		.mac_rx_valid_i				(rx_tvalid),
		.mac_rx_tlast_i				(rx_tlast),
		.axi_ready_i				(ge_rx_treadyi),
		.axi_valid_o				(ge_rx_tvalido),
		.axi_tlast_o				(ge_rx_tlasto),
		.axi_tdata_o				(ge_rx_tdatao)
	);
	
	eth_tx eth_tx(
		.mac_tx_clk_i				(tclk),
		.arst_ni					(trst),
		.remote_mac_en_i			(remote_mac_en),
		.remote_mac_i				(remote_mac),
		
		.mac_tx_ready_i				(tx_tready),
		.mac_tx_valid_o				(tx_tvalid),
		.mac_tx_tlast_o				(tx_tlast),
		.mac_tx_tdata_o				(tx_tdata),
		
		.pause_req_o				(pause_req),
		.pause_val_o				(pause_val),
		
		.axi_clk_i					(tclk),
		.axi_ready_o				(ge_tx_treadyo),
		.axi_valid_i				(ge_tx_tvalidi),
		.axi_tlast_i				(ge_tx_tlasti),
		.axi_tdata_i				(ge_tx_tdatai)
	);
*/	
endmodule
