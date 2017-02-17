//////////////////////////////////////////////////////////////////////////////////
//Filename: DECODE7.v
//Author: Hekun
//Description: Module of Seven-Segment Decoder
//Called by: DYNAMIC_SCAN.v
//Revision History: 2015-08-15
//Revision: 0.1
//Email:  541826030@qq.com
//Company: None
// Copyright(c) 2015, Person, All right reserved 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module DECODE7(D7_IN, D7_OUT);
	input[3:0] D7_IN;            //input-data
	output[7:0] D7_OUT;          //output-signal
	reg[7:0] D7_OUT;
	
	always @(D7_IN) begin
		case(D7_IN)		
		4'b0000:D7_OUT <= 8'b00000011;
		4'b0001:D7_OUT <= 8'b10011111;
		4'b0010:D7_OUT <= 8'b00100101;
		4'b0011:D7_OUT <= 8'b00001101;
		4'b0100:D7_OUT <= 8'b10011001;
		4'b0101:D7_OUT <= 8'b01001001;
		4'b0110:D7_OUT <= 8'b01000001;
		4'b0111:D7_OUT <= 8'b00011011;
		4'b1000:D7_OUT <= 8'b00000001;
		4'b1001:D7_OUT <= 8'b00001001;
		default: D7_OUT <= 8'b00000011;
		endcase
	end
endmodule
