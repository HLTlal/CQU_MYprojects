module mycpu_top(
    input clk,
    input resetn,  //low active
    input [5:0] ext_int,

    //cpu inst sram
    output        inst_sram_en   ,
    output [3 :0] inst_sram_wen  ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    //cpu data sram
    output        data_sram_en   ,
    output [3 :0] data_sram_wen  ,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,
    //debug
    output [31:0] debug_wb_pc,
    output [31:0] debug_wb_rf_wen ,
    output [31:0] debug_wb_rf_wnum ,
    output [31:0] debug_wb_rf_wdata
);

// �?个例�?
	wire [31:0] pc;
	wire [31:0] instr;
	wire [3:0] memwrite;
	wire [31:0] aluout, writedata, readdata,result,pcW;
	wire regwrite;
	wire [4:0] writereg;
    mips mips(
        .clk(clk),
        .rst(~resetn),
        //instr
        // .inst_en(inst_en),
        .pcF(pc),                    //pcF
        .instrF(instr),              //instrF
        //data
        // .data_en(data_en),
        .aluoutM(aluout),
        .writedataM(writedata),
        .readdataM(readdata),
        .memwriteM(memwrite),
        .pcW(pcW),
        .resultW(result),
        .writeregW(writereg),
        .regwriteW(regwrite)
    );

    assign inst_sram_en = 1'b1;     //如果有inst_en，就用inst_en
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = pc;
    assign inst_sram_wdata = 32'b0;
    assign instr = inst_sram_rdata;

    assign data_sram_en = 1'b1;     //如果有data_en，就用data_en
    assign data_sram_wen = memwrite;
    assign data_sram_addr = aluout;
    assign data_sram_wdata = writedata;
    assign readdata = data_sram_rdata;
    
    assign debug_wb_pc = pcW;
    assign debug_wb_rf_wen ={4{regwrite}};
    assign debug_wb_rf_wnum = writereg;
    assign debug_wb_rf_wdata = result;

    //ascii
    instdec instdec(
        .instr(instr)
    );

endmodule