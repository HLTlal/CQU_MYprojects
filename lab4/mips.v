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
	output wire [3:0] memwriteM,
	output wire [31:0] pcW,resultW,
	output wire [4:0] writeregW,
	output wire regwriteW
    );
	
	//decode stage
	wire [5:0] opD,functD;
	wire [4:0] rtD;
	wire pcsrcD,branchD,jumpD,jalD,jrD,balD,equalD,breakD,syscallD,reserveD,eretD;
	wire [5:0] alucontrolD;
	wire [31:0] instrD;
	//execute stage	
	wire flushE;	
	wire regdstE,alusrcE,hilo_enE,jumpE,jalE,jrE,balE,
	memtoregE,regwriteE;
	wire [5:0] alucontrolE;
	//mem stage
	wire memtoregM,regwriteM,mtc0_weM,mfc0M;
	//writeback stage
	wire memtoregW;

	controller c(
		clk,rst,
		//decode stage
		stallD,
		opD,functD,
		rtD,equalD,
		pcsrcD,branchD,jumpD,jalD,jrD,balD,breakD,syscallD,reserveD,eretD,
		alucontrolD,instrD,
		
		//execute stage
		flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	hilo_enE,
		jumpE,jalE,jrE,balE,
		alucontrolE,

		//mem stage
		flushM,
		memtoregM,
		regwriteM,mtc0_weM,mfc0M,
		//write back stage
		flushW,
		memtoregW,regwriteW
		);
	datapath dp(
		clk,rst,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,jalD,jrD,balD,breakD,syscallD,reserveD,eretD,
		alucontrolD,
		equalD,stallD,
		opD,functD,rtD,instrD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,hilo_enE,
		alucontrolE,
		jumpE,jalE,jrE,balE,
		flushE,stallE,
		//mem stage
		memtoregM,
		regwriteM,mtc0_weM,mfc0M,
		aluoutM,writedataM,
		readdataM,memwriteM,flushM,
		//writeback stage
		memtoregW,
		regwriteW,flushW,
		pcW,resultW,writeregW
	    );
	
endmodule
