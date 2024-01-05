`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	output wire [3:0] memwriteM
    );
	
	//decode stage
	wire [5:0] opD,functD,rtD;
	wire pcsrcD,branchD,jumpD,jalD,jrD,balD,equalD;
	wire [5:0] alucontrolD;
	//execute stage	
	wire flushE;	
	wire regdstE,alusrcE,hilo_enE,jumpE,jalE,jrE,balE,
	memtoregE,regwriteE;
	wire [5:0] alucontrolE;
	//mem stage
	wire memtoregM,regwriteM;
	//writeback stage
	wire memtoregW,regwriteW;

	controller c(
		clk,rst,
		//decode stage
		opD,functD,
		rtD,equalD,
		pcsrcD,branchD,jumpD,jalD,jrD,balD,
		alucontrolD,
		
		//execute stage
		flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	hilo_enE,
		jumpE,jalE,jrE,balE,
		alucontrolE,

		//mem stage
		memtoregM,
		regwriteM,
		//write back stage
		memtoregW,regwriteW
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,jalD,jrD,balD,
		alucontrolD,
		equalD,
		opD,functD,rtD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,hilo_enE,
		alucontrolE,
		jumpE,jalE,jrE,balE,
		flushE,
		//mem stage
		memtoregM,
		regwriteM,
		aluoutM,writedataM,
		readdataM,memwriteM,
		//writeback stage
		memtoregW,
		regwriteW
	    );
	
endmodule
