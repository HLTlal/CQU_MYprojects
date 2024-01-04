`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/23 22:57:01
// Design Name: 
// Module Name: eqcmp
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
module eqcmp(
	input wire [31:0] a,b,
	input wire[5:0] alucontrolD,
	output reg y
    );
    always@ (*) begin
        case (alucontrolD)
            `BEQ_CONTROL: y=(a==b) ?1:0;
            `BGTZ_CONTROL: y=((a[31]==0) && (a!=32'b0)) ? 1:0;
            `BLEZ_CONTROL: y=((a[31]==1) || (a==32'b0)) ? 1:0;
            `BNE_CONTROL: y=(a!=b) ?1:0;
            `BLTZ_CONTROL: y=(a[31]==1) ? 1:0;
            `BLTZAL_CONTROL: y=(a[31]==1) ? 1:0;
            `BGEZ_CONTROL: y=(a[31]==0) ? 1:0;
            `BGEZAL_CONTROL: y=(a[31]==0) ? 1:0;                  
        endcase
    end
endmodule
