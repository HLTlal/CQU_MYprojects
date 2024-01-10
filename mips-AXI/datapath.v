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
	input wire [5:0] ext_int,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,jalD,jrD,balD,breakD,syscallD,reserveD,eretD,
	input wire[5:0] alucontrolD,
	output wire equalD,stallD,
	output wire[5:0] opD,functD,
	output wire[4:0] rtD,
	output wire [31:0] instrD,
	//execute stage
	input wire memtoregE,memrenE,memwenE,
	input wire alusrcE,regdstE,
	input wire regwriteE,hilo_enE,
	input wire[5:0] alucontrolE,
	input wire jumpE,jalE,jrE,balE,
	output wire flushE,stallE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,mtc0_weM,mfc0M,
	output wire[31:0] aluout2M,writedata2M,
	input wire[31:0] readdataM,
	output wire [3:0] memwriteM,
	output wire flushM,
	output wire memrenM,memwenM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	output wire flushW,
	output wire [31:0] pcW,resultW,aluoutW,
	output wire [4:0] writeregW,
	
	output wire inst_enF,
	input wire i_stall,d_stall,
	output wire longest_stall	
    );
	
	//fetch stage
	wire stallF,flushF,indelayslotF;
	wire [31:0] newpc;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD,pcnext_tempFD,pcplus8F;
	//decode stage
	wire [31:0] pcplus4D,pcplus8D,pcD;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rdD,saD;
	wire [6:0] exceptD;
	wire flushD,indelayslotD,jrlforwardaD,jrlforwardbD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srca3D,srcbD,srcb2D,srcb3D;

	//execute stage
	wire [31:0] pcplus8E,pcE;
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE,saE;
	wire indelayslotE;
	wire [6:0] exceptE;
	wire [4:0] writeregE,writereg2E,jalwriteregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcad2E,srcbE,srcb2E,srcbd2E,srcb3E;
	wire [31:0] hi_oE,lo_oE,hi_outE,lo_outE;
	wire [31:0] aluoutE,aluout2E;
	wire div_sign,div_start,div_ready;
	wire [63:0] div_result;
	wire overflowE;
	//mem stage
	wire [4:0] writeregM;
	wire [4:0] rdM;
	wire [31:0] pcM;
	wire [5:0] alucontrolM;
	wire overflowM,indelayslotM,laddrerrM,saddrerrM;
	wire [31:0] writedataM,aluoutM,srcbM;
	wire [6:0] exceptM;
	wire [31:0] excepttype_i,bad_addr_i,count_o,cp0rdataM,compare_o,status_o,cause_o,epc_o,config_o,prid_o,badvaddr;
	wire timer_int_o;
	wire stallM;
	//writeback stage
	wire [31:0] readdataW,lwresultW;
	wire [5:0] alucontrolW;
	wire laddrerrW;

	//hazard detection
	hazard h(
		//fetch stage
		stallF,flushF, newpc,
		//decode stage
		rsD,rtD,
		branchD,jumpD,jrD,
		alucontrolD,
		forwardaD,forwardbD,jrlforwardaD,jrlforwardbD,
		stallD,flushD,
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
		memtoregM,alucontrolM,
		excepttype_i,flushM,epc_o,
		stallM,
		//write back stage
		writeregW,
		regwriteW,flushW,
		i_stall,d_stall,
		longest_stall
		);
		
		wire pc_errorF;
		assign pc_errorF = pcF[1:0]!=2'b0 ? 1'b1 : 1'b0;
        assign inst_enF = ~rst  & ~pc_errorF;


	//next PC logic (operates in fetch an decode)
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);//pc+4 or branch
	mux2 #(32) pcmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD | jalD,pcnext_tempFD);//pcnext or jump
	mux2 #(32) pcjrmux(pcnext_tempFD,srca2D,jrD,pcnextFD);	//�Ƿ�Ĵ������?

	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF,flushF,pcnextFD,newpc,pcF);//PC'-->PCF
	
	adder pcadd1(pcF,32'b100,pcplus4F);//˳����?
	adder pcadd12(pcF,32'b1000,pcplus8F);//jal,jalr,BLTZAL��BGEZAL
	
	assign indelayslotF=jumpD|jalD|jrD|branchD;
	
	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcplus8F,pcplus8D);
	flopenrc #(1) r4D(clk,rst,~stallD,flushD,indelayslotF,indelayslotD);
	flopenrc #(32) r5D(clk,rst,~stallD,flushD,pcF,pcD);
	
	signext se(instrD[15:0],instrD[29:28],signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluout2M,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluout2M,forwardbD,srcb2D);
	mux2 #(32) jrforwardamux(srca2D,readdataM,jrlforwardaD,srca3D);
	mux2 #(32) jrforwardbmux(srcb2D,readdataM,jrlforwardbD,srcb3D);
	eqcmp comp(srca3D,srcb3D,alucontrolD,equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign saD = instrD[10:6];
    assign exceptD[3:0]={reserveD,breakD,syscallD,eretD};
    
	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,pcplus8D,pcplus8E);
	flopenrc #(1) 	r9E(clk,rst,~stallE,flushE,indelayslotD,indelayslotE);
	flopenrc #(4) 	r10E(clk,rst,~stallE,flushE,exceptD[3:0],exceptE[3:0]);
	flopenrc #(32) r11E(clk,rst,~stallE,flushE,pcD,pcE);

	mux3 #(32) forwardaemux(srcaE,resultW,aluout2M,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluout2M,forwardbE,srcb2E);
	
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);//alu��b����Դ������������regfile
	assign writeregE=(regwriteE==1 & regdstE==0) ? rtE :
	                               (regwriteE==1 & regdstE==1) ? rdE : 5'b00000;
	//д��regfile�ĵ�ַΪrd��Rtype��
	//����rt��lb,lbu,lh,lhu,lw,sb,sh,sw,andi,xori,ori,lui,addi,addiu,slti,sltiu��
	//writereg��Ҫд��regfile�ļĴ�����ַ
	
	alu alu(srca2E,srcb3E,alucontrolE,saE,hi_oE,lo_oE,hi_outE,lo_outE,aluoutE,overflowE);
	assign exceptE[4]=overflowE;
	//����
	assign div_sign=(alucontrolE==`DIV_CONTROL)? 1'b1:1'b0;
	assign div_start=((alucontrolE==`DIV_CONTROL | alucontrolE==`DIVU_CONTROL )& ~div_ready) ? 1'b1:1'b0;
	div div(clk,rst,div_sign,srca2E,srcb3E,div_start,1'b0,div_result,div_ready);	
    hilo_reg hilom(clk,rst,~flushE,div_ready,alucontrolE,div_result,hi_outE,lo_outE,hi_oE,lo_oE );//ѡ�����hi_lo_o
    //д�Ĵ���
    assign jalwriteregE=(alucontrolE==`JALR_CONTROL & writeregE==0) ? 5'b11111: writeregE;//jalr��rdĬ��Ϊ0��Ϊ31�żĴ���
    mux2 #(5) jalwrmux(jalwriteregE,5'b11111,jalE|balE,writereg2E);
    mux2 #(32) wrdmux(aluoutE,pcplus8E,jalE|jrE|balE,aluout2E);
    
	//mem stage
	floprc #(32) r1M(clk,rst,flushM,srcb2E,writedataM);
	floprc #(32) r2M(clk,rst,flushM,aluout2E,aluoutM);
	floprc #(5) r3M(clk,rst,flushM,writereg2E,writeregM);
	floprc #(1) r4M(clk,rst,flushM,overflowE,overflowM);
	floprc #(6) r5M(clk,rst,flushM,alucontrolE,alucontrolM);
	floprc #(1) 	r6M(clk,rst,flushM,indelayslotE,indelayslotM);
	floprc #(5) 	r7M(clk,rst,flushM,exceptE[4:0],exceptM[4:0]);
	floprc #(32) r8M(clk,rst,flushM,pcE,pcM);
	floprc #(5) r9M(clk,rst,flushM,rdE,rdM);
	flopenrc #(1) r10M(clk,rst,~stallM,flushM,memrenE,memrenM);
	flopenrc #(1) r11M(clk,rst,~stallM,flushM,memwenE,memwenM);
	floprc #(32) r12M(clk,rst,flushM,srcb3E,srcbM);
	
