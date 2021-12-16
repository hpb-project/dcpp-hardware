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

module boe_top
   (
	input          	pci_exp_rstni  	,
	input			pci_exp_rckpi	,
	input			pci_exp_rckni	,
	input	[7:0]	pci_exp_rxdni	,
	input	[7:0]	pci_exp_rxdpi	,
	output	[7:0]	pci_exp_txdno	,
	output	[7:0]	pci_exp_txdpo	,
	
//	input           sgmii_refclkpi	,
//	input           sgmii_refclkni	,
//	input           sgmii_rxdpi		,
//	input           sgmii_rxdni		,
//	output          sgmii_txdpo		,
//	output          sgmii_txdno		,
					
    output  [7:0]   ledo
);
	wire			pcie_lnk		;
	wire			user_rst		;
	wire			user_clk		;
	wire	[31:0]	axil_awaddr		;
	wire	[2:0]	axil_awprot		;
	wire			axil_awvalid	;
	wire			axil_awready	;
	wire	[31:0]	axil_wdata		;
	wire	[3:0]	axil_wstrb		;
	wire			axil_wvalid		;
	wire			axil_wready		;
	wire			axil_bvalid		;
	wire	[1:0]	axil_bresp		;
	wire			axil_bready		;
	wire	[31:0]	axil_araddr		;
	wire	[2:0]	axil_arprot		;
	wire			axil_arvalid	;
	wire			axil_arready	;
	wire	[31:0]	axil_rdata		;
	wire	[1:0]	axil_rresp		;
	wire			axil_rvalid		;
	wire			axil_rready		;
	wire	[63:0]	isp_c2h_tdata	;
	wire	[7:0]	isp_c2h_tkeep	;
	wire			isp_c2h_tlast	;
	wire			isp_c2h_tvalid	;
	wire			isp_c2h_tready	;
	wire	[63:0]	isp_h2c_tdata	;
	wire	[7:0]	isp_h2c_tkeep	;
	wire			isp_h2c_tlast	;
	wire			isp_h2c_tvalid	;
	wire			isp_h2c_tready	;
	wire	[63:0]	fap_c2h_tdata	;
	wire	[7:0]	fap_c2h_tkeep	;
	wire			fap_c2h_tlast	;
	wire			fap_c2h_tvalid	;
	wire			fap_c2h_tready	;
	wire	[63:0]	fap_h2c_tdata	;
	wire	[7:0]	fap_h2c_tkeep	;
	wire			fap_h2c_tlast	;
	wire			fap_h2c_tvalid	;
	wire			fap_h2c_tready	;
	wire	[63:0]	scp_c2h_tdata	;
	wire	[7:0]	scp_c2h_tkeep	;
	wire			scp_c2h_tlast	;
	wire			scp_c2h_tvalid	;
	wire			scp_c2h_tready	;
	wire	[63:0]	scp_h2c_tdata	;
	wire	[7:0]	scp_h2c_tkeep	;
	wire			scp_h2c_tlast	;
	wire			scp_h2c_tvalid	;
	wire			scp_h2c_tready	;
	wire	[63:0]	toe_c2h_tdata	;
	wire	[7:0]	toe_c2h_tkeep	;
	wire			toe_c2h_tlast	;
	wire			toe_c2h_tvalid	;
	wire			toe_c2h_tready	;
	wire	[63:0]	toe_h2c_tdata	;
	wire	[7:0]	toe_h2c_tkeep	;
	wire			toe_h2c_tlast	;
	wire			toe_h2c_tvalid	;
	wire			toe_h2c_tready	;

    pcie pcie(
        .pci_exp_rstni      	(pci_exp_rstni  ),
        .pci_exp_rckpi      	(pci_exp_rckpi  ),
        .pci_exp_rckni      	(pci_exp_rckni  ),
        .pci_exp_rxdpi      	(pci_exp_rxdpi  ),
        .pci_exp_rxdni      	(pci_exp_rxdni  ),
        .pci_exp_txdpo      	(pci_exp_txdpo  ),
        .pci_exp_txdno      	(pci_exp_txdno  ),
		.pcie_lnk				(pcie_lnk		),
		.user_rst				(user_rst		),
		.user_clk				(user_clk		),
		
		.m_axil_awaddr			(axil_awaddr	),
		.m_axil_awprot			(axil_awprot	),
		.m_axil_awvalid			(axil_awvalid	),
		.m_axil_awready			(axil_awready	),
		.m_axil_wdata			(axil_wdata		),
		.m_axil_wstrb			(axil_wstrb		),
		.m_axil_wvalid			(axil_wvalid	),
		.m_axil_wready			(axil_wready	),
		.m_axil_bvalid			(axil_bvalid	),
		.m_axil_bresp			(axil_bresp		),
		.m_axil_bready			(axil_bready	),
		.m_axil_araddr			(axil_araddr	),
		.m_axil_arprot			(axil_arprot	),
		.m_axil_arvalid			(axil_arvalid	),
		.m_axil_arready			(axil_arready	),
		.m_axil_rdata			(axil_rdata		),
		.m_axil_rresp			(axil_rresp		),
		.m_axil_rvalid			(axil_rvalid	),
		.m_axil_rready			(axil_rready	),
		
		.s_axis_c2h_tdata_0		(isp_c2h_tdata	),
		.s_axis_c2h_tkeep_0		(isp_c2h_tkeep	),
		.s_axis_c2h_tlast_0		(isp_c2h_tlast	),
		.s_axis_c2h_tvalid_0 	(isp_c2h_tvalid	),
		.s_axis_c2h_tready_0 	(isp_c2h_tready	),
		.m_axis_h2c_tdata_0		(isp_h2c_tdata	),
		.m_axis_h2c_tkeep_0		(isp_h2c_tkeep	),
		.m_axis_h2c_tlast_0		(isp_h2c_tlast	),
		.m_axis_h2c_tvalid_0 	(isp_h2c_tvalid	),
		.m_axis_h2c_tready_0 	(isp_h2c_tready	),
		
		.s_axis_c2h_tdata_1		(fap_c2h_tdata	),
		.s_axis_c2h_tkeep_1		(fap_c2h_tkeep	),
		.s_axis_c2h_tlast_1		(fap_c2h_tlast	),
		.s_axis_c2h_tvalid_1 	(fap_c2h_tvalid	),
		.s_axis_c2h_tready_1 	(fap_c2h_tready	),
		.m_axis_h2c_tdata_1		(fap_h2c_tdata	),
		.m_axis_h2c_tkeep_1		(fap_h2c_tkeep	),
		.m_axis_h2c_tlast_1		(fap_h2c_tlast	),
		.m_axis_h2c_tvalid_1 	(fap_h2c_tvalid	),
		.m_axis_h2c_tready_1 	(fap_h2c_tready	),
		
		.s_axis_c2h_tdata_2		(scp_c2h_tdata	),
		.s_axis_c2h_tkeep_2		(scp_c2h_tkeep	),
		.s_axis_c2h_tlast_2		(scp_c2h_tlast	),
		.s_axis_c2h_tvalid_2 	(scp_c2h_tvalid	),
		.s_axis_c2h_tready_2 	(scp_c2h_tready	),
		.m_axis_h2c_tdata_2		(scp_h2c_tdata	),
		.m_axis_h2c_tkeep_2		(scp_h2c_tkeep	),
		.m_axis_h2c_tlast_2		(scp_h2c_tlast	),
		.m_axis_h2c_tvalid_2 	(scp_h2c_tvalid	),
		.m_axis_h2c_tready_2 	(scp_h2c_tready	),
		
		.s_axis_c2h_tdata_3		(toe_c2h_tdata	),
		.s_axis_c2h_tkeep_3		(toe_c2h_tkeep	),
		.s_axis_c2h_tlast_3		(toe_c2h_tlast	),
		.s_axis_c2h_tvalid_3 	(toe_c2h_tvalid	),
		.s_axis_c2h_tready_3 	(toe_c2h_tready	),
		.m_axis_h2c_tdata_3		(toe_h2c_tdata	),
		.m_axis_h2c_tkeep_3		(toe_h2c_tkeep	),
		.m_axis_h2c_tlast_3		(toe_h2c_tlast	),
		.m_axis_h2c_tvalid_3 	(toe_h2c_tvalid	),
		.m_axis_h2c_tready_3 	(toe_h2c_tready	)
    );
    
    arm arm(
		.rsti  					(user_rst		),
		.clki					(user_clk		),
  		.axis_rxd_tdata			(isp_h2c_tdata	), 
  		.axis_rxd_tkeep			(isp_h2c_tkeep	), 
  		.axis_rxd_tlast			(isp_h2c_tlast	), 
  		.axis_rxd_tready		(isp_h2c_tready	),
  		.axis_rxd_tvalid		(isp_h2c_tvalid	),
  		.axis_txd_tdata			(isp_c2h_tdata	), 
  		.axis_txd_tkeep			(isp_c2h_tkeep	), 
  		.axis_txd_tlast			(isp_c2h_tlast	), 
  		.axis_txd_tready		(isp_c2h_tready	),
  		.axis_txd_tvalid		(isp_c2h_tvalid	)
    );
    
    glb_reg glb_reg(
		.rsti  					(user_rst		),
		.clki					(user_clk		),
		.s_axil_awaddr			(axil_awaddr	),
		.s_axil_awprot			(axil_awprot	),
		.s_axil_awvalid			(axil_awvalid	),
		.s_axil_awready			(axil_awready	),
		.s_axil_wdata			(axil_wdata		),
		.s_axil_wstrb			(axil_wstrb		),
		.s_axil_wvalid			(axil_wvalid	),
		.s_axil_wready			(axil_wready	),
		.s_axil_bvalid			(axil_bvalid	),
		.s_axil_bresp			(axil_bresp		),
		.s_axil_bready			(axil_bready	),
		.s_axil_araddr			(axil_araddr	),
		.s_axil_arprot			(axil_arprot	),
		.s_axil_arvalid			(axil_arvalid	),
		.s_axil_arready			(axil_arready	),
		.s_axil_rdata			(axil_rdata		),
		.s_axil_rresp			(axil_rresp		),
		.s_axil_rvalid			(axil_rvalid	),
		.s_axil_rready			(axil_rready	),
		
		.pcie_lnki				(pcie_lnk		),
		.ledo					(ledo			)
    );
