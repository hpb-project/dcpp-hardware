module eth(
input				sclk_pi,
input   			sclk_ni,
output				rsto,
output				clko,
output              clk62mo,
output				clk200mo,

input   			sgmii_rxp_i,
input   			sgmii_rxn_i,
output  			sgmii_txp_o,
output  			sgmii_txn_o,

input 	[3:0] 	axis_tready_llc2user,
output 	[3:0] 	axis_tvalid_llc2user,
output 	[3:0] 	axis_tlast_llc2user,
output 	[7:0] 	axis_tkeep_llc2user[3:0],
output 	[63:0]	axis_tdata_llc2user[3:0],

output 	[3:0] 	axis_tready_user2llc,
input 	[3:0] 	axis_tvalid_user2llc,
input 	[3:0] 	axis_tlast_user2llc,
input 	[7:0] 	axis_tkeep_user2llc[3:0],
input 	[63:0]	axis_tdata_user2llc[3:0],

output  [31:0] alarmo
);
wire [31:0] gpo;
wire arst_ni;
wire odiv2;
wire ck_div2;
wire mck125m;
wire mck125m_bufg;
wire gtrefclk;
wire txoutclk;
wire rxoutclk;
wire rxoutclk_bufgt;
wire clk125m;
wire sck125m;
wire clk62m;
wire clk200m;
wire clk_ind;
wire nrst_logic;
wire mmcm_locked;
wire mmcm_reset;
wire resetdone;
wire cplllock;
wire [15:0] status_vector;  
wire gtpowergood;
wire an_interrupt;
wire rx_mac_aclk;
wire [7:0]gmii_rxd;
wire gmii_rx_clk;
wire gmii_rx_dv;
wire gmii_rx_er;
wire [7:0]gmii_txd;
wire gmii_tx_en;
wire gmii_tx_er;
wire mac_rx_clk;
(*mark_debug = "true"*)wire [7:0]mac_rx_tdata;
(*mark_debug = "true"*)wire mac_rx_valid;
(*mark_debug = "true"*)wire mac_rx_tlast;
wire pause_req;
wire [15:0]pause_val;
wire mac_tx_clk;
(*mark_debug = "true"*)wire [7:0]mac_tx_tdata;
(*mark_debug = "true"*)wire mac_tx_valid;
(*mark_debug = "true"*)wire mac_tx_tlast;
wire mac_tx_ready;
wire [79:0]rx_cfg_vector;
wire [79:0]tx_cfg_vector;
wire mac_rx_reset;
wire mac_tx_reset;
wire remote_mac_en;
wire [47:0]remote_mac;

//---------llc to user-------------

wire pcs_reset;
wire pma_reset;
wire phy_rst_n;
wire mac_rst_n;
wire ecdsa_busy;
wire p1ms;

reg  [15:0]rst_tmr;
reg  [6:0]div_125;
reg  [9:0]div_1000;
reg  [9:0]led_tmr;
reg  [7:0]pma_reset_d;
wire [4:0] CFG;

`ifdef SIM 
 assign   CFG = 5'b00000;
`else
 assign   CFG = 5'b10000;
