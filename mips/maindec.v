`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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

module maindec(//id.v
	input wire[5:0] op,
	input wire[5:0] funct,
	input wire[4:0] rt,
	input wire [31:0] instrD,

	output wire memtoreg,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,jal,jr,bal,
	output wire hilo_en,breakM,syscall,reserve,eret,mtc0_we,mfc0
    );
	reg[15:0] controls;
	assign {regwrite,regdst,alusrc,branch,memtoreg,jump,jal,jr,bal,hilo_en,breakM,syscall,reserve,eret,mtc0_we,mfc0} = controls;
	
	always @(*) begin
		case (op)
			//I-type
			//Logic
			`ANDI:controls <= 16'b1010000000000000;//ANDI
			`ORI:controls <= 16'b1010000000000000;//ORI
			`XORI:controls <= 16'b1010000000000000;//XORI
			`LUI:controls <= 16'b1010000000000000;//LUI
            //Arithmetic
            `ADDI:controls <= 16'b1010000000000000;//ADDI
            `ADDIU:controls <= 16'b1010000000000000;//ADDIU
            `SLTI:controls <= 16'b1010000000000000;//SLTI
            `SLTIU:controls <= 16'b1010000000000000;//SLTIU
            //J
            `J:controls <= 16'b0000010000000000;//J
            `JAL:controls <= 16'b1000001000000000;//JAL
            `BEQ:controls <= 16'b0001000000000000;//BEQ
            `BGTZ:controls <= 16'b0001000000000000;//BGTZ
            `BLEZ:controls <= 16'b0001000000000000;//BLEZ
            `BNE:controls <= 16'b0001000000000000;//BNE
            `REGIMM_INST:case(rt)
                    `BLTZ:controls <= 16'b0001000000000000;//BLTZ
                    `BLTZAL:controls <= 16'b1001000010000000;//BLTZAL
                    `BGEZ:controls <= 16'b0001000000000000;//BGEZ
                    `BGEZAL:controls <= 16'b1001000010000000;//BGEZAL   
                    default:controls <= 16'b0;     
             endcase                    
             `LB:controls <= 16'b1010100000000000;//LB
             `LBU:controls <= 16'b1010100000000000;//LBU
             `LH:controls <= 16'b1010100000000000;//LH
             `LHU:controls <= 16'b1010100000000000;//LHU
             `LW:controls <= 16'b1010100000000000;//LW
             `SB:controls <= 16'b0010000000000000;//SB
             `SH:controls <= 16'b0010000000000000;//SH
             `SW:controls <= 16'b0010000000000000;//SW

             `NOP:case(funct)
                    //HILO
                    `MFHI:controls <= 16'b1100000000000000;//MFHI
                    `MFLO:controls <= 16'b1100000000000000;//MFLO                  
                    `MTHI:controls <= 16'b0000000001000000;//MTHI
                    `MTLO:controls <= 16'b0000000001000000;//MTLO
                    //Arithmetic
                    `MULT:controls <= 16'b0000000001000000;//MULT
                    `MULTU:controls <= 16'b0000000001000000;//MULTU
                    `DIV:controls <= 16'b0000000001000000;//DIV
                    `DIVU:controls <= 16'b0000000001000000;//DIVU
                    //J
                    `JALR:controls <= 16'b1100000100000000;//JALR
                    `JR:controls <= 16'b0000000100000000;//JR
                    //breakM and syscall
                    `SYSCALL :controls <= 16'b0000000000010000;//syscall
                    `breakM :controls <= 16'b0000000000100000;//breakM
			        default:controls <= 16'b1100000000000000;//R-TYPE     
             endcase 
             `SPECIAL3_INST: begin
                    if(instrD==`ERET)
                            controls <= 16'b0000000000000100;//eret
                    else if (instrD[25:21]==5'b00100 && instrD[10:3]==8'b00000000)
                            controls <= 16'b0000000000000010;//mtc0
                    else if (instrD[25:21]==5'b00000 && instrD[10:3]==8'b00000000)
                            controls <= 16'b1000000000000001;//mfc0
             end
			default:  controls <= 16'b00000000001000;//illegal op
		endcase
	end
endmodule
