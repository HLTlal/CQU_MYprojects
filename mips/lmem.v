`timescale 1ns / 1ps
`include "defines2.vh"
module lmem(
//    input wire laddrerrM,
    input wire [31:0] aluoutW,
    input [7:0] alucontrolW,
    input [31:0] lwresultW,
    output reg [31:0] result2W
    );

    always@ (*) begin
//    if(~laddrerrM) begin
        case(alucontrolW)
            `LB_CONTROL: case(aluoutW[1:0])
                2'b11: result2W = {{24{lwresultW[7]}},lwresultW[7:0]};
                2'b10: result2W = {{24{lwresultW[15]}},lwresultW[15:8]};
                2'b01: result2W = {{24{lwresultW[23]}},lwresultW[23:16]};
                2'b00: result2W = {{24{lwresultW[31]}},lwresultW[31:24]};
                default: result2W = lwresultW;
            endcase
            `LBU_CONTROL: case(aluoutW[1:0])
                2'b11: result2W = {{24{1'b0}},lwresultW[7:0]};
                2'b10: result2W = {{24{1'b0}},lwresultW[15:8]};
                2'b01: result2W = {{24{1'b0}},lwresultW[23:16]};
                2'b00: result2W = {{24{1'b0}},lwresultW[31:24]};
                default: result2W = lwresultW;
            endcase
            `LH_CONTROL: case(aluoutW[1:0])
                2'b10: result2W = {{16{lwresultW[15]}},lwresultW[15:0]};
                2'b00: result2W = {{16{lwresultW[31]}},lwresultW[31:16]};
                default: result2W = lwresultW;
            endcase
            `LHU_CONTROL:case(aluoutW[1:0])
                2'b10: result2W = {{16{1'b0}},lwresultW[15:0]};
                2'b00: result2W = {{16{1'b0}},lwresultW[31:16]};
                default: result2W = lwresultW; 
            endcase
        default: result2W = lwresultW;
        endcase
    end
//    end
endmodule