/*
    fap fap(
		.rsti  					(user_rst		),
		.clki					(user_clk		),
  		.axis_rxd_tdata			(fap_h2c_tdata	), 
  		.axis_rxd_tkeep			(fap_h2c_tkeep	), 
  		.axis_rxd_tlast			(fap_h2c_tlast	), 
  		.axis_rxd_tready		(fap_h2c_tready	),
  		.axis_rxd_tvalid		(fap_h2c_tvalid	),
  		.axis_txd_tdata			(fap_c2h_tdata	), 
  		.axis_txd_tkeep			(fap_c2h_tkeep	), 
  		.axis_txd_tlast			(fap_c2h_tlast	), 
  		.axis_txd_tready		(fap_c2h_tready	),
  		.axis_txd_tvalid		(fap_c2h_tvalid	)
    );
    
    SCP Module
    scp scp(
		.rsti  					(user_rst		),
		.clki					(user_clk		),
  		.axis_rxd_tdata			(scp_h2c_tdata	), 
  		.axis_rxd_tkeep			(scp_h2c_tkeep	), 
  		.axis_rxd_tlast			(scp_h2c_tlast	), 
  		.axis_rxd_tready		(scp_h2c_tready	),
  		.axis_rxd_tvalid		(scp_h2c_tvalid	),
  		.axis_txd_tdata			(scp_c2h_tdata	), 
  		.axis_txd_tkeep			(scp_c2h_tkeep	), 
  		.axis_txd_tlast			(scp_c2h_tlast	), 
  		.axis_txd_tready		(scp_c2h_tready	),
  		.axis_txd_tvalid		(scp_c2h_tvalid	)
    );
*/

