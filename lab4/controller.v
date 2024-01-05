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
	input wire[4:0] rtD,
	input wire equalD,
	output wire pcsrcD,branchD,jumpD,jalD,jrD,balD,
	output wire[5:0] alucontrolD,
	//execute stage
	input wire flushE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,hilo_enE,jumpE,jalE,jrE,balE,
	output wire[5:0] alucontrolE,

	//mem stage
	output wire memtoregM,
				regwriteM,
	//write back stage
	output wire memtoregW,regwriteW

    );
	
	//decode stage
	wire memtoregD,alusrcD,
		regdstD,regwriteD,hilo_enD;

	//mem stage
	wire hilo_enM;

	maindec md(
		opD,functD,rtD,
		memtoregD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,jalD,jrD,balD,
		hilo_enD
		);
    aludec ad(functD,opD,rtD,alucontrolD);
    
	assign pcsrcD = branchD & equalD;

	//pipeline registers
	floprc #(15) regE(
		clk,
		rst,
		flushE,
		{memtoregD,alusrcD,regdstD,regwriteD,hilo_enD,jumpD,jalD,jrD,balD,alucontrolD},
		{memtoregE,alusrcE,regdstE,regwriteE,hilo_enE,jumpE,jalE,jrE,balE,alucontrolE}
		);
	flopr #(3) regM(
		clk,rst,
		{memtoregE,regwriteE,hilo_enE},
		{memtoregM,regwriteM,hilo_enM}
		);
	flopr #(2) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
		);
endmodule
