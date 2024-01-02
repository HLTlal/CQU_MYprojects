`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
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

`include "defines2.vh"
module aludec(
	input wire[5:0] funct,
	input wire[5:0] aluop,
	input wire[4:0] rt,
	output reg[7:0] alucontrol
    );
	always @(*) begin
		case (aluop)
		    //test
		    //`RELU: alucontrol<=`RELU_OP;
		    
			//logic
			`ANDI: alucontrol<=`AND_CONTROL;
			`XORI: alucontrol<=`XOR_CONTROL;
			`LUI: alucontrol<=`LUI_CONTROL;
			`ORI: alucontrol<=`OR_CONTROL;
			
			//shift
			//move
			//arithmetic
			`ADDI: alucontrol<=`ADD_CONTROL;
			`ADDIU: alucontrol<=`ADDU_CONTROL;
			`SLTI: alucontrol<=`SLT_CONTROL;
			`SLTIU: alucontrol<=`SLTU_CONTROL;
/*			
			//jump
			`J: alucontrol<=`J_OP;
			`JAL: alucontrol<=`JAL_OP;
			//branch
			`BEQ: alucontrol<=`BEQ_OP;
			`BGTZ: alucontrol<=`BGTZ_OP;
			`BLEZ: alucontrol<=`BLEZ_OP;
			`BNE: alucontrol<=`BEN_OP;
			`B_ADDITION: case(rt)
			    `BLTZ: alucontrol<=`BLTZ_OP;
			    `BLTZAL: alucontrol<=`BLTZAL_OP;
			    `BGEZ: alucontrol<=`BGEZ_OP;
			    `BGEZAL: alucontrol<=`BGEZAL_OP;
			    default: alucontrol <= `NOP_OP;
			endcase
*/			    
			//memory
			`LB: alucontrol<=`MEM_CONTROL;
			`LBU: alucontrol<=`MEM_CONTROL;
			`LH: alucontrol<=`MEM_CONTROL;
			`LHU: alucontrol<=`MEM_CONTROL;
			`LW: alucontrol<=`MEM_CONTROL;
			`SB: alucontrol<=`MEM_CONTROL;
			`SH: alucontrol<=`MEM_CONTROL;
			`SW: alucontrol<=`MEM_CONTROL;
			
			//Invagination
			//privilege
			
			`NOP: case(funct)
			    //logic
			    `AND: alucontrol<= `AND_CONTROL;
                `OR: alucontrol<= `OR_CONTROL;
                `XOR: alucontrol<= `XOR_CONTROL;
                `NOR: alucontrol<= `NOR_CONTROL;
                
			    //shift
			    `SLL: alucontrol<= `SLL_CONTROL;
                `SRL: alucontrol<= `SRL_CONTROL;
                `SRA: alucontrol<= `SRA_CONTROL;
                `SLLV: alucontrol<= `SLLV_CONTROL;
                `SRLV: alucontrol<= `SRLV_CONTROL;
                `SRAV: alucontrol<= `SRAV_CONTROL;
                
			    //move
			    `MFHI: alucontrol<= `MFHI_CONTROL;
                `MFLO: alucontrol<= `MFLO_CONTROL;
                `MTHI: alucontrol<= `MTHI_CONTROL;
                `MTLO: alucontrol<= `MTLO_CONTROL;
                
			    //arithemetic
			    `ADD: alucontrol <= `ADD_CONTROL;
                `ADDU: alucontrol<= `ADDU_CONTROL;
                `SUB: alucontrol <= `SUB_CONTROL;
                `SUBU: alucontrol <= `SUBU_CONTROL;
                `SLT: alucontrol <= `SLT_CONTROL;
                `SLTU:alucontrol <= `SLTU_CONTROL;
                `MULT:alucontrol <= `MULT_CONTROL;
                `MULTU: alucontrol <= `MULTU_CONTROL;
                `DIV: alucontrol <= `DIV_CONTROL;
                `DIVU: alucontrol <= `DIVU_CONTROL;
/*			    
			    //jump
			    `JR: alucontrol <= `JR_OP;
                `JALR: alucontrol <= `JALR_OP;
*/                
			    //Invagination
			    //privilege
			    
			    default: alucontrol <= `NOP_CONTROL;
			endcase
			default: alucontrol <= `NOP_CONTROL;
		endcase
	end
endmodule