/*    TOE Module
    toe toe(
		.rsti  					(user_rst		),
		.clki					(user_clk		),
  		.axis_rxd_tdata			(toe_h2c_tdata	), 
  		.axis_rxd_tkeep			(toe_h2c_tkeep	), 
  		.axis_rxd_tlast			(toe_h2c_tlast	), 
  		.axis_rxd_tready		(toe_h2c_tready	),
  		.axis_rxd_tvalid		(toe_h2c_tvalid	),
  		.axis_txd_tdata			(toe_c2h_tdata	), 
  		.axis_txd_tkeep			(toe_c2h_tkeep	), 
  		.axis_txd_tlast			(toe_c2h_tlast	), 
  		.axis_txd_tready		(toe_c2h_tready	),
  		.axis_txd_tvalid		(toe_c2h_tvalid	),
		
		.ge_rx_tdatai			(ge_rx_tdata	),
		.ge_rx_tlasti			(ge_rx_tlast	),
		.ge_rx_tvalidi			(ge_rx_tvalid	),
		.ge_rx_treadyo			(ge_rx_tready	),
		.ge_tx_tdatao			(ge_tx_tdata	),
		.ge_tx_tlasto			(ge_tx_tlast	),
		.ge_tx_tvalido			(ge_tx_tvalid	),
		.ge_tx_treadyi			(ge_tx_tready	),
    );
*/

