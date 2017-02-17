//////////////////////////////////////////////////////////////////////////////////
//Filename: MAIN.v
//Author: Wenzhengxing
//Description: Scan dynamicly and show on screen
//Called by: None
//Revision History: 2015-08-17
//Revision: 0.1
//Email: 1308950671@qq.com
//Company: None
//Copyright(c) 2015, Person, All right reserved 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

`include "DYNAMIC_SCAN.v"
`include "FDIVISION.v"
`include "TRAFFIC.v"

module MAIN(CLK, ONLINE, RST, SET, Cm, Cc, PQm, PQc, BUSY,
            MR, MY, MG, CR, CY, CG, DS_OUT, DS_FLAG, ONLINELED);
				
    input CLK, ONLINE, RST, SET, Cm, Cc, PQm, PQc, BUSY;
	 output MR, MY, MG, CR, CY, CG, ONLINELED;
	 output [7:0] DS_OUT;
	 output [3:0] DS_FLAG; 
   
	 wire clk1, clk2, clk3;
	 wire [3:0] MOUTH, MOUTL, COUTH, COUTL;
	 
    FDIVISION FDI(.CLK(CLK), .DS_CLK(clk2), .COU_CLK(clk1), .SH_CLK(clk3));
	 
	 DYNAMIC_SCAN SCAN(.DS_CLK(clk2), .DS_IN3(MOUTH), .DS_IN2(MOUTL), 
	                   .DS_IN1(COUTH), .DS_IN0(COUTL), .DS_OUT(DS_OUT), 
							 .DS_FLAG(DS_FLAG));
							 
	 TRAFFIC TRA(.CLK(clk1), .FLK_CLK(clk3), .ONLINE(ONLINE), 
	             .RST(RST), .SET(SET),
              	 .Cm(Cm), .Cc(Cc) , .PQm(PQm), .PQc(PQc), .BUSY(BUSY),
	             .MR(MR), .MY(MY), .MG(MG), .CR(CR), .CY(CY), .CG(CG),
					 .MCOUTH(MOUTH), .MCOUTL(MOUTL), .CCOUTH(COUTH), 
					 .CCOUTL(COUTL), .ONLINELED(ONLINELED));
endmodule
