`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire stallD,
	input wire[5:0] opD,functD,
	input wire[4:0] rtD,
	input wire equalD,
	output wire pcsrcD,branchD,jumpD,jalD,jrD,balD,breakD,syscallD,reserveD,eretD,
	output wire[5:0] alucontrolD,
	input wire [31:0] instrD,
	//execute stage
	input wire flushE,
	output wire memtoregE,memrenE,memwenE,alusrcE,
	output wire regdstE,regwriteE,hilo_enE,jumpE,jalE,jrE,balE,
	output wire[5:0] alucontrolE,

	//mem stage
	input wire flushM,
	output wire memtoregM,regwriteM,mtc0_weM,mfc0M,
	//write back stage
	input wire flushW,
	output wire memtoregW,regwriteW

    );
	
	//decode stage
	wire memtoregD,memrenD,memwenD,alusrcD,
		regdstD,regwriteD,hilo_enD,mtc0_weD,mfc0D;
    //execute stage
    wire mtc0_weE,mfc0E;

	maindec md(
		opD,functD,rtD,instrD,
		memtoregD,memrenD,memwenD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,jalD,jrD,balD,
		hilo_enD,breakD,syscallD,reserveD,eretD,mtc0_weD,mfc0D
		);
    aludec ad(functD,opD,rtD,alucontrolD);
    
	assign pcsrcD = branchD & equalD;

	//pipeline registers
	flopenrc #(18) regE(
		clk,
		rst,
		~stallD,flushE,
		{memtoregD,memrenD,memwenD,alusrcD,regdstD,regwriteD,jumpD,jalD,jrD,balD,alucontrolD,mtc0_weD,mfc0D},
		{memtoregE,memrenE,memwenE,alusrcE,regdstE,regwriteE,jumpE,jalE,jrE,balE,alucontrolE,mtc0_weE,mfc0E}
		);
	flopr #(1) reghilo(clk,rst,hilo_enD,hilo_enE);
	floprc #(4) regM(
		clk,rst,flushM,
		{memtoregE,regwriteE,mtc0_weE,mfc0E},
		{memtoregM,regwriteM,mtc0_weM,mfc0M}
		);
	floprc #(2) regW(
		clk,rst,flushW,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
