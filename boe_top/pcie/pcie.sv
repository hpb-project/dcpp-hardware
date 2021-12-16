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

module pcie
   (
//pcie interface    
	input          	pci_exp_rstni  	,
	input			pci_exp_rckpi	,
	input			pci_exp_rckni	,
	input	[7:0]	pci_exp_rxdni	,
	input	[7:0]	pci_exp_rxdpi	,
	output	[7:0]	pci_exp_txdno	,
	output	[7:0]	pci_exp_txdpo	,
	output			pcie_lnk		,
	output			user_rst		,
	output			user_clk		,
//axilite interface    
	output	[31:0]	m_axil_awaddr	,
	output	[2:0]	m_axil_awprot	,
	output			m_axil_awvalid	,
	input			m_axil_awready	,
	output	[31:0]	m_axil_wdata	,
	output	[3:0]	m_axil_wstrb	,
	output			m_axil_wvalid	,
	input			m_axil_wready	,
	input			m_axil_bvalid	,
	input	[1:0]	m_axil_bresp	,
	output			m_axil_bready	,
	output	[31:0]	m_axil_araddr	,
	output	[2:0]	m_axil_arprot	,
	output			m_axil_arvalid	,
	input			m_axil_arready	,
	input	[31:0]	m_axil_rdata	,
	input	[1:0]	m_axil_rresp	,
	input			m_axil_rvalid	,
	output			m_axil_rready	,
//axis interface    
	input	[63:0]	s_axis_c2h_tdata_0	,
	input	[7:0]	s_axis_c2h_tkeep_0	,
	input			s_axis_c2h_tlast_0	,
	input			s_axis_c2h_tvalid_0 ,
	output			s_axis_c2h_tready_0 ,
	output	[63:0]	m_axis_h2c_tdata_0	,
	output	[7:0]	m_axis_h2c_tkeep_0	,
	output			m_axis_h2c_tlast_0	,
	output			m_axis_h2c_tvalid_0 ,
	input			m_axis_h2c_tready_0 ,

	input	[63:0]	s_axis_c2h_tdata_1	,
	input	[7:0]	s_axis_c2h_tkeep_1	,
	input			s_axis_c2h_tlast_1	,
	input			s_axis_c2h_tvalid_1 ,
	output			s_axis_c2h_tready_1 ,
	output	[63:0]	m_axis_h2c_tdata_1	,
	output	[7:0]	m_axis_h2c_tkeep_1	,
	output			m_axis_h2c_tlast_1	,
	output			m_axis_h2c_tvalid_1 ,
	input			m_axis_h2c_tready_1 ,

	input	[63:0]	s_axis_c2h_tdata_2	,
	input	[7:0]	s_axis_c2h_tkeep_2	,
	input			s_axis_c2h_tlast_2	,
	input			s_axis_c2h_tvalid_2 ,
	output			s_axis_c2h_tready_2 ,
	output	[63:0]	m_axis_h2c_tdata_2	,
	output	[7:0]	m_axis_h2c_tkeep_2	,
	output			m_axis_h2c_tlast_2	,
	output			m_axis_h2c_tvalid_2 ,
	input			m_axis_h2c_tready_2 ,

	input	[63:0]	s_axis_c2h_tdata_3	,
	input	[7:0]	s_axis_c2h_tkeep_3	,
	input			s_axis_c2h_tlast_3	,
	input			s_axis_c2h_tvalid_3 ,
	output			s_axis_c2h_tready_3 ,
	output	[63:0]	m_axis_h2c_tdata_3	,
	output	[7:0]	m_axis_h2c_tkeep_3	,
	output			m_axis_h2c_tlast_3	,
	output			m_axis_h2c_tvalid_3 ,
	input			m_axis_h2c_tready_3 
);

wire pcie_ref_clk;
wire pcie_ref_clk_div2;
wire user_rst_n;

IBUFDS_GTE4 # (.REFCLK_HROW_CK_SEL(2'b00)) refclk_ibuf (.O(pcie_ref_clk), .ODIV2(pcie_ref_clk_div2), .I(pci_exp_rckpi), .CEB(1'b0), .IB(pci_exp_rckni));

