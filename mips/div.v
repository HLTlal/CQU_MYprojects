`include "defines2.vh"

module div(

	input wire clk,
	input wire rst,
	
	input wire signed_div_i,//是否有符号运算
	input wire[31:0]  opdata1_i,
	input wire[31:0]	opdata2_i,
	input wire  start_i,
	input wire  annul_i,//是否取消除法运算
	
	output reg[63:0]  result_o,
	output reg	ready_o
);

	wire[32:0] div_temp;//暂时结果
	reg[5:0] cnt;//试商的轮次，32时结束
	reg[64:0] dividend;//[62:32]是每次迭代的被减数，[31:0]是被除数和中间结果
	reg[1:0] state;
	reg[31:0] divisor;	//除数 
	reg[31:0] temp_op1;
	reg[31:0] temp_op2;
	
	assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};//minuend-n

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			state <= `DivFree;
			ready_o <= `DivResultNotReady;
			result_o <= {`ZeroWord,`ZeroWord};
		end else begin
		  case (state)
		  	`DivFree:			begin               //DivFree状态
		  		if(start_i == `DivStart && annul_i == 1'b0) begin
		  			if(opdata2_i == `ZeroWord) begin
		  				state <= `DivByZero;
		  			end else begin
		  				state <= `DivOn;
		  				cnt <= 6'b000000;
		  				if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin
		  					temp_op1 = ~opdata1_i + 1;//补码
		  				end else begin
		  					temp_op1 = opdata1_i;
		  				end
		  				if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin
		  					temp_op2 = ~opdata2_i + 1;
		  				end else begin
		  					temp_op2 = opdata2_i;
		  				end
		  			    dividend <= {`ZeroWord,`ZeroWord};
                        dividend[32:1] <= temp_op1;
                        divisor <= temp_op2;
                    end
                end else begin//没有开始除法
						ready_o <= `DivResultNotReady;
						result_o <= {`ZeroWord,`ZeroWord};
				end          	
		  	end
		  	`DivByZero:		begin               //DivByZero状态
         	    dividend <= {`ZeroWord,`ZeroWord};
                state <= `DivEnd;		 		
		  	end
		  	`DivOn:				begin               //DivOn状态
		  		if(annul_i == 1'b0) begin
		  			if(cnt != 6'b100000) begin
                        if(div_temp[32] == 1'b1) begin//试商小于0
                            dividend <= {dividend[63:0] , 1'b0};//0000...0被减数中间结果，左移一位被减数加一位，同时最低位加结果
                        end else begin
                            dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};//减的余数，剩下的被减数，中间商
                        end
                        cnt <= cnt + 1;
                    end else begin//cnt=32，除法结束
                        if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1)) begin
                            dividend[31:0] <= (~dividend[31:0] + 1);
                        end
                        if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1)) begin              
                            dividend[64:33] <= (~dividend[64:33] + 1);
                        end
                        state <= `DivEnd;
                        cnt <= 6'b000000;            	
                    end
		  		end else begin//annul_i为1，直接结束
		  			state <= `DivFree;
		  		end	
		  	end
		  	`DivEnd:			begin               //DivEnd状态
        	    result_o <= {dividend[64:33], dividend[31:0]};  //余数，商
                ready_o <= `DivResultReady;
                if(start_i == `DivStop) begin
          	        state <= `DivFree;
					ready_o <= `DivResultNotReady;
					result_o <= {`ZeroWord,`ZeroWord};       	
                end		  	
		  	end
		  endcase
		end
	end

endmodule