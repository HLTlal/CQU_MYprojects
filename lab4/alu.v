`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
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

module alu(//ex.v
	input wire[31:0] a,b,
	input wire[4:0] alucontrol,
	input wire[4:0] sa,
	input [31:0] hi_in,lo_in,
    output reg [31:0] hi_out,lo_out,
	output reg[31:0] y,
	output reg overflow
    );
    
    wire mul_sign;
    wire [63:0] mul_res;
    assign mul_sign=(alucontrol == `MULT_CONTROL);
    mul alumul(
    .a(a),
    .b(b),
    .sign(mul_sign),
    .result(mul_res)
);
    
	always @(*) begin
		case (alucontrol)
			//Logic
			`AND_CONTROL: begin y<= a & b;   overflow <= 0; end  //and
            `OR_CONTROL: begin y<= a | b;   overflow <= 0; end  //or
            `XOR_CONTROL: begin y<= a ^ b;   overflow <= 0; end  //xor
            `NOR_CONTROL: begin y<= ~(a|b);   overflow <= 0; end  //nor
            `LUI_CONTROL: begin y<= { b[15:0],16'b0 };   overflow <= 0; end  //lui
            //Move
            `SLL_CONTROL: begin y<= b<<sa;   overflow <= 0; end  //sll
            `SRL_CONTROL: begin y<= b>>sa;   overflow <= 0; end  //srl
            `SRA_CONTROL: begin y<= ({32{b[31]}} << (6'd32 -{1'b0,sa})) | (b >> sa);   
                    overflow <= 0; end  //sra
            `SLLV_CONTROL: begin y<= b << a[4:0];   overflow <= 0; end  //sllv
            `SRLV_CONTROL: begin y<= b >> a[4:0];   overflow <= 0; end  //srlv
            `SRAV_CONTROL: begin y<= ({32{b[31]}} << (6'd32 -{1'b0,a[4:0]})) | (b >> a[4:0]);   
                    overflow <= 0; end  //srav
            //Arithmetic
            `ADD_CONTROL: begin y= a+b;   
                    overflow = (a[31] & b[31] & ~y[31] )|(~a[31] & ~b[31] & y[31]); end  //add
            `ADDU_CONTROL: y= a+b; //addu
            `SUB_CONTROL: begin y= a-b;   
                    overflow =( ~a[31] & b[31] & y[31]) |(a[31] & ~b[31] & ~y[31]); end  //sub
            `SUBU_CONTROL:  y= a-b;  //subu
            `SLT_CONTROL: begin y<= $signed(a) < $signed(b);   
                    overflow <= 0; end  //slt
            `SLTU_CONTROL: begin y<= a<b;   overflow <= 0; end  //stlu
            
//            `DIV_CONTROL: begin y<= a<b;   overflow <= 0; end  //sll
//            `DIVU_CONTROL: begin y<= a<b;   overflow <= 0; end  //sll
            //move
            `MFHI_CONTROL :begin y<=hi_in[31:0];  overflow <= 0; end //mfhi
            `MFLO_CONTROL:begin y<=lo_in[31:0];  overflow <= 0; end //mflo
            `MTHI_CONTROL :begin hi_out<={a, lo_in[31:0]};  overflow <= 0; end //mthi
            `MTLO_CONTROL:begin lo_out<={hi_in[31:0], a};  overflow <= 0; end //mtlo
//            `MFC0_CONTROL
//            `MTC0_CONTROL 
            
			default : begin y <= 32'h0; overflow <= 0; hi_out <= 0; lo_out<=0;end
		endcase	
	end
endmodule