assign user_rst = ~user_rst_n;

    ip_pcie ip_pcie(
//pcie interface    
		.sys_clk				(pcie_ref_clk_div2	),
		.sys_clk_gt				(pcie_ref_clk		),
		.sys_rst_n				(pci_exp_rstni		),
		.pci_exp_txp			(pci_exp_txdpo		),
		.pci_exp_txn			(pci_exp_txdno		),
		.pci_exp_rxp			(pci_exp_rxdpi		),
		.pci_exp_rxn			(pci_exp_rxdni		),
		.axi_aclk				(user_clk			),
		.axi_aresetn			(user_rst_n			),
		.user_lnk_up			(pcie_lnk			),
		.usr_irq_req			(1'b0				),
		.usr_irq_ack			(					),
//axilite interface    
		.m_axil_awaddr			(m_axil_awaddr		),
		.m_axil_awprot			(m_axil_awprot		),
		.m_axil_awvalid			(m_axil_awvalid		),
		.m_axil_awready			(m_axil_awready		),
		.m_axil_wdata			(m_axil_wdata		),
		.m_axil_wstrb			(m_axil_wstrb		),
		.m_axil_wvalid			(m_axil_wvalid		),
		.m_axil_wready			(m_axil_wready		),
		.m_axil_bvalid			(m_axil_bvalid		),
		.m_axil_bresp			(m_axil_bresp		),
		.m_axil_bready			(m_axil_bready		),
		.m_axil_araddr			(m_axil_araddr		),
		.m_axil_arprot			(m_axil_arprot		),
		.m_axil_arvalid			(m_axil_arvalid		),
		.m_axil_arready			(m_axil_arready		),
		.m_axil_rdata			(m_axil_rdata		),
		.m_axil_rresp			(m_axil_rresp		),
		.m_axil_rvalid			(m_axil_rvalid		),
		.m_axil_rready			(m_axil_rready		),
//axis interface    
		.s_axis_c2h_tdata_0		(s_axis_c2h_tdata_0	),
		.s_axis_c2h_tlast_0		(s_axis_c2h_tlast_0	),
		.s_axis_c2h_tvalid_0	(s_axis_c2h_tvalid_0),
		.s_axis_c2h_tready_0	(s_axis_c2h_tready_0),
		.s_axis_c2h_tkeep_0		(s_axis_c2h_tkeep_0	),
		.m_axis_h2c_tdata_0		(m_axis_h2c_tdata_0	),
		.m_axis_h2c_tlast_0		(m_axis_h2c_tlast_0	),
		.m_axis_h2c_tvalid_0	(m_axis_h2c_tvalid_0),
		.m_axis_h2c_tready_0	(m_axis_h2c_tready_0),
		.m_axis_h2c_tkeep_0		(m_axis_h2c_tkeep_0	),
		.s_axis_c2h_tdata_1		(s_axis_c2h_tdata_1	),
		.s_axis_c2h_tlast_1		(s_axis_c2h_tlast_1	),
		.s_axis_c2h_tvalid_1	(s_axis_c2h_tvalid_1),
		.s_axis_c2h_tready_1	(s_axis_c2h_tready_1),
		.s_axis_c2h_tkeep_1		(s_axis_c2h_tkeep_1	),
		.m_axis_h2c_tdata_1		(m_axis_h2c_tdata_1	),
		.m_axis_h2c_tlast_1		(m_axis_h2c_tlast_1	),
		.m_axis_h2c_tvalid_1	(m_axis_h2c_tvalid_1),
		.m_axis_h2c_tready_1	(m_axis_h2c_tready_1),
		.m_axis_h2c_tkeep_1		(m_axis_h2c_tkeep_1	),
		.s_axis_c2h_tdata_2		(s_axis_c2h_tdata_2	),
		.s_axis_c2h_tlast_2		(s_axis_c2h_tlast_2	),
		.s_axis_c2h_tvalid_2	(s_axis_c2h_tvalid_2),
		.s_axis_c2h_tready_2	(s_axis_c2h_tready_2),
		.s_axis_c2h_tkeep_2		(s_axis_c2h_tkeep_2	),
		.m_axis_h2c_tdata_2		(m_axis_h2c_tdata_2	),
		.m_axis_h2c_tlast_2		(m_axis_h2c_tlast_2	),
		.m_axis_h2c_tvalid_2	(m_axis_h2c_tvalid_2),
		.m_axis_h2c_tready_2	(m_axis_h2c_tready_2),
		.m_axis_h2c_tkeep_2		(m_axis_h2c_tkeep_2	),
		.s_axis_c2h_tdata_3		(s_axis_c2h_tdata_3	),
		.s_axis_c2h_tlast_3		(s_axis_c2h_tlast_3	),
		.s_axis_c2h_tvalid_3	(s_axis_c2h_tvalid_3),
		.s_axis_c2h_tready_3	(s_axis_c2h_tready_3),
		.s_axis_c2h_tkeep_3		(s_axis_c2h_tkeep_3	),
		.m_axis_h2c_tdata_3		(m_axis_h2c_tdata_3	),
		.m_axis_h2c_tlast_3		(m_axis_h2c_tlast_3	),
		.m_axis_h2c_tvalid_3	(m_axis_h2c_tvalid_3),
		.m_axis_h2c_tready_3	(m_axis_h2c_tready_3),
		.m_axis_h2c_tkeep_3 	(m_axis_h2c_tkeep_3 )
    );
    
endmodule
