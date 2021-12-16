`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/04 19:50:36
// Design Name: 
// Module Name: s_eth_llc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module s_eth_llc(
input	clki,
input   rsti,
//mac if
(*mark_debug = "true"*)input        s_axis_tvalid_mac,
(*mark_debug = "true"*)input        s_axis_tlast_mac,
(*mark_debug = "true"*)input   [7:0]s_axis_tdata_mac,
(*mark_debug = "true"*)input        m_axis_tready_mac,
(*mark_debug = "true"*)output       m_axis_tvalid_mac,
(*mark_debug = "true"*)output       m_axis_tlast_mac,
(*mark_debug = "true"*)output  [7:0]m_axis_tdata_mac,
//user if
(*mark_debug = "true"*)output  [3:0]s_axis_tready_user,
(*mark_debug = "true"*)input   [3:0]s_axis_tvalid_user,
(*mark_debug = "true"*)input   [3:0]s_axis_tlast_user,
(*mark_debug = "true"*)input   [7:0]s_axis_tkeep_user[3:0],
(*mark_debug = "true"*)input   [63:0]s_axis_tdata_user[3:0],
(*mark_debug = "true"*)input   [3:0]m_axis_tready_user,
(*mark_debug = "true"*)output  [3:0]m_axis_tvalid_user,
(*mark_debug = "true"*)output  [3:0]m_axis_tlast_user,
(*mark_debug = "true"*)output  [7:0]m_axis_tkeep_user[3:0],
(*mark_debug = "true"*)output  [63:0]m_axis_tdata_user[3:0]
    );
    
wire        remote_mac_en;
wire [47:0] remote_mac;

//-------------------------llc encode--------------------------------   
(*mark_debug = "true"*)wire       axis_tvalid_mux2encode;
(*mark_debug = "true"*)wire        axis_tready_mux2encode;
(*mark_debug = "true"*)wire        axis_tlast_mux2encode;
(*mark_debug = "true"*)wire [7:0]  axis_tdata_mux2encode;
(*mark_debug = "true"*)wire [1:0]  axis_tid_mux2encode;
   
axis_4to1_wapper u_axis_mux(
    .clki      ( clki  ),
    .rsti      ( rsti  ),
    .s_axis_tvalid( s_axis_tvalid_user  ),
    .s_axis_tready( s_axis_tready_user  ),
    .s_axis_tlast ( s_axis_tlast_user   ),
    .s_axis_tkeep ( s_axis_tkeep_user   ),
    .s_axis_tdata ( s_axis_tdata_user   ),
    .m_axis_tvalid( axis_tvalid_mux2encode  ),
    .m_axis_tready( axis_tready_mux2encode  ),
    .m_axis_tlast ( axis_tlast_mux2encode   ),
    .m_axis_tdata ( axis_tdata_mux2encode   ),
    .m_axis_tid   ( axis_tid_mux2encode     )
    );
 
 
eth_llc_encode u_eth_llc_encode(
            .clki           ( clki ),
            .rsti           ( rsti ),
            .s_axis_tready  ( axis_tready_mux2encode ),
            .s_axis_tvalid  ( axis_tvalid_mux2encode ),
            .s_axis_tlast   ( axis_tlast_mux2encode ),
            .s_axis_tdata   ( axis_tdata_mux2encode ),
            .s_axis_tid     ( axis_tid_mux2encode ),
            .m_axis_tready  ( m_axis_tready_mac ),
            .m_axis_tvalid  ( m_axis_tvalid_mac ),
            .m_axis_tlast   ( m_axis_tlast_mac  ),
            .m_axis_tdata   ( m_axis_tdata_mac  ),
            .remote_mac_en_i(remote_mac_en),
            .remote_mac_i   (remote_mac)
            );

//---------------------------------------


//----------------llc decode---------------------      
(*mark_debug = "true"*)wire [3:0] axis_tvalid_decode2fifo     ;  
(*mark_debug = "true"*)wire [3:0] axis_tlast_decode2fifo      ;  
(*mark_debug = "true"*)wire [7:0] axis_tdata_decode2fifo [3:0]    ;  
 
(*mark_debug = "true"*)wire [3:0] axis_tready_fifo2conv     ;  
(*mark_debug = "true"*)wire [3:0] axis_tvalid_fifo2conv     ;  
(*mark_debug = "true"*)wire [3:0] axis_tlast_fifo2conv      ;  
(*mark_debug = "true"*)wire [7:0] axis_tdata_fifo2conv [3:0]    ;  
 
eth_llc_decode u_eth_llc_decode(
                    .clki           ( clki ),
                    .rsti           ( rsti ),
                    .s_axis_tvalid  ( s_axis_tvalid_mac ),
                    .s_axis_tlast   ( s_axis_tlast_mac ),
                    .s_axis_tdata   ( s_axis_tdata_mac ),
                    .m_axis_tvalid  ( axis_tvalid_decode2fifo ),
                    .m_axis_tlast   ( axis_tlast_decode2fifo  ),
                    .m_axis_tdata   ( axis_tdata_decode2fifo  ),
                    .remote_mac_en_o(remote_mac_en),
                    .remote_mac_o   (remote_mac)
                    );
                    

            
genvar var_i;
            generate
               for (var_i=0 ; var_i<=3; var_i=var_i+1)  begin: gen_fifo
//            axis_data_fifo_0 u_fifo(
            axis_pkt_fifo  #(.FIFO_SIZE(4096)) u_fifo(
              .s_axis_aresetn    ( ~rsti  ),
              .m_axis_aresetn    ( ~rsti  ),
              .s_axis_aclk       ( clki  ),
              .m_axis_aclk       ( clki  ),
              .s_axis_tvalid     ( axis_tvalid_decode2fifo[var_i]  ),
              .s_axis_tready     (   ),
              .s_axis_tdata      ( axis_tdata_decode2fifo[var_i]  ),
              .s_axis_tlast      ( axis_tlast_decode2fifo[var_i]  ),
              .m_axis_tvalid     ( axis_tvalid_fifo2conv[var_i]  ),
              .m_axis_tready     ( axis_tready_fifo2conv[var_i]  ),
              .m_axis_tdata      ( axis_tdata_fifo2conv[var_i]   ),
              .m_axis_tlast      ( axis_tlast_fifo2conv[var_i]   )
            );
            
            axis_dwidth_converter_0 u_axis_dwidth_conv(
              .aclk           ( clki ),
              .aresetn        ( ~rsti ),
              .s_axis_tvalid  ( axis_tvalid_fifo2conv[var_i] ),
              .s_axis_tready  ( axis_tready_fifo2conv[var_i] ),
              .s_axis_tdata   ( axis_tdata_fifo2conv[var_i] ),
              .s_axis_tkeep   ( 1'b1  ),
              .s_axis_tlast   ( axis_tlast_fifo2conv[var_i] ),
              .m_axis_tvalid  ( m_axis_tvalid_user[var_i]  ),
              .m_axis_tready  ( m_axis_tready_user[var_i] ),
              .m_axis_tdata   ( m_axis_tdata_user[var_i]  ),
              .m_axis_tkeep   ( m_axis_tkeep_user[var_i]  ),
              .m_axis_tlast   ( m_axis_tlast_user[var_i]  )
            );
               end
            endgenerate
//-----------------------------------------------------------------------                        
                        
    
endmodule
