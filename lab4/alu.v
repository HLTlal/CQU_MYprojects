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
	input wire[5:0] alucontrol,
	input wire[4:0] sa,
	input [31:0] hi_in,lo_in,
    output reg [31:0] hi_out,lo_out,
	output reg[31:0] y,
	output reg overflow
    );
    reg [63:0] y_temp;
    //减法与有符号数的补码加法
    wire [31:0]b_co;             //b的补码
    wire overflow_temp;
    wire slt_out;
    wire [31:0]y_sum;
    assign b_co=((alucontrol==`SUB_CONTROL)||
                            (alucontrol==`SUBU_CONTROL)||
                            (alucontrol==`SLT_CONTROL))? ((~b)+1) : b;
    assign y_sum=a+b_co;
    assign overflow_temp=( (~a[31]) & (~b_co[31]) & y_sum[31] )|
                                            ( a[31] & b_co[31] & (~y_sum[31]) );
    assign slt_out=(alucontrol==`SLT_CONTROL)?
                              ( (a[31] & (~b[31]) ) |//a是负数1，b是正数0，小于
                              ( (~a[31]) & (~b[31]) & y_sum[31] ) |//ab都是正数0，但a-b为负数，小于
                               (a[31] & b[31] & y_sum[31]) ) : (a<b);
    
    //有符号与无符号乘法                                                                
    wire mul_sign;
    wire [63:0] hilo_temp;
    assign mul_sign=(alucontrol == `MULT_CONTROL) ?1:0;
    mul alumul(
    .a(a),
    .b(b),
    .sign(mul_sign),
    .result(hilo_temp)
);
    
	always @(*) begin
	   y=32'b0;               //赋初值
	   hi_out=32'b0;
	   lo_out=32'b0;
	   overflow=0;
	   
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
            `SRA_CONTROL: begin y_temp={ {32{b[31]}},b[31:0]} >> sa; 
                                         y=y_temp[31:0];   overflow = 0; end  //sra
            `SLLV_CONTROL: begin y<= b << a[4:0];   overflow <= 0; end  //sllv
            `SRLV_CONTROL: begin y<= b >> a[4:0];   overflow <= 0; end  //srlv
            `SRAV_CONTROL: begin y_temp= { {32{b[31]}},b[31:0]} >> a[4:0];  
                                          y=y_temp[31:0];   overflow = 0; end  //srav
            //Arithmetic
            `ADD_CONTROL: begin y= y_sum;    overflow =overflow_temp; end  //add 有溢出例外
            `ADDU_CONTROL: y= y_sum; //addu
            `SUB_CONTROL: begin y= y_sum;    overflow =overflow_temp; end  //sub 有溢出例外
            `SUBU_CONTROL:  y= y_sum;  //subu
            `SLT_CONTROL: begin y<={31'd0,slt_out} ;  overflow <= 0; end  //slt
            `SLTU_CONTROL: begin y<={31'd0,slt_out};  overflow <= 0; end  //stlu
            `MULT_CONTROL:begin hi_out<=hilo_temp[63:32]; lo_out<=hilo_temp[31:0]; overflow <= 0; end
            `MULTU_CONTROL :begin hi_out<=hilo_temp[63:32]; lo_out<=hilo_temp[31:0]; overflow <= 0; end
//            `DIV_CONTROL: begin y<= a<b;   overflow <= 0; end  //sll
//            `DIVU_CONTROL: begin y<= a<b;   overflow <= 0; end  //sll
            //move
            `MFHI_CONTROL :begin y<=hi_in[31:0];  overflow <= 0; end //mfhi
            `MFLO_CONTROL:begin y<=lo_in[31:0];  overflow <= 0; end //mflo
            `MTHI_CONTROL :begin hi_out<=a; lo_out<=lo_in[31:0]; overflow <= 0; end //mthi
            `MTLO_CONTROL:begin lo_out<=a; hi_out<=hi_in[31:0];  overflow <= 0; end //mtlo
            `LB_CONTROL: y= y_sum;
			`LBU_CONTROL: y= y_sum;
			`LH_CONTROL: y= y_sum;
			`LHU_CONTROL: y= y_sum;
			`LW_CONTROL: y= y_sum;
			`SB_CONTROL: y= y_sum;
			`SH_CONTROL: y= y_sum;
			`SW_CONTROL: y= y_sum;
//            `MFC0_CONTROL
//            `MTC0_CONTROL 
            
			default : begin y <= 32'h0; overflow <= 0; hi_out <= hi_in[31:0]; lo_out<=lo_in[31:0];end
		endcase	
	end
endmodule
