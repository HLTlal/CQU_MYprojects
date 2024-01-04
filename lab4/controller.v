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
	input wire[5:0] opD,functD,
	input wire[4:0] rtD,equalD,
	output wire pcsrcD,branchD,jumpD,jalD,jrD,balD,
	
	//execute stage
	input wire flushE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	hilo_enE,jumpE,jalE,jrE,balE,
	output wire[4:0] alucontrolE,

	//mem stage
	output wire memtoregM,memwriteM,
				regwriteM,
	//write back stage
	output wire memtoregW,regwriteW

    );
	
	//decode stage
	wire[1:0] aluopD;
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD;
	wire[4:0] alucontrolD;

	//execute stage
	wire memwriteE,hilo_enM;

	maindec md(
		opD,functD,rtD,
		memtoregD,memwriteD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,jalD,jrD,balD,
		hilo_enD
		);
    aludec ad(functD,aluopD,rtD,alucontrolD);
    
	assign pcsrcD = branchD & equalD;

	//pipeline registers
	floprc #(8) regE(
		clk,
		rst,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,hilo_enD,jumpD,jalD,jrD,balD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,hilo_enE,jumpE,jalE,jrE,balE,alucontrolE}
		);
	flopr #(8) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE,hilo_enE},
		{memtoregM,memwriteM,regwriteM,hilo_enM}
		);
	flopr #(8) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
