`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/13 17:02:57
// Design Name: 
// Module Name: fifo1x
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



module fifo1x(aclri,wclki,wei,wdatai,fullo,rclki,rei,rdatao,emptyo);

   parameter DW = 8;        // Data bus width
   
   input           aclri;       // master reset,active high 
   input           wclki;        // write Port Clock
   input           wei;          // read enable, synchronous, high active
   input           rclki;        // read Port Clock 
   input           rei;          // read enable, synchronous, high active
   output          fullo;        // Indicates the FIFO is fullo (driven at the rising edge of wclki)
   output          emptyo;       // Indicates the FIFO is emptyo (driven at the rising edge of rclki)
   input  [DW-1:0] wdatai;
   output [DW-1:0] rdatao;


   // Local Wires & Regi
   wire          we;
   wire          re;
   reg           wflag;
   reg           wflag_1d;
   reg           wflag_2d;
   reg           rflag;
   reg           rflag_1d;
   reg           rflag_2d;
   wire          full;
   wire          empty;
   reg [DW-1:0]  mem;

   // write flags logic
   always @(posedge aclri or posedge wclki)
	 if(aclri)
	     mem <= 0;
	 else if(we)
		 mem <= wdatai;

   // write flags logic
   always @(posedge aclri or posedge wclki)
	 if(aclri)
	     wflag <= 0;
	 else if(we)
		 wflag <= !wflag;

   // read flags logic
   always @(posedge aclri or posedge rclki)
	 if(aclri)
    	 rflag <= 0;
	 else if(re)
	     rflag <= !rflag;

   // mask wei using full,mask rei using empty
   assign we = wei && (!full);
   assign re = rei && (!empty);

   // write flag syn 1d
   always @(posedge aclri or posedge rclki)	
      if(aclri)
         wflag_1d <=0;
      else    
    	 wflag_1d <= wflag;

   // write flag syn 2d
   always @(posedge aclri or posedge rclki)	
      if(aclri)
         wflag_2d <= 0;
      else    
         wflag_2d <= wflag_1d;

   // read flag syn 1d
   always @(posedge aclri or posedge wclki)	
      if(aclri)
         rflag_1d <=0;
      else    
    	 rflag_1d <= rflag;

   // read flag syn 2d
   always @(posedge aclri or posedge wclki)	
      if(aclri)
         rflag_2d <= 0;
      else    
         rflag_2d <= rflag_1d;

   //generate full && empty
   assign full  = (wflag != rflag_2d);
   assign empty = (rflag == wflag_2d);

   //output
   assign rdatao = mem;    
   assign fullo = full;
   assign emptyo = empty;

  endmodule
