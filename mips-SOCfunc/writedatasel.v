`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/01/05 23:47:26
// Design Name: 
// Module Name: writedatasel
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


module writedatasel(
    input [31:0] writedataM,
    input [5:0] alucontrolM,
    output reg [31:0] writedata2M
    );
    always@ (*) begin
        case (alucontrolM)
            `SB_CONTROL: writedata2M <= {{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]},{writedataM[7:0]}};
            `SH_CONTROL: writedata2M <= {{writedataM[15:0]},{writedataM[15:0]}};
            `SW_CONTROL:writedata2M <= writedataM[31:0];
            default: writedata2M <= writedataM;
        endcase
    end
endmodule
