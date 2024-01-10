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

	output wire memtoreg,memren,memwen,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,jal,jr,bal,
	output wire hilo_en,breakM,syscall,reserve,eret,mtc0_we,mfc0
    );
	reg[17:0] controls;
	assign {regwrite,regdst,alusrc,branch,memtoreg,memren,memwen,jump,jal,jr,bal,hilo_en,breakM,syscall,reserve,eret,mtc0_we,mfc0} = controls;
	
	always @(*) begin
		case (op)
			//I-type
			//Logic
			`ANDI:controls <= 18'b101000000000000000;//ANDI
			`ORI:controls <= 18'b101000000000000000;//ORI
			`XORI:controls <= 18'b101000000000000000;//XORI
			`LUI:controls <= 18'b101000000000000000;//LUI
            //Arithmetic
            `ADDI:controls <= 18'b101000000000000000;//ADDI
            `ADDIU:controls <= 18'b101000000000000000;//ADDIU
            `SLTI:controls <= 18'b101000000000000000;//SLTI
            `SLTIU:controls <= 18'b101000000000000000;//SLTIU
            //J
            `J:controls <= 18'b000000010000000000;//J
            `JAL:controls <= 18'b100000001000000000;//JAL
            `BEQ:controls <= 18'b000100000000000000;//BEQ
            `BGTZ:controls <= 18'b000100000000000000;//BGTZ
            `BLEZ:controls <= 18'b000100000000000000;//BLEZ
            `BNE:controls <= 18'b000100000000000000;//BNE
            `REGIMM_INST:case(rt)
                    `BLTZ:controls <= 18'b000100000000000000;//BLTZ
                    `BLTZAL:controls <= 18'b100100000010000000;//BLTZAL
                    `BGEZ:controls <= 18'b000100000000000000;//BGEZ
                    `BGEZAL:controls <= 18'b100100000010000000;//BGEZAL   
                    default:controls <= 18'b0;     
             endcase                    
             `LB:controls <= 18'b101011000000000000;//LB
             `LBU:controls <= 18'b101011000000000000;//LBU
             `LH:controls <= 18'b101011000000000000;//LH
             `LHU:controls <= 18'b101011000000000000;//LHU
             `LW:controls <= 18'b101011000000000000;//LW
             `SB:controls <= 18'b001000100000000000;//SB
             `SH:controls <= 18'b001000100000000000;//SH
             `SW:controls <= 18'b001000100000000000;//SW

             `NOP:case(funct)
                    //HILO
                    `MFHI:controls <= 18'b110000000000000000;//MFHI
                    `MFLO:controls <= 18'b110000000000000000;//MFLO                  
                    `MTHI:controls <= 18'b000000000001000000;//MTHI
                    `MTLO:controls <= 18'b000000000001000000;//MTLO
                    //Arithmetic
                    `MULT:controls <= 18'b000000000001000000;//MULT
                    `MULTU:controls <= 18'b000000000001000000;//MULTU
                    `DIV:controls <= 18'b000000000001000000;//DIV
                    `DIVU:controls <= 18'b000000000001000000;//DIVU
                    //J
                    `JALR:controls <= 18'b110000000100000000;//JALR
                    `JR:controls <= 18'b000000000100000000;//JR
                    //breakM and syscall
                    `SYSCALL :controls <= 18'b000000000000010000;//syscall
                    `breakM :controls <= 18'b000000000000100000;//breakM
			        default:controls <= 18'b110000000000000000;//R-TYPE     
             endcase 
             `SPECIAL3_INST: begin
                    if(instrD==`ERET)
                            controls <= 18'b000000000000000100;//eret
                    else if (instrD[25:21]==5'b00100 && instrD[10:3]==8'b00000000)
                            controls <= 18'b000000000000000010;//mtc0
                    else if (instrD[25:21]==5'b00000 && instrD[10:3]==8'b00000000)
                            controls <= 18'b100000000000000001;//mfc0
             end
			default:  controls <= 18'b0000000000001000;//illegal op
		endcase
	end
endmodule
