// global macro definition
`define RstEnable 		1'b1
`define RstDisable		1'b0
`define ZeroWord		32'h00000000
`define WriteEnable		1'b1
`define WriteDisable	1'b0
`define ReadEnable		1'b1
`define ReadDisable		1'b0
`define AluOpBus		7:0
`define AluSelBus		2:0
`define InstValid		1'b0
`define InstInvalid		1'b1
`define Stop 			1'b1
`define NoStop 			1'b0
`define InDelaySlot 	1'b1
`define NotInDelaySlot 	1'b0
`define Branch 			1'b1
`define NotBranch 		1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 		1'b1
`define TrapNotAssert 	1'b0
`define True_v			1'b1
`define False_v			1'b0
`define ChipEnable		1'b1
`define ChipDisable		1'b0
`define AHB_IDLE 2'b00
`define AHB_BUSY 2'b01
`define AHB_WAIT_FOR_STALL 2'b11

//specific inst macro definition

`define NOP			6'b000000
`define AND 		6'b100100//funct
`define OR 			6'b100101//funct
`define XOR 		6'b100110//funct
`define NOR			6'b100111//funct
`define ANDI		6'b001100
`define ORI			6'b001101
`define XORI		6'b001110
`define LUI			6'b001111

`define SLL			6'b000000//funct
`define SLLV		6'b000100
`define SRL 		6'b000010
`define SRLV 		6'b000110
`define SRA 		6'b000011
`define SRAV 		6'b000111//funct

`define MFHI  		6'b010000//funct
`define MTHI  		6'b010001
`define MFLO  		6'b010010
`define MTLO  		6'b010011//funct

`define SLT  6'b101010//funct
`define SLTU  6'b101011   
`define ADD  6'b100000
`define ADDU  6'b100001
`define SUB  6'b100010
`define SUBU  6'b100011//funct
`define ADDI  6'b001000
`define ADDIU  6'b001001
`define SLTI  6'b001010
`define SLTIU  6'b001011

`define MULT  6'b011000//funct
`define MULTU  6'b011001
`define DIV  6'b011010
`define DIVU  6'b011011//funct

`define JALR  6'b001001//funct
`define JR  6'b001000//funct
`define J  6'b000010
`define JAL  6'b000011
`define BEQ  6'b000100
`define BGTZ  6'b000111
`define BLEZ  6'b000110
`define BNE  6'b000101
`define BLTZ  5'b00000//rt
`define BLTZAL  5'b10000//rt
`define BGEZ  5'b00001//rt
`define BGEZAL  5'b10001//rt

`define LB  6'b100000
`define LBU  6'b100100
`define LH  6'b100001
`define LHU  6'b100101
`define LW  6'b100011
`define SB  6'b101000
`define SH  6'b101001
`define SW  6'b101011

`define SYSCALL 6'b001100//funct
`define BREAK 6'b001101//funct
   
`define ERET 32'b01000010000000000000000000011000

`define R_TYPE 6'b000000
`define REGIMM_INST 6'b000001
`define SPECIAL3_INST 6'b010000
//change the SPECIAL2_INST from 6'b011100 to 6'b010000
`define MTC0 5'b00100//rs
`define MFC0 5'b00000//rs

// ALU OP 4bit

`define ANDI_OP 4'b0000
`define XORI_OP 4'b0001
`define ORI_OP  4'b0010
`define LUI_OP  4'b0011
`define ADDI_OP 4'b0100
`define ADDIU_OP    4'b0101
`define SLTI_OP     4'b0110
`define SLTIU_OP    4'b0111

`define MEM_OP  4'b0100
`define R_TYPE_OP 4'b1000
`define MFC0_OP 4'b1001
`define MTC0_OP 4'b1010
`define USELESS_OP 4'b1111

// ALU CONTROL 6bit
`define AND_CONTROL 6'b000111
`define OR_CONTROL  6'b000001
`define XOR_CONTROL 6'b000010
`define NOR_CONTROL 6'b000011
`define LUI_CONTROL 6'b000100

`define SLL_CONTROL 6'b001000
`define SRL_CONTROL 6'b001001
`define SRA_CONTROL 6'b001010
`define SLLV_CONTROL    6'b001011
`define SRLV_CONTROL    6'b001100
`define SRAV_CONTROL    6'b001101

`define ADD_CONTROL    6'b010000
`define ADDU_CONTROL    6'b010001
`define SUB_CONTROL     6'b010010
`define SUBU_CONTROL    6'b010011
`define SLT_CONTROL     6'b010100
`define SLTU_CONTROL    6'b010101

`define MULT_CONTROL    6'b011000
`define MULTU_CONTROL   6'b011001
`define DIV_CONTROL     6'b011010
`define DIVU_CONTROL    6'b011011

`define MFHI_CONTROL  	6'b011100
`define MTHI_CONTROL  	6'b011101
`define MFLO_CONTROL  	6'b011110
`define MTLO_CONTROL  	6'b011111

`define J_CONTROL    6'b100001
`define JAL_CONTROL    6'b100010
`define BEQ_CONTROL    6'b100011
`define BGTZ_CONTROL    6'b100100
`define BLEZ_CONTROL    6'b100101
`define BNE_CONTROL    6'b100110
`define BLTZ_CONTROL    6'b100111
`define BLTZAL_CONTROL    6'b101000
`define BGEZ_CONTROL    6'b101001
`define BGEZAL_CONTROL    6'b101010
`define JALR_CONTROL    6'b101011
`define JR_CONTROL    6'b101100

`define LB_CONTROL    6'b110001
`define LBU_CONTROL    6'b110010
`define LH_CONTROL    6'b110011
`define LHU_CONTROL    6'b110100
`define LW_CONTROL    6'b110101
`define SB_CONTROL    6'b110110
`define SH_CONTROL    6'b110111
`define SW_CONTROL    6'b111000

`define MFC0_CONTROL 	6'b000101
`define MTC0_CONTROL 	6'b000110

//inst ROM macro definition
`define InstAddrBus		31:0
`define InstBus 		31:0

//data RAM
`define DataAddrBus 31:0
`define DataBus 31:0
`define ByteWidth 7:0

//regfiles macro definition

`define RegAddrBus		4:0
`define RegBus 			31:0
`define RegWidth		32
`define DoubleRegWidth	64
`define DoubleRegBus	63:0
`define RegNum			32
`define RegNumLog2		5
`define NOPRegAddr		5'b00000

//div
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivResultReady 1'b1
`define DivResultNotReady 1'b0
`define DivStart 1'b1
`define DivStop 1'b0

//CP0
`define CP0_REG_BADVADDR    5'b01000       
`define CP0_REG_COUNT    5'b01001        
`define CP0_REG_COMPARE    5'b01011      
`define CP0_REG_STATUS    5'b01100       
`define CP0_REG_CAUSE    5'b01101       
`define CP0_REG_EPC    5'b01110          
`define CP0_REG_PRID    5'b01111         
`define CP0_REG_CONFIG    5'b10000       