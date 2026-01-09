`define I_NOP	32'h13

//==================== ALU Operation  ====================//
`define ALUOP_ADD				4'h0
`define ALUOP_SUB				4'h1
`define ALUOP_AND				4'h2
`define ALUOP_OR				4'h3
`define ALUOP_XOR				4'h4
`define ALUOP_A				4'h5
`define ALUOP_A_ADD_4		4'h6
`define ALUOP_LTU				4'h7
`define ALUOP_LT				4'h8
`define ALUOP_SLL				4'h9
`define ALUOP_SRL				4'hA
`define ALUOP_SRA				4'hB
`define ALUOP_B				4'hC

//==================== Opcode 定義 ====================//

`define Opcode_I			7'b0010011		// I-type 指令
`define Opcode_R_M		7'b0110011		// R-type 指令
`define Opcode_B			7'b1100011		// B-type 指令
`define Opcode_JAL		7'b1101111		// J-type 指令
`define Opcode_JALR		7'b1100111
`define Opcode_LUI		7'b0110111
`define Opcode_AUIPC		7'b0010111
`define Opcode_L			7'b0000011		// load 指令
`define Opcode_S			7'b0100011		// store 指令

//==================== funct3 定義 ====================//

// --- I-type ---
`define F_ADDI				3'b000
`define F_SLTI				3'b010
`define F_SLTIU			3'b011
`define F_XORI				3'b100
`define F_ORI				3'b110
`define F_ANDI				3'b111
`define F_SLLI				3'b001
`define F_SRLI_SRAI		3'b101

// --- R-type ---
`define F_ADD_SUB			3'b000
`define F_SLL				3'b001
`define F_SLT				3'b010
`define F_SLTU				3'b011
`define F_XOR				3'b100
`define F_SRL_SRA			3'b101
`define F_OR				3'b110
`define F_AND				3'b111

// --- B-type ---
`define F_BEQ				3'b000
`define F_BNE				3'b001
`define F_BLT				3'b100
`define F_BGE				3'b101
`define F_BLTU				3'b110
`define F_BGEU				3'b111

// --- load ---
`define F_LB				3'b000
`define F_LH				3'b001
`define F_LW				3'b010
`define F_LBU				3'b100
`define F_LHU				3'b101
// --- store ---
`define F_SB				3'b000
`define F_SH				3'b001
`define F_SW				3'b010

// --- mul ---
`define F_MUL				3'b000
`define F_MULH				3'b001
`define F_MULHSU			3'b010
`define F_MULHU			3'b011
// --- div ---
`define F_DIV				3'b100
`define F_DIVU				3'b101
`define F_REM				3'b110
`define F_REMU				3'b111

//==================== funct7 定義 ====================//

// --- I-type ---
`define F7_SRLI			7'b0000000
`define F7_SRAI			7'b0100000

// --- R-type ---
`define F7_ADD				7'b0000000
`define F7_SUB_SRA		7'b0100000
`define F7_OPCODE_R		7'b0000000
`define F7_SRL				7'b0000000

// --- mul/div ---
`define F7_M				7'b0000001