/*	ETH debug Module
	eth_dbg u_dbg(
    	.rsti					(user_rst		),
    	.clki					(user_clk		),
	
		.ge_rx_tdatai			(ge_rx_tdata	),
		.ge_rx_tlasti			(ge_rx_tlast	),
		.ge_rx_tvalidi			(ge_rx_tvalid	),
		.ge_rx_treadyo			(ge_rx_tready	),
		.ge_tx_tdatao			(ge_tx_tdata	),
		.ge_tx_tlasto			(ge_tx_tlast	),
		.ge_tx_tvalido			(ge_tx_tvalid	),
		.ge_tx_treadyi			(ge_tx_tready	),
		
  		.axis_rxd_tdata			(fap_h2c_tdata	), 
  		.axis_rxd_tkeep			(fap_h2c_tkeep	), 
  		.axis_rxd_tlast			(fap_h2c_tlast	), 
  		.axis_rxd_tready		(fap_h2c_tready	),
  		.axis_rxd_tvalid		(fap_h2c_tvalid	),
  		.axis_txd_tdata			(fap_c2h_tdata	), 
  		.axis_txd_tkeep			(fap_c2h_tkeep	), 
  		.axis_txd_tlast			(fap_c2h_tlast	), 
  		.axis_txd_tready		(fap_c2h_tready	),
  		.axis_txd_tvalid		(fap_c2h_tvalid	)
	);
*/

/*	MAC Module
    mac mac(
    	.rsti					(user_rst		),
    	.clki					(user_clk		),
    
		.sgmii_refclkpi			(sgmii_refclkpi	),
		.sgmii_refclkni			(sgmii_refclkni	),
		.sgmii_rxdpi			(sgmii_rxdpi	),
		.sgmii_rxdni			(sgmii_rxdni	),
		.sgmii_txdpo			(sgmii_txdpo	),
		.sgmii_txdno			(sgmii_txdno	),
		
		.ge_rx_tdatao			(ge_rx_tdata	),
		.ge_rx_tlasto			(ge_rx_tlast	),
		.ge_rx_tvalido			(ge_rx_tvalid	),
		.ge_rx_treadyi			(ge_rx_tready	),
		.ge_tx_tdatai			(ge_tx_tdata	),
		.ge_tx_tlasti			(ge_tx_tlast	),
		.ge_tx_tvalidi			(ge_tx_tvalid	),
		.ge_tx_treadyo			(ge_tx_tready	)
     );
*/    
endmodule
