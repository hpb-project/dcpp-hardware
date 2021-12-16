`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/13 14:39:28
// Design Name: 
// Module Name: axis_pkt_fifo
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


module axis_pkt_fifo#(parameter FIFO_SIZE = 512)
  (
    s_axis_aresetn,	    //
    m_axis_aresetn,	    //
    s_axis_aclk,	    //s is fifo in
    s_axis_tdata,
    s_axis_tvalid,
    s_axis_tlast,
    s_axis_tready,
    m_axis_aclk,	    // m is fifo out
    m_axis_tdata,
    m_axis_tvalid,
    m_axis_tlast,
    m_axis_tready
);
//==========================================================
localparam ADDR_WIDTH = (FIFO_SIZE == 512)   ? 9 :
                        (FIFO_SIZE == 1024)  ? 10 :
                        (FIFO_SIZE == 2048)  ? 11 :
                        (FIFO_SIZE == 4096)  ? 12 :
                        (FIFO_SIZE == 8192)  ? 13 :
                        (FIFO_SIZE == 16384) ? 14 : 9;
parameter FULL_THRESHOLD=8;
parameter W_FSM_IDLE=2'd0;
parameter W_FSM_DATA=2'd1;
parameter W_FSM_DISC=2'd2;

parameter R_FSM_IDLE=2'd0;
parameter R_FSM_DATA=2'd1;
//==========================================================
    input		s_axis_aresetn;	    //
    input		m_axis_aresetn;	    //

    input		    s_axis_aclk;	    //s is fifo in
    input[7:0]	    s_axis_tdata;
    input		    s_axis_tvalid;
    input		    s_axis_tlast;
    output          s_axis_tready;
    
    input		    m_axis_aclk;	    // m is fifo out
    output[7:0]     m_axis_tdata;
    output		    m_axis_tvalid;
    output		    m_axis_tlast;
    input		    m_axis_tready;

    
//===========================================================
    reg                ram_full;
    reg [ADDR_WIDTH:0] ram_used;
    reg[ADDR_WIDTH:0]  waddr_reg;
    wire[ADDR_WIDTH:0] raddr_in_wr_side;
    reg[ADDR_WIDTH:0]  waddr;
    wire	           wren;
    wire[7:0]	       wdata;

    reg [ADDR_WIDTH:0]  raddr;
    wire[ADDR_WIDTH:0]  raddr_comb;
    wire		        rden;
    wire[7:0]	        rdata;
    
    wire	        s_info_tready;
    reg		        s_info_tvalid;
    reg[31:0]	    s_info_tdata;
    wire	        m_info_tvalid;
    wire[31:0]	    m_info_tdata;
    reg		        m_info_tready;
    
//---------------send raddr of data ram to write side-------------
    wire raddr_fifo_full;
    wire raddr_fifo_empty;
    
fifo1x  #(.DW(ADDR_WIDTH+1)) u_raddr_fifo 
(
.aclri ( ~s_axis_aresetn  ),
.wclki ( m_axis_aclk  ),
.wei   ( !raddr_fifo_full  ),
.wdatai( raddr  ),
.fullo ( raddr_fifo_full  ),
.rclki ( s_axis_aclk   ),
.rei   ( !raddr_fifo_empty  ),
.rdatao( raddr_in_wr_side  ),
.emptyo( raddr_fifo_empty  )
);
    
    
 //--------------calculate used ram and generate full flag----------------- 
    always @(posedge s_axis_aclk or negedge s_axis_aresetn)begin
        if(~s_axis_aresetn)begin
            ram_used <= 'd0;
            ram_full<=1'b0;
        end else begin
            ram_used <=  (waddr[ADDR_WIDTH]==raddr_in_wr_side[ADDR_WIDTH]) ? (waddr[ADDR_WIDTH-1:0]-raddr_in_wr_side[ADDR_WIDTH-1:0])  :  ({1'b1,waddr[ADDR_WIDTH-1:0]}-{1'b0,raddr_in_wr_side[ADDR_WIDTH-1:0]});
            ram_full <= (ram_used > FIFO_SIZE-FULL_THRESHOLD) ? 1'b1 : 1'b0;
        end
    end
   
    
//---------------fsm in wr side------------------------
    reg[1:0]	w_cs;
    reg[1:0]	w_ns;
    
    always @(*)begin
        w_ns<=w_cs;
        
        case(w_cs)
            W_FSM_IDLE : begin
                if(s_axis_tvalid==1'b1 && s_axis_tlast==1'b0)begin 
                    if((!ram_full) && s_info_tready)
                         w_ns <= W_FSM_DATA;
                    else   
                         w_ns <= W_FSM_DISC;
                end
            end
            W_FSM_DATA : begin
                if(s_axis_tvalid )
                    if(s_axis_tlast) 
                        w_ns <= W_FSM_IDLE;
                    else if(ram_full)
                        w_ns<=W_FSM_DISC;
            end
            W_FSM_DISC : begin
                if(s_axis_tvalid && s_axis_tlast)
                    w_ns <= W_FSM_IDLE;
            end
            default : begin
              w_ns <= W_FSM_IDLE;
            end
        endcase
    end
    
     always @(posedge s_axis_aclk or negedge s_axis_aresetn)begin
        if(~s_axis_aresetn)begin
            w_cs <= W_FSM_IDLE;
        end else begin
            w_cs <= w_ns;
        end
    end
   
 //---------------write to the data ram---------------------
 assign wren  = (s_axis_tvalid==1'b1 && (w_ns==W_FSM_DATA || w_cs==W_FSM_DATA )) ? 1'b1 : 1'b0;
 assign wdata = s_axis_tdata;
 
   always @(posedge s_axis_aclk or negedge s_axis_aresetn)begin
      if(~s_axis_aresetn)begin
          waddr <= 0;
      end else if(w_cs==W_FSM_DISC && w_ns==W_FSM_IDLE) begin
          waddr <= waddr_reg;
      end else if(wren==1'b1)begin
          waddr <=  waddr + 1'b1;
      end
  end

   always @(posedge s_axis_aclk or negedge s_axis_aresetn)begin
        if(~s_axis_aresetn)begin
            waddr_reg <= 0;
        end	else if(w_cs==W_FSM_IDLE &&  w_ns==W_FSM_DATA)begin
            waddr_reg <=  waddr;
        end
    end


//-------------write to info fifo---------------
    always @(posedge s_axis_aclk or negedge s_axis_aresetn)begin
        if(~s_axis_aresetn)begin
            s_info_tvalid <= 1'b0;
            s_info_tdata <= 'd0;
        end	else if(w_cs == W_FSM_DATA && w_ns == W_FSM_IDLE )begin//��Ч������ʱ
            s_info_tvalid <= 1'b1;
            s_info_tdata <= waddr;
        end else begin
            s_info_tvalid <= 1'b0;
        end
    end

//-----------------signal to s_axis------------
assign s_axis_tready=1'b1;    
    
    
//====================================================================================================
//����״̬��
    reg[1:0]	r_cs;
    reg[1:0]	r_ns;
    
    always @(posedge m_axis_aclk or negedge m_axis_aresetn)begin
        if(~m_axis_aresetn)begin
            r_cs <= R_FSM_IDLE;
        end	else begin
            r_cs <= r_ns;
        end
    end
    
    always @(*)begin
        r_ns<=r_cs;
        
        case(r_cs)
            R_FSM_IDLE : begin
                if(m_info_tvalid)begin
                    r_ns <= R_FSM_DATA;
                end
            end
            R_FSM_DATA : begin
                if(m_axis_tready==1'b1 && raddr==m_info_tdata[ADDR_WIDTH:0]) begin 
                    r_ns <= R_FSM_IDLE;
                end
            end
            default : begin
                r_ns <= R_FSM_IDLE;
            end
        endcase
    end

//--------------signal to data ram------------------
assign rden = ((r_cs==R_FSM_IDLE && r_ns==R_FSM_DATA) || (r_cs==R_FSM_DATA && r_ns==R_FSM_DATA && m_axis_tready==1'b1)) ?  1'b1 : 1'b0;
assign raddr_comb = (r_cs==R_FSM_IDLE && r_ns==R_FSM_DATA) ? raddr : raddr+1'b1;

always @(posedge m_axis_aclk or negedge m_axis_aresetn)begin
    if(~m_axis_aresetn)begin
        raddr <= 'd0;
    end	else if (r_cs==R_FSM_DATA && m_axis_tready==1'b1) begin
       raddr<= raddr+1;
    end
end

//---------------signal to info fifo-----------------
assign m_info_tready = (r_cs==R_FSM_DATA && r_ns==R_FSM_IDLE) ? 1'b1 : 1'b0;

//---------------signal to m_axis--------------------
assign m_axis_tvalid = (r_cs==R_FSM_DATA) ? 1'b1: 1'b0;    
assign m_axis_tlast  = (r_cs==R_FSM_DATA && r_ns==R_FSM_IDLE) ? 1'b1: 1'b0;
assign m_axis_tdata  =  rdata;


 //====================================================================================================
//����Ϣfifo���洢����ram�е��׵�ַ�������ȣ�У����
axis_data_fifo_128x32 info_fifo
   (.s_axis_aresetn(s_axis_aresetn),
//    .m_axis_aresetn(m_axis_aresetn),
    .s_axis_aclk(s_axis_aclk),
    .s_axis_tvalid(s_info_tvalid),
    .s_axis_tready(s_info_tready),
    .s_axis_tdata(s_info_tdata),
    .m_axis_aclk(m_axis_aclk),
    .m_axis_tvalid(m_info_tvalid),
    .m_axis_tready(m_info_tready),
    .m_axis_tdata(m_info_tdata),
//    .axis_data_count(),
    .axis_wr_data_count(),
    .axis_rd_data_count());
//=====================================================================================================
//������ram
sdp_ram 
#(
.ADDR_WIDTH(ADDR_WIDTH),
.DATA_WIDTH(8)
)
data_ram
(
.wr_clk(s_axis_aclk),
.wr_addr(waddr[ADDR_WIDTH-1:0]),
.data_in(wdata),
.wr_allow(wren),
.rd_clk(m_axis_aclk),
.rd_sreset(~m_axis_aresetn),
.rd_addr(raddr_comb[ADDR_WIDTH-1:0]),
.data_out(rdata),
.rd_allow(rden));

endmodule
