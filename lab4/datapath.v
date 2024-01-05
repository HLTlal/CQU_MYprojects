`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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


module datapath(
	input wire clk,rst,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,jalD,jrD,balD,
	input wire[5:0] alucontrolD,
	output wire equalD,
	output wire[5:0] opD,functD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,hilo_enE,
	input wire[5:0] alucontrolE,
	input wire jumpE,jalE,jrE,balE,
	output wire flushE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM,
	output wire [3:0] memwriteM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	input wire [31:0] resultW
    );
	
	//fetch stage
	wire stallF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD,pcnext_tempFD,pcplus8F;
	//decode stage
	wire [31:0] pcplus4D,instrD,pcplus8D;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD,saD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srca3DsrcbD,srcb2D,srcb3D;
	//execute stage
	wire [31:0] pcplus8E;
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE,saE;
	wire stallE;
	wire [4:0] writeregE,writereg2E,jalwriteregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] hi_oE,lo_oE,hi_outE,lo_outE;
	wire [31:0] aluoutE,aluout2E;
	wire div_sign,div_start,div_ready;
	wire [63:0] div_result;
	wire overflowE;
	//mem stage
	wire [4:0] writeregM;
	wire [31:0] alucontrolM;
	wire overflowM;
	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,lwresultW;
	wire [31:0] alucontrolW;

	//hazard detection
	hazard h(
		//fetch stage
		stallF,
		//decode stage
		rsD,rtD,
		branchD,jumpD,jrD,
		alucontrolD,
		forwardaD,forwardbD,jrlforwardaD,jrlforwardbD,
		stallD,
		//execute stage
		rsE,rtE,
		writeregE,
		regwriteE,
		memtoregE,alucontrolE,div_ready,
		forwardaE,forwardbE,
		flushE,stallE,
		//mem stage
		writeregM,
		regwriteM,
		memtoregM,
		//write back stage
		writeregW,
		regwriteW
		);

	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);//pc+4 or branch
	mux2 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD | jalD,pcnext_tempFD);//pcnext or jump
	mux2 #(32) pcjrmux(pcnext_tempFD,srca2D,jrD,pcnextFD);	//是否寄存器地址

	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF,pcnextFD,pcF);//PC'-->PCF
	
	adder pcadd1(pcF,32'b100,pcplus4F);//顺序读取
	adder pcadd12(pcF,32'b1000,pcplus8F);//jal,jalr,BLTZAL、BGEZAL
	
	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcplus8F,pcplus8D);
	
	signext se(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	mux2 #(32) jrforwardamux(srca2D,readdataM,jrlforwardaD,srca3D);
	mux2 #(32) jrforwardbmux(srcb2D,readdataM,jrlforwardbD,srcb3D);
	eqcmp comp(srca3D,srcb3D,alucontrolD,equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];

	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);//alu的b的来源于立即数还是regfile
	assign writeregE=(regwriteE==1 & regdstE==0) ? rtE :
	                               (regwriteE==1 & regdstE==1) ? rdE : 5'b00000;
	//写到regfile的地址为rd（Rtype）
	//还是rt（lb,lbu,lh,lhu,lw,sb,sh,sw,andi,xori,ori,lui,addi,addiu,slti,sltiu）
	//writereg是要写入regfile的寄存器地址
	
	alu alu(srca2E,srcb3E,alucontrolE,saE,hi_oE,lo_oE,hi_outE,lo_outE,aluoutE,overflowE);
	//除法
	assign div_sign=(alucontrolE==`DIV_CONTROL)? 1'b1:1'b0;
	assign div_start=(alucontrolE==`DIV_CONTROL | alucontrolE==`DIVU_CONTROL & ~div_ready) ? 1'b1:1'b0;
	div div(clk,rst,div_sign,srca2E,srcb3E,div_start,1'b0,div_result,div_ready);	
    hilo_reg hilom(clk,rst,hilo_enE,div_ready,alucontrolE,div_result,hi_outE,lo_outE,hi_oE,lo_oE );//选择输出hi_lo_o
    //写寄存器
    assign jalwriteregE=(alucontrolE==`JALR_CONTROL & writeregE==0) ? 5'b11111: writeregE;//jalr的rd默认为0则为31号寄存器
    mux2 #(5) jalwrmux(jalwriteregE,5'b11111,jalE|balE,writereg2E);
    mux2 #(32) wrdmux(aluoutE,pcplus8E,jalE|jrE|balE,aluout2E);
    
	//mem stage
	flopr #(32) r1M(clk,rst,srcb2E,writedataM);
	flopr #(32) r2M(clk,rst,aluout2E,aluoutM);
	flopr #(5) r3M(clk,rst,writereg2E,writeregM);
	flopr #(32) r4M(clk,rst,overflowE,overflowM);
	flopr #(8) r5M(clk,rst,alucontrolE,alucontrolM);
//	flopr #(32) r5M(clk,rst,lo_outE,lo_outM);

//	lsaddr ls_addr(aluoutM,alucontrolM,laddrerrM,saddrerrM);
    smem swsel(aluoutM,alucontrolM,memwriteM);

	//writeback stage
	flopr #(32) r1W(clk,rst,aluoutM,aluoutW);
	flopr #(32) r2W(clk,rst,readdataM,readdataW);
	flopr #(5) r3W(clk,rst,writeregM,writeregW);
	flopr #(8) r4W(clk,rst,alucontrolM,alucontrolW);
	
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,lwresultW);//控制Result 来源为 ALU 或数据存储器
    lmem lwsel(aluoutW,alucontrolW,lwresultW,resultW);

endmodule
