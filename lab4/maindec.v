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

	output wire memtoreg,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,jal,jr,bal,
	output wire hilo_en
    );
	reg[9:0] controls;
	assign {regwrite,regdst,alusrc,branch,memtoreg,jump,jal,jr,bal,hilo_en} = controls;
	
	always @(*) begin
		case (op)
			//I-type
			//Logic
			`ANDI:controls <= 10'b1010000000;//ANDI
			`ORI:controls <= 10'b1010000000;//ORI
			`XORI:controls <= 10'b1010000000;//XORI
			`LUI:controls <= 10'b1010000000;//LUI
            //Arithmetic
            `ADDI:controls <= 10'b1010000000;//ADDI
            `ADDIU:controls <= 10'b1010000000;//ADDIU
            `SLTI:controls <= 10'b1010000000;//SLTI
            `SLTIU:controls <= 10'b1010000000;//SLTIU
            //J
            `J:controls <= 10'b0000010000;//J
            `JAL:controls <= 10'b1000001000;//JAL
            `BEQ:controls <= 10'b0001000000;//BEQ
            `BGTZ:controls <= 10'b0001000000;//BGTZ
            `BLEZ:controls <= 10'b0001000000;//BLEZ
            `BNE:controls <= 10'b0001000000;//BNE
            `REGIMM_INST:case(rt)
                    `BLTZ:controls <= 10'b0001000000;//BLTZ
                    `BLTZAL:controls <= 10'b1001000010;//BLTZAL
                    `BGEZ:controls <= 10'b0001000000;//BGEZ
                    `BGEZAL:controls <= 10'b1001000010;//BGEZAL   
                    default:controls <= 10'b0;     
             endcase                    
             `LB:controls <= 10'b1010100000;//LB
             `LBU:controls <= 10'b1010100000;//LBU
             `LH:controls <= 10'b1010100000;//LH
             `LHU:controls <= 10'b1010100000;//LHU
             `LW:controls <= 10'b1010100000;//LW
             `SB:controls <= 10'b0010000000;//SB
             `SH:controls <= 10'b0010000000;//SH
             `SW:controls <= 10'b0010000000;//SW

             `NOP:case(funct)
                    //HILO
                    `MFHI:controls <= 10'b1100000000;//MFHI
                    `MFLO:controls <= 10'b1100000000;//MFLO                  
                    `MTHI:controls <= 10'b0000000001;//MTHI
                    `MTLO:controls <= 10'b0000000001;//MTLO
                    //Arithmetic
                    `MULT:controls <= 10'b0000000001;//MULT
                    `MULTU:controls <= 10'b0000000001;//MULTU
                    `DIV:controls <= 10'b0000000001;//DIV
                    `DIVU:controls <= 10'b0000000001;//DIVU
                    //J
                    `JALR:controls <= 10'b1100000100;//JALR
                    `JR:controls <= 10'b0000000100;//JR
			        default:controls <= 10'b1100000000;//R-TYPE     
             endcase 
			default:  controls <= 10'b00000000;//illegal op
		endcase
	end
endmodule
