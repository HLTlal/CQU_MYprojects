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

	output wire memtoreg,memwrite,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,
	output wire hilo_en
    );
	reg[20:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,hilo_en} = controls;
	
	always @(*) begin
		case (op)
			//I-type
			//Logic
			`ANDI:controls <= 20'b10100000;//ANDI
			`ORI:controls <= 20'b10100000;//ORI
			`XORI:controls <= 20'b10100000;//XORI
			`LUI:controls <= 20'b10100000;//LUI
            //Arithmetic
            `ADDI:controls <= 20'b10100000;//ADDI
            `ADDIU:controls <= 20'b10100000;//ADDIU
            `SLTI:controls <= 20'b10100000;//SLTI
            `SLTIU:controls <= 20'b10100000;//SLTIU
            //J
            `J:controls <= 20'b00000010;//J
            `JAL:controls <= 20'b11000000;//JAL
            `BEQ:controls <= 20'b00010001;//BEQ
            `BGTZ:controls <= 20'b11000000;//BGTZ
            `BLEZ:controls <= 20'b11000000;//BLEZ
            `BNE:controls <= 20'b11000000;//BNE
            `REGIMM_INST:case(rt)
                    `BLTZ:controls <= 20'b11000000;//BLTZ
                    `BLTZAL:controls <= 20'b11000000;//BLTZAL
                    `BGEZ:controls <= 20'b11000000;//BGEZ
                    `BGEZAL:controls <= 20'b11000000;//BGEZAL   
                    default:controls <= 20'b0;     
             endcase                    
             `LB:controls <= 20'b10100000;//LB
             `LBU:controls <= 20'b10100000;//LBU
             `LH:controls <= 20'b10100000;//LH
             `LHU:controls <= 20'b10100000;//LHU
             `LW:controls <= 20'b10100100;//LW
             `SB:controls <= 20'b00100000;//SB
             `SH:controls <= 20'b00100000;//SH
             `SW:controls <= 20'b00101000;//SW

             `NOP:case(funct)
                    //HILO
                    `MFHI:controls <= 20'b11101000;//MFHI
                    `MFLO:controls <= 20'b11101000;//MFLO                  
                    `MTHI:controls <= 20'b00101001;//MTHI
                    `MTLO:controls <= 20'b00101001;//MTLO
                    //Arithmetic
                    `MULT:controls <= 20'b00101001;//MULT
                    `MULTU:controls <= 20'b00101001;//MULTU
                    `DIV:controls <= 20'b00101001;//DIV
                    `DIVU:controls <= 20'b00101001;//DIVU
                    //J
                    `JALR:controls <= 20'b00101000;//JALR
                    `JR:controls <= 20'b00101000;//JR
			        default:controls <= 20'b11000000;//R-TYPE     
             endcase 
			default:  controls <= 20'b00000000;//illegal op
		endcase
	end
endmodule
