`timescale 1ns / 1ps
`include "defines2.vh"
module lmem(
    input wire laddrerrM,
    input wire [31:0] aluoutW,
    input [5:0] alucontrolW,
    input [31:0] lwresultW,
    output reg [31:0] resultW
    );

    always@ (*) begin
    if(~laddrerrM) begin
        case(alucontrolW)
            `LB_CONTROL: case(aluoutW[1:0])
                2'b00: resultW = {{24{lwresultW[7]}},lwresultW[7:0]};
                2'b01: resultW = {{24{lwresultW[15]}},lwresultW[15:8]};
                2'b10: resultW = {{24{lwresultW[23]}},lwresultW[23:16]};
                2'b11: resultW = {{24{lwresultW[31]}},lwresultW[31:24]};
                //2'b11: resultW = {{24{lwresultW[7]}},lwresultW[7:0]};
                //2'b10: resultW = {{24{lwresultW[15]}},lwresultW[15:8]};
                //2'b01: resultW = {{24{lwresultW[23]}},lwresultW[23:16]};
                //2'b00: resultW = {{24{lwresultW[31]}},lwresultW[31:24]};
                default: resultW = lwresultW;
            endcase
            `LBU_CONTROL: case(aluoutW[1:0])
                2'b00: resultW = {{24{1'b0}},lwresultW[7:0]};
                2'b01: resultW = {{24{1'b0}},lwresultW[15:8]};
                2'b10: resultW = {{24{1'b0}},lwresultW[23:16]};
                2'b11: resultW = {{24{1'b0}},lwresultW[31:24]};
                //2'b11: resultW = {{24{1'b0}},lwresultW[7:0]};
                //2'b10: resultW = {{24{1'b0}},lwresultW[15:8]};
                //2'b01: resultW = {{24{1'b0}},lwresultW[23:16]};
                //2'b00: resultW = {{24{1'b0}},lwresultW[31:24]};
                default: resultW = lwresultW;
            endcase
            `LH_CONTROL: case(aluoutW[1:0])
                2'b00: resultW = {{16{lwresultW[15]}},lwresultW[15:0]};
                2'b10: resultW = {{16{lwresultW[31]}},lwresultW[31:16]};
                //2'b10: resultW = {{16{lwresultW[15]}},lwresultW[15:0]};
                //2'b00: resultW = {{16{lwresultW[31]}},lwresultW[31:16]};
                default: resultW = lwresultW;
            endcase
            `LHU_CONTROL:case(aluoutW[1:0])
                2'b00: resultW = {{16{1'b0}},lwresultW[15:0]};
                2'b10: resultW = {{16{1'b0}},lwresultW[31:16]};
                //2'b10: resultW = {{16{1'b0}},lwresultW[15:0]};
                //2'b00: resultW = {{16{1'b0}},lwresultW[31:16]};
                default: resultW = lwresultW; 
            endcase
        default: resultW = lwresultW;
        endcase
    end
    end
endmodule