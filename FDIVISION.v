//////////////////////////////////////////////////////////////////////////////////
//Filename: FDIVISION.v
//Author: Hekun
//Description: Divide the clock of the system
//Called by: MAIN.v
//Revision History: 2015-08-15
//Revision: 0.1
//Email: 541826030@qq.com
//Company: None
// Copyright(c) 2015, Person, All right reserved 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module FDIVISION(CLK, DS_CLK, COU_CLK, SH_CLK);
    input CLK;               //system clock
	 output DS_CLK, COU_CLK, SH_CLK;  //scanning and countering clock
    reg DS_CLK = 0, COU_CLK = 0, SH_CLK = 0;
	 
	 reg [24:0] counter1, counter2, counter;  //counter
   
	 //1Hz
	 always @(posedge CLK) begin
        //if (counter1 < 25'd10)     	    //for simulation
	     if (counter1 < 25'd60000000)
		      counter1 <= counter1 + 1;
		  else begin
		      COU_CLK <= ~COU_CLK;
				counter1 <= 0;
		  end
	 end
	 
	 //100Hz
	 always @(posedge CLK) begin
	     //if (counter2 < 25'd1)          //for simulation
	     if (counter2 < 25'd50000)
		      counter2 <= counter2 + 1;
		  else begin
		      DS_CLK <= ~DS_CLK;
				counter2 <= 0;
		  end
	 end
	 
	 //9Hz
	 always @(posedge CLK) begin
	     //if (counter < 25'd2)         //for simulation
	     if (counter < 25'd6000000)
		      counter <= counter + 1;
		  else begin
		      SH_CLK <= ~SH_CLK;
				counter <= 0;
		  end
	 end
		  	 		  
endmodule
