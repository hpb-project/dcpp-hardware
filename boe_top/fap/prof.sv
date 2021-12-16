
`timescale 1 ps / 1 ps

module prof
   (
	input          	rsti  			,
	input			clki			,
	input			mclki			,
  	input	[63:0]	prof_rx_tdatai	,
  	input	[7:0]	prof_rx_tkeepi	,
  	input			prof_rx_tlasti	,
  	input			prof_rx_tvalidi	,
  	output			prof_rx_treadyo	,
  	output	[63:0]	prof_tx_tdatao	,
  	output	[7:0]	prof_tx_tkeepo	,
  	output			prof_tx_tlasto	,
  	output			prof_tx_tvalido	,
  	input			prof_tx_treadyi	
);

(*mark_debug = "true"*)	reg		[10:0]	rx_cnt,tx_cnt,write_cnt,read_cnt;
(*mark_debug = "true"*)	reg		[63:0]	head_fap;
(*mark_debug = "true"*)	reg		[31:0]	fap_id;
(*mark_debug = "true"*)	wire	[63:0]	head_prof;
(*mark_debug = "true"*)	reg		[63:0]	data_prof;
//(*mark_debug = "true"*)	reg				prof_rx_tlast;
//(*mark_debug = "true"*)	reg				prof_rx_tvalid;
//(*mark_debug = "true"*)	reg		[63:0]	prof_rx_tdata;
(*mark_debug = "true"*)	reg				prof_rx_tready;
(*mark_debug = "true"*)	wire			prof_tx_tvalid;
(*mark_debug = "true"*)	wire	[63:0]	prof_tx_tdata;
(*mark_debug = "true"*)	reg		[1:0]	status_block [7:0];
(*mark_debub = "true"*) reg		[7:0]	reg_task_id;
(*mark_debub = "true"*) reg		[7:0]	reg_frm_type;
(*mark_debub = "true"*) reg		[7:0]	reg_sub_frm;
(*mark_debub = "true"*) reg		[7:0]	reg_chk_sum;
(*mark_debug = "true"*)	reg		[2:0]	rx_wbcnt;
(*mark_debug = "true"*)	reg				rx_wen;
(*mark_debug = "true"*)	reg		[63:0]	rx_wdat;
(*mark_debug = "true"*)	reg				rx_ren;
(*mark_debug = "true"*)	wire	[9:0]	rx_len;
(*mark_debug = "true"*)	wire	[63:0]	rx_rdat;
//(*mark_debug = "true"*)	wire	[63:0]	tx_rdat;

(*mark_debug = "true"*)	reg				err_chk_sum;
(*mark_debug = "true"*)	reg				err_chk_sum_d;
(*mark_debug = "true"*)	reg		[63:0]	err_dat;
(*mark_debug = "true"*)	reg		[63:0]	tx_wdat;
(*mark_debug = "true"*)	reg				tx_wen;
(*mark_debug = "true"*)	reg				wea;
(*mark_debug = "true"*)	reg		[12:0]	addra;
(*mark_debug = "true"*)	reg		[12:0]	addrb;
(*mark_debug = "true"*)	reg		[12:0]	rx_rcnt;
							reg		[7:0]	rx_tkeep;
(*mark_debug = "true"*)	reg				rx_tlast;
(*mark_debug = "true"*)	reg				rx_tvalid;
(*mark_debug = "true"*)	reg		[63:0]	rx_tdata;
(*mark_debug = "true"*)	reg		[7:0]	rx_task_id;
(*mark_debug = "true"*)	reg		[7:0]	rx_frm_type;
(*mark_debug = "true"*)	reg		[7:0]	rx_sub_id;
(*mark_debug = "true"*)	reg		[7:0]	rx_chk_sum;
(*mark_debug = "true"*)	wire	[7:0]	chk_sum;
(*mark_debug = "true"*)	wire			rx_empty,rx_full;
(*mark_debug = "true"*)	wire			tx_empty,tx_full;
(*mark_debug = "true"*)	wire	[63:0]	tx_tdata;
(*mark_debug = "true"*)	reg				tx_ren;
	
/*****************rx ****************************/

	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			prof_rx_tready  <= 1'b1;
		end
		else begin
			if(rx_full) prof_rx_tready  <= 1'b0;
			else prof_rx_tready  <= 1'b1;
		end
	end

	assign prof_rx_treadyo = prof_rx_tready;
	assign prof_tx_tkeepo  = 8'hff;
	
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			rx_cnt <= 11'd0;
		end
		else if(prof_rx_tready&prof_rx_tvalidi)begin
			if(prof_rx_tlasti) rx_cnt <= 11'd0;
			else rx_cnt <= rx_cnt + 1;
		end
	end

	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			head_fap 	<= 'd0;
			rx_task_id	<= 'd0;
			rx_frm_type	<= 'd0;
			rx_sub_id	<= 'd0;
			rx_chk_sum	<= 'd0;
		end
		else if(prof_rx_tready&prof_rx_tvalidi)begin
			if(rx_cnt == 11'd0) begin
				head_fap <= endian(prof_rx_tdatai);
			end
			if(rx_cnt == 11'd1) begin
				rx_task_id  <= head_prof[63:56];
				rx_frm_type <= head_prof[47:40];
				rx_sub_id   <= head_prof[39:32];
				rx_chk_sum  <= head_prof[55:48];
			end
		end
	end

	assign head_prof   = endian(prof_rx_tdatai);

//write sub-frame count and frame count
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			reg_chk_sum <= 8'd0;
			reg_sub_frm <= 8'd0;
			reg_task_id <= 8'd0;
			reg_frm_type<= 8'd0;
			fap_id		<= 32'd0;
		end
		else if(prof_rx_tready&prof_rx_tvalidi)begin
			if(rx_cnt == 1)begin
				if((head_prof[63:56] != reg_task_id) || (head_prof[47:40] != reg_frm_type))begin
					reg_task_id  <= head_prof[63:56];
					reg_frm_type <= head_prof[47:40];
					reg_sub_frm  <= 0;
					reg_chk_sum  <= 0;
					fap_id		 <= 0;
				end
				if(head_prof[47:40] == 1)begin
					case(head_prof[39:32])
						0: reg_sub_frm[0] <= 1'b1;
						1: reg_sub_frm[1] <= 1'b1;
						2: reg_sub_frm[2] <= 1'b1;
						3: reg_sub_frm[3] <= 1'b1;
						4:	begin 
								reg_sub_frm[4] <= 1'b1;
								fap_id <= head_fap[63:32];
							end
						default: reg_sub_frm <= 0;
					endcase
				end
				else if(head_prof[47:40] == 0)begin
					case(head_prof[39:32])
						0: reg_sub_frm[0] <= 1'b1;
						1: reg_sub_frm[1] <= 1'b1;
						2:	begin 
								reg_sub_frm[2] <= 1'b1;
								fap_id <= head_fap[63:32];
							end
						default: reg_sub_frm <= 0;
					endcase
				end
			end
			else if(rx_cnt > 1)begin
				reg_chk_sum <= 	reg_chk_sum + chk_sum;
			end
		end
	end
	
	assign chk_sum = prof_rx_tdatai[63:56] + prof_rx_tdatai[55:48] + 
					 prof_rx_tdatai[47:40] + prof_rx_tdatai[40:32] + prof_rx_tdatai[31:24] + 
					 prof_rx_tdatai[23:16] + prof_rx_tdatai[15:8] + prof_rx_tdatai[7:0];
	
//write sub-frame count and frame count
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			err_chk_sum <= 1'b0;
			err_dat		<= 64'd0;
			rx_wbcnt	<= 3'd0;
			rx_wen		<= 1'b0;
			rx_wdat		<= 64'd0;
		end
		else begin
			rx_wen		<= 1'b0;
			err_chk_sum <= 1'b0;
			if(prof_rx_tready&prof_rx_tvalidi&prof_rx_tlasti)begin
				if(((rx_frm_type == 1)&&(reg_sub_frm == 8'h1f))||((rx_frm_type == 0)&&(reg_sub_frm == 8'h07)))begin
					if((reg_chk_sum + chk_sum) == rx_chk_sum)begin
						err_chk_sum <= 0;
						rx_wbcnt	<= rx_wbcnt + 1;
						rx_wen		<= 1'b1;
						rx_wdat		<= {rx_frm_type,8'd0,rx_task_id,5'd0,rx_wbcnt,fap_id};
					end
					else begin
						err_chk_sum <= 1;
						err_dat		<= {rx_frm_type,8'h13,8'h01,8'h04,fap_id};
					end
				end
			end
		end
	end
	

//memory write control
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			wea  		<= 1'd0;
			addra		<= 13'd0;
			data_prof 	<= 64'd0;
		end
		else begin
			wea		<= 1'b0;
			if(prof_rx_tready&prof_rx_tvalidi)begin
				if(rx_cnt > 1)begin
					wea 		<= 1'b1;
					data_prof 	<= endian(prof_rx_tdatai);
					addra 		<= (rx_wbcnt*8+rx_sub_id)*128 + rx_cnt - 2;
				end
				else begin
					wea  		<= 1'd0;
					addra		<= 13'd0;
					data_prof 	<= 64'd0;
				end
			end
		end
	end
	
//fifo read control

	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			rx_ren <= 1'b0;
		end
		else begin
			rx_ren <= 1'b0;
			if((rx_tready == 1)&&(rx_empty == 0))begin
				rx_ren <= 1'b1;
			end
		end
	end
	
	fifo_64x16 rx_fifo(
		.rst		(rsti),
		.wr_clk		(clki),
		.rd_clk		(clki),
		.din		(rx_wdat),
		.wr_en		(rx_wen),
		.rd_en		(rx_ren),
		.dout		(rx_rdat),
		.full		(rx_full),
		.empty		(rx_empty)
	);
	
//memory read control
	assign rx_tkeep = 8'hff;
	assign rx_len	= (rx_rdat[63:56]==1)?10'd636:10'd364;
	assign addrb	= rx_rdat[39:32]*1024 + rx_rcnt - 1;
	
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			rx_tvalid	<= 1'b0;
			rx_tlast	<= 1'b0;
			rx_rcnt		<= 10'h3ff;
		end
		else begin
			if(rx_ren)begin
				rx_rcnt 	<= 10'd0;
				rx_tvalid	<= 1'b0;
			end
			else if(rx_rcnt < rx_len+1)begin
				rx_tvalid 	<= 1'b1;
				rx_rcnt		<= rx_rcnt + 1;
			end
			else begin
				rx_tvalid	<= 1'b0;
			end
			if(rx_rcnt == rx_len)begin
				rx_tlast	<= 1'b1;
			end
			else begin
				rx_tlast	<= 1'b0;
			end
		end
	end
	
	
	ramdp_64x8192 mem_prof(
		.clka		(clki),
		.wea		(wea),
		.addra		(addra),
		.dina		(data_prof),
		.clkb		(clki),
		.addrb		(addrb),
		.enb		(1'b1),
		.doutb		(rx_tdata)
	);
	
	
/**********proof module ***************/
`ifdef SIM
	tm_proof u_proof(
		.clki			(clki),
		.rsti		    (~rsti),
		.rx_treadyo     (rx_tready),
		.rx_tvalidi	    (rx_tvalid),
		.rx_tlasti	    (rx_tlast),
		.rx_tdatai	    ((rx_rcnt==1)?rx_rdat:rx_tdata),
		.tx_treadyi	    (1'b1),
		.tx_tvalido	    (tx_tvalid),
		.tx_tlasto	    (tx_tlast),
		.tx_tdatao	    (tx_tdata)
	);
`else
	proof_top u_proof(
		.clk_i			(clki),
		.arst_ni		(~rsti),
		.axi_ready_o	(rx_tready),
		.axi_valid_i	(rx_tvalid),
		.axi_tlast_i	(rx_tlast),
		.axi_tdata_i	((rx_rcnt==1)?rx_rdat:rx_tdata),
		.axi_ready_i	(1'b1),
		.axi_valid_o	(tx_tvalid),
		.axi_tlast_o	(tx_tlast),
		.axi_tdata_o	(tx_tdata)
	);
`endif
	
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			tx_wdat			<= 64'd0;
			tx_wen			<= 1'b0;
			err_chk_sum_d	<= 1'b0;
		end
		else begin
			tx_wen	<= 1'b0;
			err_chk_sum_d <= err_chk_sum;
			if(tx_tvalid&tx_tlast)begin
				tx_wen	<= 1'b1;
				tx_wdat	<= {tx_tdata[63:49],~tx_tdata[48],tx_tdata[47:0]};
			end
			else if(!err_chk_sum_d && err_chk_sum)begin
				tx_wen	<= 1'b1;
				tx_wdat	<= err_dat;
			end
		end
	end
	 	
	fifo_64x16 tx_fifo(
		.rst		(rsti),
		.wr_clk		(clki),
		.rd_clk		(clki),
		.din		({tx_wdat[63:48],8'h03,tx_wdat[39:0]}),
		.wr_en		(tx_wen),
		.rd_en		(prof_tx_treadyi&(!tx_empty)),
		.dout		(prof_tx_tdata),
		.full		(tx_full),
		.empty		(tx_empty)
	);
	
	assign prof_tx_tdatao = endian({prof_tx_tdata[31:0],8'h04,8'h01,prof_tx_tdata[55:48],prof_tx_tdata[63:56]});
	always@(posedge rsti or posedge clki)
	begin
		if(rsti)begin
			tx_ren	<= 1'b0;
		end
		else begin
			tx_ren	<=	prof_tx_treadyi&(!tx_empty);
		end
	end
	assign prof_tx_tlasto = (tx_ren)?prof_tx_tdata[40]:1'b0;
	assign prof_tx_tvalido= (tx_ren)?prof_tx_tdata[41]:1'b0;
	
/*******function for big/little endian***********/
	function [63:0] endian;
		input	[63:0] 	dati;
		begin
			endian = {dati[7:0],dati[15:8],dati[23:16],dati[31:24],dati[39:32],dati[47:40],dati[55:48],dati[63:56]};
		end
	endfunction
	
//function
endmodule
