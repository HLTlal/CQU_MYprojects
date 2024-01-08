`timescale 1ns / 1ps
`include "defines2.vh"

module cp0_reg(
	input wire clk,
	input wire rst,

	input wire we_i,
	input[4:0] waddr_i,
	input[4:0] raddr_i,
	input[`RegBus] data_i,//д����

	input wire[5:0] int_i,//ÿһλ��Ӧһ��Ӳ���ж�

	input wire[`RegBus] excepttype_i,
	input wire[`RegBus] current_inst_addr_i,
	input wire is_in_delayslot_i,
	input wire[`RegBus] bad_addr_i,

	output wire[`RegBus] count_o,//9,��32���¼���
	output reg [`RegBus] data_o,//������
	output reg [`RegBus] compare_o,//11����countֵ��ͬʱ��ʱ�ж�
	output reg [`RegBus] status_o,//12
	output reg [`RegBus] cause_o,//13,��¼��һ���쳣ԭ��
	output reg [`RegBus] epc_o,//14�쳣���ص�ַ
	output reg [`RegBus] config_o,
	output reg [`RegBus] prid_o,
	output reg [`RegBus] badvaddr,
	output reg           timer_int_o//�Ƿ�ʱ�ж�
    );

	reg[32:0] count;
	assign count_o = count[32:1];
	
	always @(posedge clk) begin
		if(rst == `RstEnable) begin
			count <= 0;
			compare_o <= `ZeroWord;
			status_o <= 32'b00010000000000000000000000000000;
			cause_o <= `ZeroWord;
			epc_o <= `ZeroWord;
			config_o <= 32'b00000000000000001000000000000000;
			prid_o <= 32'b00000000010011000000000100000010;
			timer_int_o <= `InterruptNotAssert;
		end else begin
			count <= count + 1;
			cause_o[15:10] <= int_i;
			if(compare_o != `ZeroWord && count_o == compare_o) begin
				/* code */
				timer_int_o <= `InterruptAssert;//ʱ���жϷ���
			end
			if(we_i == `WriteEnable) begin
				/* code */
				case (waddr_i)
					`CP0_REG_COUNT:begin 
						count[32:1] <= data_i;
					end
					`CP0_REG_COMPARE:begin 
						compare_o <= data_i;
						timer_int_o <= `InterruptNotAssert;
					end
					`CP0_REG_STATUS:begin 
						status_o <= data_i;
					end
					`CP0_REG_CAUSE:begin 
						cause_o[9:8] <= data_i[9:8];
						cause_o[23] <= data_i[23];
						cause_o[22] <= data_i[22];
					end
					`CP0_REG_EPC:begin 
						epc_o <= data_i;
					end
					default : /* default */;
				endcase
			end
			case (excepttype_i)
				32'h00000001:begin // �ⲿ�ж�
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00000;
				end
				32'h00000004:begin // adel
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00100;
					badvaddr <= bad_addr_i;
				end
				32'h00000005:begin // ades
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b00101;
					badvaddr <= bad_addr_i;
				end
				32'h00000008:begin // Syscall
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01000;
				end
				32'h00000009:begin // breakM
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01001;
				end
				32'h0000000a:begin //��Чָ��
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01010;
				end
				32'h0000000c:begin // ALU�������
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01100;
				end
				32'h0000000d:begin // 自陷指令（不�?57条中�?
					if(is_in_delayslot_i == `InDelaySlot) begin
						/* code */
						epc_o <= current_inst_addr_i - 4;
						cause_o[31] <= 1'b1;
					end else begin 
						epc_o <= current_inst_addr_i;
						cause_o[31] <= 1'b0;
					end
					status_o[1] <= 1'b1;
					cause_o[6:2] <= 5'b01101;
				end
				32'h0000000e:begin // eret
					status_o[1] <= 1'b0;
				end
				default : /* default */;
			endcase
		end
	end

	always @(*) begin
		if(rst == `RstEnable) begin
			/* code */
			data_o <= `ZeroWord;
		end else begin 
			case (raddr_i)
				`CP0_REG_COUNT:begin 
					data_o <= count_o;
				end
				`CP0_REG_COMPARE:begin 
					data_o <= compare_o;
				end
				`CP0_REG_STATUS:begin 
					data_o <= status_o;
				end
				`CP0_REG_CAUSE:begin 
					data_o <= cause_o;
				end
				`CP0_REG_EPC:begin 
					data_o <= epc_o;
				end
				`CP0_REG_PRID:begin 
					data_o <= prid_o;
				end
				`CP0_REG_CONFIG:begin 
					data_o <= config_o;
				end
				`CP0_REG_BADVADDR:begin 
					data_o <= badvaddr;
				end
				default : begin 
					data_o <= `ZeroWord;
				end
			endcase
		end
	
	end
endmodule
