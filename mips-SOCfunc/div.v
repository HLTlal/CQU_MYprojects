`include "defines2.vh"

module div(

	input wire clk,
	input wire rst,
	
	input wire signed_div_i,//�Ƿ��з�������
	input wire[31:0]  opdata1_i,
	input wire[31:0]	opdata2_i,
	input wire  start_i,
	input wire  annul_i,//�Ƿ�ȡ����������
	
	output reg[63:0]  result_o,
	output reg	ready_o
);

	wire[32:0] div_temp;//��ʱ���
	reg[5:0] cnt;//���̵��ִΣ�32ʱ����
	reg[64:0] dividend;//[62:32]��ÿ�ε����ı�������[31:0]�Ǳ��������м���
	reg[1:0] state;
	reg[31:0] divisor;	//���� 
	reg[31:0] temp_op1;
	reg[31:0] temp_op2;
	reg[31:0] reg_op1;
	reg[31:0] reg_op2;
	
	assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};//minuend-n

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			state <= `DivFree;
			ready_o <= `DivResultNotReady;
			result_o <= {`ZeroWord,`ZeroWord};
		end else begin
		  case (state)
		  	`DivFree:			begin               //DivFree״̬
		  		if(start_i == `DivStart && annul_i == 1'b0) begin
		  			if(opdata2_i == `ZeroWord) begin
		  				state <= `DivByZero;
		  			end else begin
		  				state <= `DivOn;
		  				cnt <= 6'b000000;
		  				if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin
		  					temp_op1 = ~opdata1_i + 1;//����
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
						reg_op1 <= opdata1_i;
			  			reg_op2 <= opdata2_i;
                    end
                end else begin//û�п�ʼ����
						ready_o <= `DivResultNotReady;
						result_o <= {`ZeroWord,`ZeroWord};
				end          	
		  	end
		  	`DivByZero:		begin               //DivByZero״̬
         	    dividend <= {`ZeroWord,`ZeroWord};
                state <= `DivEnd;		 		
		  	end
		  	`DivOn:				begin               //DivOn״̬
		  		if(annul_i == 1'b0) begin
		  			if(cnt != 6'b100000) begin
                        if(div_temp[32] == 1'b1) begin//����С��0
                            dividend <= {dividend[63:0] , 1'b0};//0000...0�������м���������һλ��������һλ��ͬʱ���λ�ӽ��
                        end else begin
                            dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};//����������ʣ�µı��������м���
                        end
                        cnt <= cnt + 1;
                    end else begin//cnt=32����������
                        if((signed_div_i == 1'b1) && ((reg_op1[31] ^ reg_op2[31]) == 1'b1)) begin
                            dividend[31:0] <= (~dividend[31:0] + 1);
                        end
                        if((signed_div_i == 1'b1) && ((reg_op1[31] ^ dividend[64]) == 1'b1)) begin              
                            dividend[64:33] <= (~dividend[64:33] + 1);
                        end
                        state <= `DivEnd;
                        cnt <= 6'b000000;            	
                    end
		  		end else begin//annul_iΪ1��ֱ�ӽ���
		  			state <= `DivFree;
		  		end	
		  	end
		  	`DivEnd:			begin               //DivEnd״̬
        	    result_o <= {dividend[64:33], dividend[31:0]};  //��������
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