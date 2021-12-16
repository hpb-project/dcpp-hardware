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

module vrfy
   (
	input          	rsti  			,
	input			clki			,
	input			mclki			,
  	input	[63:0]	vrfy_rx_tdatai	,
  	input	[7:0]	vrfy_rx_tkeepi	,
  	input			vrfy_rx_tlasti	,
  	input			vrfy_rx_tvalidi	,
  	output			vrfy_rx_treadyo	,
  	output	[63:0]	vrfy_tx_tdatao	,
  	output	[7:0]	vrfy_tx_tkeepo	,
  	output			vrfy_tx_tlasto	,
  	output			vrfy_tx_tvalido	,
  	input			vrfy_tx_treadyi	
);

(*mark_debug = "true"*)	reg		[7:0]	rcnt,tcnt,vrcnt;
(*mark_debug = "true"*)	reg		[63:0]	head;
(*mark_debug = "true"*)	reg		[255:0]	data_r,data_s,data_h;
(*mark_debug = "true"*)	reg		[7:0]	data_v;
(*mark_debug = "true"*)	reg				vrfy_rx_tlast,vrfy_rx_tvalid;
(*mark_debug = "true"*)	reg		[63:0]	vrfy_rx_tdata;
(*mark_debug = "true"*)	wire			vrfy_tx_tvalid;
(*mark_debug = "true"*)	wire	[63:0]	vrfy_tx_tdata;
	
	assign vrfy_rx_treadyo = vrfy_rx_tready;
	assign vrfy_tx_tkeepo  = 8'hff;
	
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			rcnt <= 8'd0;
		end
		else if(vrfy_rx_tready&vrfy_rx_tvalidi)begin
			if(vrfy_rx_tlasti) rcnt <= 8'd0;
			else rcnt <= rcnt + 1;
		end
	end

	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			head  	<= 64'd0;
			data_r	<= 256'd0;
			data_s	<= 256'd0;
			data_h	<= 256'd0;
			data_v	<= 8'd0;
		end
		else if(vrfy_rx_tready&vrfy_rx_tvalidi)begin
			if(rcnt == 8'd0) head         <= endian(vrfy_rx_tdatai);
			else if(rcnt <= 8'd4) data_r  <= {data_r[191:0],endian(vrfy_rx_tdatai)};
			else if(rcnt <= 8'd8) data_s  <= {data_s[191:0],endian(vrfy_rx_tdatai)};
			else if(rcnt <= 8'd12) data_h <= {data_h[191:0],endian(vrfy_rx_tdatai)};
			else if(rcnt <= 8'd13) data_v <= vrfy_rx_tdatai[7:0];
		end
	end
	
	
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			vrcnt <= 8'd31;
		end
		else if(vrfy_rx_tready) begin
			if(vrfy_rx_tvalidi&vrfy_rx_tlasti)
				vrcnt <= 8'd0;
			else if(vrcnt < 8'd31)
				vrcnt <= vrcnt + 1;
		end
	end

	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			vrfy_rx_tvalid  <= 1'd0;
			vrfy_rx_tlast	<= 1'd0;
			vrfy_rx_tdata	<= 64'd0;
		end
		else if(vrfy_rx_tready) begin
			case(vrcnt)
				8'd1:begin
					vrfy_rx_tvalid <= 1'b1;
					vrfy_rx_tlast  <= 1'b0;
					vrfy_rx_tdata  <= {data_v,24'd0,head[63:32]};
				end
				8'd2:vrfy_rx_tdata <= data_r[255:192];
				8'd3:vrfy_rx_tdata <= data_r[191:128];
				8'd4:vrfy_rx_tdata <= data_r[127:64];
				8'd5:vrfy_rx_tdata <= data_r[63:0];
				8'd6:vrfy_rx_tdata <= data_s[255:192];
				8'd7:vrfy_rx_tdata <= data_s[191:128];
				8'd8:vrfy_rx_tdata <= data_s[127:64];
				8'd9:vrfy_rx_tdata <= data_s[63:0];
				8'd10:vrfy_rx_tdata <= data_h[255:192];
				8'd11:vrfy_rx_tdata <= data_h[191:128];
				8'd12:vrfy_rx_tdata <= data_h[127:64];
				8'd13:begin
					vrfy_rx_tlast	<= 1'd1;
					vrfy_rx_tdata <= data_h[63:0];
				end
				default:begin
					vrfy_rx_tvalid  <= 1'd0;
					vrfy_rx_tlast	<= 1'd0;
					vrfy_rx_tdata	<= 64'd0;
				end
			endcase
		end
	end

	ECSDA_verify8_eth u_vrfy(
		.clk_i				(mclki),
		.arst_ni			(~rsti),
		.axi_wrclk_i		(clki),
		.axi_ready_o		(vrfy_rx_tready),
		.axi_valid_i		(vrfy_rx_tvalid),
		.axi_tlast_i		(vrfy_rx_tlast),
		.axi_tdata_i		(vrfy_rx_tdata),
		.axi_rdclk_i		(clki),
		.axi_ready_i		(vrfy_tx_treadyi),
		.axi_valid_o		(vrfy_tx_tvalid),
		.axi_tlast_o		(vrfy_tx_tlast),
		.axi_tdata_o		(vrfy_tx_tdata)
	);
	
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			tcnt <= 8'd0;
		end
		else if(vrfy_tx_treadyi&vrfy_tx_tvalid)begin
			if(vrfy_tx_tlast) tcnt <= 8'd0;
			else tcnt <= tcnt + 1;
		end
	end

	assign vrfy_tx_tvalido = vrfy_tx_tvalid;
	assign vrfy_tx_tlasto  = vrfy_tx_tlast;
	assign vrfy_tx_tdatao  = (tcnt == 8'd0)?endian({vrfy_tx_tdata[31:0],head[31:0]}):endian(vrfy_tx_tdata);

	function [63:0] endian;
		input	[63:0] 	dati;
		begin
			endian = {dati[7:0],dati[15:8],dati[23:16],dati[31:24],dati[39:32],dati[47:40],dati[55:48],dati[63:56]};
		end
	endfunction
endmodule
