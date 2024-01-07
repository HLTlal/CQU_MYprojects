`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/19 16:39:24
// Design Name: 
// Module Name: swselect
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
module smem(
    input wire saddrerrM,
    input [31:0] addressE,
    input [5:0] alucontrolE,
    output reg [3:0] memwriteE
    );
    always@ (*) begin
    if(saddrerrM) 
         memwriteE <= 4'b0000;
    else begin    
        case(alucontrolE)
            `SB_CONTROL: begin
                case(addressE[1:0])
                    2'b00: memwriteE <= 4'b1000;
                    2'b01: memwriteE <= 4'b0100;
                    2'b10: memwriteE <= 4'b0010;
                    2'b11: memwriteE <= 4'b0001;
//                     2'b11: memwriteE <= 4'b1000;
//                     2'b10: memwriteE <= 4'b0100;
//                     2'b01: memwriteE <= 4'b0010;
//                     2'b00: memwriteE <= 4'b0001;
                    default: memwriteE <= 4'b0000;
                endcase
            end    
            `SH_CONTROL: begin
                case(addressE[1:0])
                    2'b00: memwriteE <= 4'b1100;
                    2'b10: memwriteE <= 4'b0011;
                    default: memwriteE <= 4'b0000;
                endcase
            end
            `SW_CONTROL:
                memwriteE <= 4'b1111;
            default: memwriteE <= 4'b0000;       
        endcase
    end
    end
endmodule
