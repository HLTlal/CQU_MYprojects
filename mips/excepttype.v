`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/07 18:35:30
// Design Name: 
// Module Name: excepttype
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


module excepttype(
    input rst,
	input [31:0] pcM,
	input [6:0] exceptM,
	input wire[31:0] cp0_status,cp0_cause,aluoutM,
	output reg [31:0] excepttype,bad_addr
    );
    //eret e,sys8,break9,re a,ov c,s5,l4
    always @(*) begin
		if(rst) begin
		      excepttype <= 32'h00000000;
		      bad_addr<=32'h00000000;
		end else begin
			if((cp0_cause[15:8] & cp0_status[15:8]) != 8'h00 && cp0_status[1] == 1'b0 && cp0_status[0] == 1'b1) begin
				excepttype <= 32'h00000001;
				bad_addr<=32'h00000000;
			end else if(pcM[1:0]!=2'b00)	begin 
				excepttype <= 32'h00000004;
				bad_addr <= pcM;
			end else if(exceptM[6]) begin//adel
				excepttype <= 32'h00000004;
				bad_addr <= aluoutM;
			end
			else if(exceptM[0])	excepttype <= 32'h0000000e;//eret
			else if(exceptM[1])	excepttype <= 32'h00000008;//sys
			else if(exceptM[2])	excepttype <= 32'h00000009;//breakM
			else if(exceptM[3])	excepttype <= 32'h0000000a;//re
			else if(exceptM[4])	excepttype <= 32'h0000000c;//ov
			else if(exceptM[5]) begin //ades
				excepttype <= 32'h00000005;
				bad_addr<=aluoutM;
			end else	
			excepttype <= 32'h00000000;
			bad_addr<=32'h00000000;
		end
	end
endmodule
