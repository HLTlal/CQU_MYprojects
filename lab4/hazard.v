`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
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


module hazard(
	//fetch stage
	output wire stallF,flushF,
	output reg [31:0] newpc,
	//decode stage
	input wire[4:0] rsD,rtD,
	input wire branchD,jumpD,jrD,
	input wire [5:0] alucontrolD,
	output wire forwardaD,forwardbD,jrlforwardaD,jrlforwardbD,
	output wire stallD,flushD,
	//execute stage
	input wire[4:0] rsE,rtE,
	input wire[4:0] writeregE,
	input wire regwriteE,
	input wire memtoregE,
	input wire [5:0] alucontrolE,
	input wire div_ready,
	output reg[1:0] forwardaE,forwardbE,
	output wire flushE,stallE,
	//mem stage
	input wire[4:0] writeregM,
	input wire regwriteM,
	input wire memtoregM,
    input wire [5:0] alucontrolM,
    input wire [31:0] excepttype,
    output wire flushM,
    input wire [31:0] epc,
	//write back stage
	input wire[4:0] writeregW,
	input wire regwriteW,
	output wire flushW
    );
    
	wire lwstallD,branchstallD,divstallE,jrstall;
	
	//所有例外（含中断）的例外入口地址统一为 0xBFC00380
	always@(*) begin   
        if(excepttype!=32'b0)
        begin 
            case (excepttype)
                32'h00000001,32'h00000004,32'h00000005,32'h00000008,32'h00000009,32'h0000000a,32'h0000000c:
                    newpc<=32'hbfc00380;
                32'h0000000e:	newpc <= epc;
            endcase
        end
    end

	//forwarding sources to D stage (branch equality)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	//forwarding sources to D stage(b and jr for lw)
	assign jrlforwardaD = (jrD | branchD) && ((memtoregE && (writeregE==rsD))
	                                   ||(memtoregM && (writeregM==rsD)));
	assign jrlforwardbD=(jrD | branchD) && ((memtoregE && (writeregE==rtD))
	                                   ||(memtoregM && (writeregM==rtD)));
	
	//forwarding sources to E stage (ALU)

	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			if(rsE == writeregM & regwriteM) begin
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			if(rtE == writeregM & regwriteM) begin
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				forwardbE = 2'b01;
			end
		end
	end

	//stalls
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign #1 branchstallD = branchD & (regwriteE & 
				(writeregE == rsD | writeregE == rtD) | memtoregM &
				(writeregM == rsD | writeregM == rtD));
	assign #1 divstallE=((alucontrolE==`DIV_CONTROL)|(alucontrolE==`DIVU_CONTROL))
	                                   &(~div_ready);
	assign jrstall = jrD && regwriteE && (writeregE==rsD);
	
	assign #1 stallD = lwstallD | branchstallD|divstallE | jrstall;
	assign #1 stallF = stallD;
	assign #1 stallE = divstallE;
		//stalling D stalls all previous stages
	assign #1 flushF =(excepttype!=32'b0);
	assign #1 flushD =(excepttype!=32'b0);
	assign #1 flushE = lwstallD | branchstallD | (excepttype!=32'b0);
	assign #1 flushM =(excepttype!=32'b0);
	assign #1 flushW =(excepttype!=32'b0);
		//stalling D flushes next stage
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
endmodule
