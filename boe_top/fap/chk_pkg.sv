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

module chk_pkg
   (
	input          	rsti  			,
	input			clki			,
	input			mclki			,
  	input	[63:0]	chk_rx_tdatai	,
  	input	[7:0]	chk_rx_tkeepi	,
  	input			chk_rx_tlasti	,
  	input			chk_rx_tvalidi	,
  	output			chk_rx_treadyo	,
  	output	[63:0]	chk_tx_tdatao	,
  	output	[7:0]	chk_tx_tkeepo	,
  	output			chk_tx_tlasto	,
  	output			chk_tx_tvalido	,
  	input			chk_tx_treadyi	
);

reg		[7:0]	chksum;
reg		[7:0]	rcnt,tcnt,vrcnt;
reg		[63:0]	head;
reg		[255:0]	data_r,data_s,data_h;
reg		[7:0]	data_v;
reg				chk_rx_tlast,chk_rx_tvalid;
reg		[63:0]	chk_rx_tdata;
wire			chk_tx_tvalid;
wire	[63:0]	chk_tx_tdata;
	
	assign chk_rx_tready  = 1;
	assign chk_rx_treadyo = chk_rx_tready;
	assign chk_tx_tkeepo  = 8'hff;
	
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			rcnt <= 8'd0;
		end
		else if(chk_rx_tready&chk_rx_tvalidi)begin
			if(chk_rx_tlasti) rcnt <= 8'd0;
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
			chksum	<= 8'd0;
		end
		else if(chk_rx_tready&chk_rx_tvalidi)begin
			if(rcnt == 8'd0) begin
				head 	<= endian(chk_rx_tdatai);
			end
			else if(rcnt <= 8'd4) begin
				data_r  <= {data_r[191:0],endian(chk_rx_tdatai)};
				chksum	<= chksum + chk_rx_tdatai[7:0] + chk_rx_tdatai[15:8]
								  + chk_rx_tdatai[23:16] + chk_rx_tdatai[31:24]
								  + chk_rx_tdatai[39:32] + chk_rx_tdatai[47:40]
								  + chk_rx_tdatai[55:48] + chk_rx_tdatai[63:56];
			end
			else if(rcnt <= 8'd8) begin
				data_s  <= {data_s[191:0],endian(chk_rx_tdatai)};
				chksum	<= chksum + chk_rx_tdatai[7:0] + chk_rx_tdatai[15:8]
								  + chk_rx_tdatai[23:16] + chk_rx_tdatai[31:24]
								  + chk_rx_tdatai[39:32] + chk_rx_tdatai[47:40]
								  + chk_rx_tdatai[55:48] + chk_rx_tdatai[63:56];
			end
			else if(rcnt <= 8'd12) begin
				data_h <= {data_h[191:0],endian(chk_rx_tdatai)};
				chksum	<= chksum + chk_rx_tdatai[7:0] + chk_rx_tdatai[15:8]
								  + chk_rx_tdatai[23:16] + chk_rx_tdatai[31:24]
								  + chk_rx_tdatai[39:32] + chk_rx_tdatai[47:40]
								  + chk_rx_tdatai[55:48] + chk_rx_tdatai[63:56];
			end
			else if(rcnt <= 8'd13) begin
				data_v <= chk_rx_tdatai[7:0];
				chksum	<= chksum + chk_rx_tdatai[7:0] + chk_rx_tdatai[15:8]
								  + chk_rx_tdatai[23:16] + chk_rx_tdatai[31:24]
								  + chk_rx_tdatai[39:32] + chk_rx_tdatai[47:40]
								  + chk_rx_tdatai[55:48] + chk_rx_tdatai[63:56];
			end
		end
	end
	
	
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			vrcnt <= 8'd31;
		end
		else begin
			if(chk_rx_tready&chk_rx_tvalidi&chk_rx_tlasti)
				vrcnt <= 8'd0;
			else if(vrcnt < 8'd31) vrcnt <= vrcnt + 1;
		end
	end

	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			chk_rx_tvalid  <= 1'd0;
			chk_rx_tlast	<= 1'd0;
			chk_rx_tdata	<= 64'd0;
		end
		else if(chk_rx_tready) begin
			case(vrcnt)
				8'd1:begin
					chk_rx_tvalid <= 1'b1;
					chk_rx_tlast  <= 1'b0;
					chk_rx_tdata  <= {data_v,24'd0,head[63:32]};
				end
				8'd2:chk_rx_tdata <= data_r[255:192];
				8'd3:chk_rx_tdata <= data_r[191:128];
				8'd4:chk_rx_tdata <= data_r[127:64];
				8'd5:chk_rx_tdata <= data_r[63:0];
				8'd6:chk_rx_tdata <= data_s[255:192];
				8'd7:chk_rx_tdata <= data_s[191:128];
				8'd8:chk_rx_tdata <= data_s[127:64];
				8'd9:chk_rx_tdata <= data_s[63:0];
				8'd10:chk_rx_tdata <= data_h[255:192];
				8'd11:chk_rx_tdata <= data_h[191:128];
				8'd12:chk_rx_tdata <= data_h[127:64];
				8'd13:begin
					chk_rx_tlast	<= 1'd1;
					chk_rx_tdata <= data_h[63:0];
				end
				default:begin
					chk_rx_tvalid  <= 1'd0;
					chk_rx_tlast	<= 1'd0;
					chk_rx_tdata	<= 64'd0;
				end
			endcase
		end
	end

	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			tcnt <= 8'd0;
		end
		else if(chk_tx_treadyi&chk_tx_tvalid)begin
			if(chk_tx_tlast) tcnt <= 8'd0;
			else tcnt <= tcnt + 1;
		end
	end

	assign chk_tx_tvalido = chk_tx_tvalid;
	assign chk_tx_tlasto  = chk_tx_tlast;
	assign chk_tx_tdatao  = (tcnt == 8'd0)?endian({chk_tx_tdata[31:0],head[31:0]}):endian(chk_tx_tdata);

	function [63:0] endian;
		input	[63:0] 	dati;
		begin
			endian = dati;//{dati[7:0],dati[15:8],dati[23:16],dati[31:24],dati[39:32],dati[47:40],dati[55:48],dati[63:56]};
		end
	endfunction
endmodule