//	flopr #(32) r5M(clk,rst,lo_outE,lo_outM);
    mux2 #(32) cp0mux(aluoutM,cp0rdataM,mfc0M,aluout2M);
	lsaddr ls_addr(aluout2M,alucontrolM,laddrerrM,saddrerrM);
    smem swsel(saddrerrM,aluout2M,alucontrolM,memwriteM);
    writedatasel writedata(writedataM,alucontrolM,writedata2M);
    assign exceptM[6:5]={laddrerrM,saddrerrM};
    
    excepttype excepttypei(rst,pcM,exceptM,status_o,cause_o,aluout2M,excepttype_i,bad_addr_i);
    
    cp0_reg cp0reg(clk, rst,mtc0_weM,rdM,rdM,srcbM,ext_int,excepttype_i,pcM, indelayslotM,bad_addr_i,
            count_o,cp0rdataM,compare_o,status_o,cause_o,epc_o,config_o,prid_o,badvaddr,timer_int_o);
            
	//writeback stage
	floprc #(32) r1W(clk,rst,flushW,aluout2M,aluoutW);
	floprc #(32) r2W(clk,rst,flushW,readdataM,readdataW);
	floprc #(5) r3W(clk,rst,flushW,writeregM,writeregW);
	floprc #(6) r4W(clk,rst,flushW,alucontrolM,alucontrolW);
	floprc #(1) r5W(clk,rst,flushW,laddrerrM,laddrerrW);
	floprc #(32) r6W(clk,rst,flushW,pcM,pcW);
	
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,lwresultW);//����Result ��ԴΪ ALU �����ݴ洢��
    lmem lwsel(laddrerrW,aluoutW,alucontrolW,lwresultW,resultW);
    
    
    
endmodule
