`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/12/20 20:20:38
// Design Name: 
// Module Name: lwswexcept
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
module lsaddr(
    input [31:0] addrs,
    input [5:0] alucontrolM,
    output reg laddrerrM,saddrerrM
    );
    always@(*) begin
        case (alucontrolM)
            `LH_CONTROL: if (addrs[0] != 1'b0 ) begin
                laddrerrM = 1'b1;
            end
            `LHU_CONTROL: if ( addrs[0] != 1'b0 ) begin
                laddrerrM = 1'b1;
            end
            `LW_CONTROL: if ( addrs[1:0] != 2'b00 ) begin
                laddrerrM = 1'b1;
            end
            `SH_CONTROL: if (addrs[0] != 1'b0 ) begin
                saddrerrM = 1'b1;
            end
            `SW_CONTROL: if ( addrs[1:0] != 2'b00 ) begin
                saddrerrM = 1'b1;
            end
            default: begin
                laddrerrM = 1'b0;
                saddrerrM = 1'b0;
            end
        endcase
    end
endmodule