`endif
//****************************eth if**************************//
//assign arst_ni=~reset_i;
assign nrst_logic=mmcm_locked;
assign tx_cfg_vector=80'h55443322110000002022; 
assign rx_cfg_vector=80'h55443322110000002022;
assign mac_rst_n=(rst_tmr>=16'h8000)?1:0;
assign pcs_reset=(rst_tmr<=16'h1000)?1:0;
assign phy_rst_n=rst_tmr[15];
assign p1ms=(div_1000>=999)&(div_125>=124);

assign rsto = ~mac_rst_n;
assign clk62mo = clk62m;
assign clko = clk125m;
assign clk200mo = clk200m;

assign alarmo = {status_vector,11'b0,gtpowergood,mmcm_reset,resetdone,cplllock,mmcm_locked};

IBUFDS_GTE4 #(.REFCLK_HROW_CK_SEL(2'b00))
IBUFDS_GTE4_1(
    .CEB(1'd0),
	.I(sclk_pi),
	.IB(sclk_ni),
	.O(gtrefclk),
	.ODIV2(odiv2)
);

BUFG_GT BUFG_GT3(
	.O(ck_div2), // 1-bit output: Buffer
	.CE(1'd1), // 1-bit input: Buffer enable
	.CEMASK(1'd0), // 1-bit input: CE Mask
	.CLR(1'd0), // 1-bit input: Asynchronous clear
	.CLRMASK(1'd0), // 1-bit input: CLR Mask
	.DIV(3'd0), // 3-bit input: Dynamic divide Value
	.I(odiv2) // 1-bit input: Buffer
);

BUFG_GT BUFG_GT0(
	.O(clk125m), // 1-bit output: Buffer
	.CE(1'd1), // 1-bit input: Buffer enable
	.CEMASK(1'd0), // 1-bit input: CE Mask
	.CLR(1'd0), // 1-bit input: Asynchronous clear
	.CLRMASK(1'd0), // 1-bit input: CLR Mask
	.DIV(3'd0), // 3-bit input: Dynamic divide Value
	.I(txoutclk) // 1-bit input: Buffer
);

BUFG_GT BUFG_GT1(
	.O(clk62m), // 1-bit output: Buffer
	.CE(1'd1), // 1-bit input: Buffer enable
	.CEMASK(1'd0), // 1-bit input: CE Mask
	.CLR(1'd0), // 1-bit input: Asynchronous clear
	.CLRMASK(1'd0), // 1-bit input: CLR Mask
	.DIV(3'd1), // 3-bit input: Dynamic divide Value
	.I(txoutclk) // 1-bit input: Buffer
);

BUFG_GT  BUFG_GT2(
    .I(rxoutclk),
    .CE(1'b1),
    .O(rxoutclk_bufgt)
);

clk_wiz_0 u_clk_gen(
	.clk_out1(clk200m),
	.clk_out2(sck125m),
	.clk_out3(clk_ind),  //62.5M
	.resetn(1'd1),
	.locked(mmcm_locked),
	.clk_in1(ck_div2)
);

always @(posedge sck125m or negedge nrst_logic)
begin
	if(~nrst_logic)
		div_125<=0;
	else if(div_125>=124)
		div_125<=0;
	else
		div_125<=div_125+1;
end

always @(posedge sck125m or negedge nrst_logic)
begin
	if(~nrst_logic)
		div_1000<=0;
	else if(div_125>=124)
	begin
		if(div_1000>=999)
			div_1000<=0;
		else
			div_1000<=div_1000+1;
	end
end

always @(posedge sck125m or negedge nrst_logic)
begin
	if(~nrst_logic)
		led_tmr<=0;
	else if(p1ms)
		led_tmr<=led_tmr+1;
end

always @(posedge sck125m or negedge nrst_logic)
begin
	if(~nrst_logic)
		rst_tmr<=0;
	else if(~rst_tmr[15])
		rst_tmr<=rst_tmr+1;
end

//**************************sgmii pcs**************************************//
assign pma_reset=pma_reset_d[7];

always @(posedge clk_ind or posedge pcs_reset)
begin
	if(pcs_reset)
		pma_reset_d<=8'hff;
	else 
		pma_reset_d<={pma_reset_d[6:0],pcs_reset};
end

gig_ethernet_pcs_pma_0 u_pcs_pma(
    .gtrefclk(gtrefclk),               
    .txp(sgmii_txp_o),                   // Differential +ve of serial transmission from PMA to PMD.
    .txn(sgmii_txn_o),                   // Differential -ve of serial transmission from PMA to PMD.
    .rxp(sgmii_rxp_i),                   // Differential +ve for serial reception from PMD to PMA.
    .rxn(sgmii_rxn_i),                   // Differential -ve for serial reception from PMD to PMA.
    .resetdone(resetdone),                 // The GT transceiver has completed its reset cycle
    .cplllock(cplllock),
    .mmcm_reset(mmcm_reset),
    .txoutclk(txoutclk),               
    .rxoutclk(rxoutclk),              
    .userclk(clk62m),                 
    .userclk2(clk125m),                 
    .rxuserclk(rxoutclk_bufgt),                
    .rxuserclk2(rxoutclk_bufgt),               
    .independent_clock_bufg(clk_ind),  //200M
    .pma_reset(pma_reset),                 // transceiver PMA reset signal
    .mmcm_locked(mmcm_locked),               // MMCM Locked
    // GMII Interface
    //---------------
    .sgmii_clk_r(gmii_rx_clk),           
    .sgmii_clk_f(),           
    .sgmii_clk_en(),          // Clock enable for client MAC
    .gmii_txd(gmii_txd),              // Transmit data from client MAC.
    .gmii_tx_en(gmii_tx_en),            // Transmit control signal from client MAC.
    .gmii_tx_er(gmii_tx_er),            // Transmit control signal from client MAC.
    .gmii_rxd(gmii_rxd),              // Received Data to client MAC.
    .gmii_rx_dv(gmii_rx_dv),            // Received control signal to client MAC.
    .gmii_rx_er(gmii_rx_er),            // Received control signal to client MAC.
    .gmii_isolate(),          // Tristate control to electrically isolate GMII.

    // Management: Alternative to MDIO Interface
    //------------------------------------------

    .configuration_vector(CFG),  // Alternative to MDIO interface.
    .an_interrupt           (an_interrupt),
    .an_adv_config_vector   (16'b0000000000100001),
    .an_restart_config      (1'b0),

    // Speed Control
    //--------------
    .speed_is_10_100(1'b0),       // Core should operate at either 10Mbps or 100Mbps speeds
    .speed_is_100(1'b0),          // Core should operate at 100Mbps speed

    // General IO's
    //-------------
    .status_vector(status_vector),         // Core status.
    .reset(pcs_reset),                 // Asynchronous reset for entire core
    
    .gtpowergood(gtpowergood),
    .signal_detect(1'd1)          // Input from PMD to indicate presence of optical input.
);

//*************************ethernet mac*****************************//
tri_mode_ethernet_mac_0 u_eth_mac(
    .gtx_clk(clk125m),
	//.refclk(clk200m),
    // asynchronous reset
    .glbl_rstn(mac_rst_n),
    .rx_axi_rstn(1'd1),
    .tx_axi_rstn(1'd1),
    // Receiver Interface
    .rx_statistics_vector(),
    .rx_statistics_valid(),
    .rx_mac_aclk(mac_rx_clk),
    .rx_reset(mac_rx_reset),
    .rx_axis_mac_tdata(mac_rx_tdata),
    .rx_axis_mac_tvalid(mac_rx_valid),
    .rx_axis_mac_tlast(mac_rx_tlast),
    .rx_axis_mac_tuser(),
    // Transmitter Interface
    .tx_ifg_delay(8'd16),
    .tx_statistics_vector(),
    .tx_statistics_valid(),

    .tx_mac_aclk(mac_tx_clk),
    .tx_reset(mac_tx_reset),
    .tx_axis_mac_tdata(mac_tx_tdata),
    .tx_axis_mac_tvalid(mac_tx_valid),
    .tx_axis_mac_tlast(mac_tx_tlast),
    .tx_axis_mac_tuser(1'd0),
    .tx_axis_mac_tready(mac_tx_ready),
    // MAC Control Interface
    .pause_req(1'd0),
    .pause_val(0), //pause_val),
//    .clk_enable(1'b1),
    .speedis100(  ),
    .speedis10100(  ),
	//GMII Interface
    .gmii_txd(gmii_txd),
    .gmii_tx_en(gmii_tx_en),
	.gmii_tx_er(gmii_tx_er),
    //.gmii_tx_clk(),
    .gmii_rxd(gmii_rxd),
    .gmii_rx_dv(gmii_rx_dv),
	.gmii_rx_er(gmii_rx_er),
    //.gmii_rx_clk(gmii_rx_clk),
    // Configuration Vectors
    .rx_configuration_vector(rx_cfg_vector),
    .tx_configuration_vector(tx_cfg_vector)
);

s_eth_llc u_eth_llc(
	.clki(mac_rx_clk),
	.rsti(mac_rx_reset),
	.s_axis_tvalid_mac(mac_rx_valid),
	.s_axis_tlast_mac (mac_rx_tlast),
	.s_axis_tdata_mac (mac_rx_tdata),
	.m_axis_tready_mac(mac_tx_ready),
    .m_axis_tvalid_mac(mac_tx_valid),
    .m_axis_tlast_mac (mac_tx_tlast),
    .m_axis_tdata_mac (mac_tx_tdata),
	.s_axis_tready_user(axis_tready_user2llc),
    .s_axis_tvalid_user(axis_tvalid_user2llc),
    .s_axis_tlast_user (axis_tlast_user2llc),
    .s_axis_tkeep_user (axis_tkeep_user2llc),
    .s_axis_tdata_user (axis_tdata_user2llc),
    .m_axis_tready_user(axis_tready_llc2user),
    .m_axis_tvalid_user(axis_tvalid_llc2user),
    .m_axis_tlast_user (axis_tlast_llc2user),
    .m_axis_tkeep_user (axis_tkeep_llc2user),
    .m_axis_tdata_user (axis_tdata_llc2user)
);

endmodule