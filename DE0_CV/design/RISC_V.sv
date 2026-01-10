`include "defines.sv"

module RISC_V(
	input clk,
	input rst,
	output logic [31:0] regs_31
);

logic [63:0] product;
			 
logic [31:0] pc, pc_r, pc_rr, pc_next_;
logic [31:0] inst_, inst_r;
logic [31:0] rd_value_, rs1_value, rs1_value_, rs1_value_r;
logic [31:0] rs2_value, rs2_value_, rs2_value_r;
logic [31:0] imm_, imm_r, IMM_I, IMM_B, IMM_JAL, IMM_LUI_AUIPC, IMM_S;
logic [31:0] alu_a_, alu_b_, alu_out;
logic [31:0] mul_out, div_out;
logic [31:0] read_data;
logic [31:0] j_addr_, base_addr_, jump_addr_;
 
logic [6:0] opcode_, funct7_;

logic [4:0] addr_rd_, addr_rs1_, addr_rs2_, addr_rd_r;
				
logic [3:0] op_, op_r;

logic [2:0] funct3_, funct3_r;

logic [1:0] sel_alu_b_, sel_alu_b_r;
logic [1:0] sel_rd_value_, sel_rd_value_r;

logic rst_pc_, flush_IFID_, flush_IFID_r, flush_IDEX_, flush_IDEX_r;
logic write_regf_en_, write_regf_en_r;
logic sel_pc_, sel_pc_r;
logic sel_alu_a_, sel_alu_a_r;
logic sel_jump_, sel_jump_r;
logic write_ram_, write_ram_r;
logic sel_rs1_value_, sel_rs2_value_;

// B-type flag
logic BEQ_FLAG, BNE_FLAG, BLT_FLAG, BGE_FLAG, BLTU_FLAG, BGEU_FLAG;

// PC

always_comb begin
	unique case (sel_pc_r)
		0: pc_next_ = pc + 4;
		1: pc_next_ = jump_addr_;
	endcase
end

always_ff @(posedge clk)
	if(rst | rst_pc_)
		pc <= 0;
	else
		pc <= pc_next_;
		
// Program_Rom

Program_Rom u_Program_Rom(
	.Rom_addr	(pc),
	.Rom_data	(inst_)
);

// IF/IDSS

always_ff @(posedge clk)
begin
	if(rst | flush_IFID_r)
	begin
		inst_r 	<= `I_NOP;
		pc_r 	<= 0;
	end
	else 
	begin
		inst_r 	<= inst_;
		pc_r 	<= pc;
	end
end

// INST_DEC

assign opcode_ 		= inst_r[6:0];
assign addr_rd_ 	= inst_r[11:7];
assign funct3_ 		= inst_r[14:12];
assign addr_rs1_ 	= inst_r[19:15];
assign addr_rs2_ 	= inst_r[24:20];
assign funct7_ 		= inst_r[31:25];

assign IMM_I 			= {{20{inst_r[31]}}, inst_r[31:20]};	// I-type立即值
assign IMM_B 			= {{20{inst_r[31]}}, inst_r[7], inst_r[30:25], inst_r[11:8], 1'b0};	// B-type立即值
assign IMM_JAL			= {{12{inst_r[31]}}, inst_r[19:12], inst_r[20], inst_r[30:21], 1'b0};
assign IMM_LUI_AUIPC	= {inst_r[31:12], 12'b0};
assign IMM_S			= {{20{inst_r[31]}}, inst_r[31:25], inst_r[11:7]};

always_comb begin
	unique case (opcode_)
		`Opcode_I: 		imm_ = IMM_I;
		`Opcode_B: 		imm_ = IMM_B;
		`Opcode_JAL: 	imm_ = IMM_JAL;
		`Opcode_JALR: 	imm_ = IMM_I;
		`Opcode_LUI: 	imm_ = IMM_LUI_AUIPC;
		`Opcode_AUIPC:  imm_ = IMM_LUI_AUIPC;
		`Opcode_L:	 	imm_ = IMM_I;
		`Opcode_S:	 	imm_ = IMM_S;
	endcase
end

// REG_FILE

Reg_file u_Reg_file(
	.clk(clk),
	.rst(rst),
	.write_regf_en(write_regf_en_r),
	.addr_rd(addr_rd_r),
	.addr_rs1(addr_rs1_),
	.addr_rs2(addr_rs2_),
	.rd_value(rd_value_),
	
	.rs1_value(rs1_value),
	.rs2_value(rs2_value),
	.regs_31(regs_31)
);

// CONTROLLER

typedef enum {S0,S1,S2,S3} FSM_STATE;
FSM_STATE ps, ns;

always_ff @(posedge clk) begin
	if(rst)
		ps <= #1 S0;
	else
		ps <= #1 ns;
end
		
		//	combination

always_comb
begin
	rst_pc_ 			= 0;
	sel_pc_				= 0;
	flush_IFID_ 		= 0;
	flush_IDEX_ 		= 0;
	write_regf_en_ 		= 0;
	op_					= 0;
	sel_alu_a_			= 0;
	sel_alu_b_			= 0;
	sel_jump_			= 0;
	sel_rd_value_		= 0;
	write_regf_en_		= 0;
	write_ram_			= 0;	// = write_read_
	ns					= ps;
	unique case(ps)
		S0:
			begin
				flush_IFID_ = 1;
				flush_IDEX_ = 1;
				rst_pc_		= 1;
				ns = S1;
			end
		S1:
			begin
				flush_IFID_ = 1;
				flush_IDEX_ = 1;
				rst_pc_		= 1;
				ns = S2;
			end
		S2:
			begin
				unique case (opcode_)
					// I-type
					`Opcode_I:
					begin
						write_regf_en_ = 1;
							unique case(funct3_)
								`F_ADDI:			op_ = `ALUOP_ADD;
								`F_SLTI:			op_ = `ALUOP_LT;
								`F_SLTIU:			op_ = `ALUOP_LTU;
								`F_ANDI:			op_ = `ALUOP_AND;
								`F_ORI:				op_ = `ALUOP_OR;
								`F_XORI:			op_ = `ALUOP_XOR;
								`F_SLLI:			op_ = `ALUOP_SLL;
								`F_SRLI_SRAI:
								begin
									unique case(funct7_)
										`F7_SRLI: 	op_ = `ALUOP_SRL;
										`F7_SRAI: 	op_ = `ALUOP_SRA;
									endcase
								end
							endcase
					end
					// R-type, mul, div
					`Opcode_R_M:
					begin
						write_regf_en_ = 1;
						sel_alu_b_ = 1;
						unique case(funct7_)
							`F7_SUB_SRA: 
							begin
								unique case(funct3_)
									`F_ADD_SUB: 	op_ = `ALUOP_SUB;
									`F_SRL_SRA: 	op_ = `ALUOP_SRA;
								endcase
							end
							`F7_OPCODE_R:
							begin
								unique case(funct3_)
									`F_ADD_SUB:		op_ = `ALUOP_ADD;	
									`F_SLT:			op_ = `ALUOP_LT;
									`F_SLTU:		op_ = `ALUOP_LTU;
									`F_AND:			op_ = `ALUOP_AND;
									`F_OR:			op_ = `ALUOP_OR;
									`F_XOR:			op_ = `ALUOP_XOR;
									`F_SLL:			op_ = `ALUOP_SLL;
									`F_SRL_SRA:		op_ = `ALUOP_SRL;
								endcase
							end
							`F7_M:
							begin
								write_regf_en_ = 1;
								unique case(funct3_)
									`F_MUL:			sel_rd_value_ = 2;
									`F_MULHU:		sel_rd_value_ = 2;
									`F_MULHSU:		sel_rd_value_ = 2;
									`F_MULH:		sel_rd_value_ = 2;
									`F_DIV:			sel_rd_value_ = 3;
									`F_DIVU:		sel_rd_value_ = 3;
									`F_REM:			sel_rd_value_ = 3;
									`F_REMU:		sel_rd_value_ = 3;
								endcase
							end
						endcase
					end
					// B-type
					`Opcode_B:
					begin
						sel_jump_ = 1;
						unique case(funct3_)
							//等於
							`F_BEQ: begin
								if(BEQ_FLAG) begin	//x[rs1] == x[rs2] 跳躍
									sel_pc_ 	= 1;
									flush_IFID_ = 1;
									flush_IDEX_ = 1;
								end
							end
							//不等於
							`F_BNE: begin
								if(BNE_FLAG) begin	//x[rs1] != x[rs2] 跳躍
									sel_pc_ 	= 1;
									flush_IFID_ = 1;
									flush_IDEX_ = 1;
								end
							end
							`F_BLT: begin
								if(BLT_FLAG) begin	
									sel_pc_ 	= 1;
									flush_IFID_ = 1;
									flush_IDEX_ = 1;
								end
							end
							`F_BGE: begin
								if(BGE_FLAG) begin	
									sel_pc_ 	= 1;
									flush_IFID_ = 1;
									flush_IDEX_ = 1;
								end
							end
							`F_BLTU: begin
								if(BLTU_FLAG) begin	
									sel_pc_ 	= 1;
									flush_IFID_ = 1;
									flush_IDEX_ = 1;
								end
							end
							`F_BGEU: begin
								if(BGEU_FLAG) begin	
									sel_pc_ 	= 1;
									flush_IFID_ = 1;
									flush_IDEX_ = 1;
								end
							end
						endcase
					end
					// J-type
					`Opcode_JAL:
					begin
						sel_pc_ 			= 1;
						flush_IFID_ 		= 1;
						flush_IDEX_ 		= 1;
						sel_alu_a_ 			= 1;
						sel_alu_b_			= 2;
						sel_jump_			= 1;
						write_regf_en_		= 1;
						op_ 				= `ALUOP_ADD;
					end
					`Opcode_JALR:
					begin
						sel_pc_ 			= 1;
						flush_IFID_ 		= 1;
						flush_IDEX_ 		= 1;
						sel_alu_a_ 			= 1;
						sel_alu_b_			= 2;
						sel_jump_			= 0;
						write_regf_en_		= 1;
						op_ 				= `ALUOP_ADD;
					end
					`Opcode_LUI:
					begin
						sel_alu_b_			= 0;
						write_regf_en_		= 1;
						op_ 				= `ALUOP_B;
					end
					`Opcode_AUIPC:
					begin
						sel_alu_a_			= 1;
						sel_alu_b_			= 0;
						write_regf_en_		= 1;
						op_ 				= `ALUOP_ADD;
					end
					`Opcode_L:
					begin
						sel_rd_value_		= 1;
						write_regf_en_		= 1;
						unique case(funct3_)
							`F_LB:			op_ = `ALUOP_ADD;
							`F_LH:			op_ = `ALUOP_ADD;
							`F_LW:			op_ = `ALUOP_ADD;
							`F_LBU:			op_ = `ALUOP_ADD;
							`F_LHU:			op_ = `ALUOP_ADD;
						endcase
					end
					`Opcode_S:
					begin
						write_ram_ = 1;
						unique case(funct3_)
							`F_SB:			op_ = `ALUOP_ADD;
							`F_SH:			op_ = `ALUOP_ADD;
							`F_SW:			op_ = `ALUOP_ADD;
						endcase
					end
				endcase
			end
	endcase
end

// Branch Compare

assign BEQ_FLAG		= (rs1_value_ == rs2_value_);
assign BNE_FLAG 	= (rs1_value_ != rs2_value_);
assign BLT_FLAG		= ($signed(rs1_value_) < $signed(rs2_value_));
assign BGE_FLAG 	= ($signed(rs1_value_) >= $signed(rs2_value_));
assign BLTU_FLAG	= (rs1_value_ < rs2_value_);
assign BGEU_FLAG 	= (rs1_value_ >= rs2_value_);

// ID/EX

always_ff @(posedge clk)
begin
	if(rst | flush_IDEX_r)
	begin
		rs1_value_r 		<= 0;
		rs2_value_r 		<= 0;
		imm_r				<= 0;
		addr_rd_r			<= 0;
		op_r				<= 0;
		write_regf_en_r		<= 0;
		sel_alu_a_r			<= 0;
		sel_alu_b_r			<= 0;
		flush_IDEX_r		<= 0;
		flush_IFID_r		<= 0;
		sel_pc_r			<= 0;
		pc_rr				<= 0;
		sel_jump_r			<= 0;
		funct3_r			<= 0;
		write_ram_r			<= 0;
		sel_rd_value_r		<= 0;
	end
	else
	begin
		rs1_value_r 		<= rs1_value_;
		rs2_value_r 		<= rs2_value_;
		imm_r				<= imm_;
		addr_rd_r			<= addr_rd_;
		op_r				<= op_;
		write_regf_en_r		<= write_regf_en_;
		sel_alu_a_r			<= sel_alu_a_;
		sel_alu_b_r			<= sel_alu_b_;
		flush_IDEX_r		<= flush_IDEX_;
		flush_IFID_r		<= flush_IFID_;
		sel_pc_r			<= sel_pc_;
		pc_rr				<= pc_r;
		sel_jump_r			<= sel_jump_;
		funct3_r			<= funct3_;
		write_ram_r			<= write_ram_;
		sel_rd_value_r		<= sel_rd_value_;
	end
end

// ALU

always_comb begin
	unique case(sel_alu_a_r)
		0:	alu_a_	= rs1_value_r;
		1:	alu_a_	= pc_rr;
	endcase
end

always_comb begin
	unique case(sel_alu_b_r)
		0:	alu_b_	= imm_r;
		1:	alu_b_	= rs2_value_r;
		2:	alu_b_	= 32'd4;
	endcase
end

always_comb begin
	unique case(op_r)
		`ALUOP_ADD: 		alu_out = alu_a_ + alu_b_;
      	`ALUOP_SUB: 		alu_out = $signed(alu_a_) - $signed(alu_b_);
		`ALUOP_AND: 		alu_out = alu_a_ & alu_b_;	
     	 `ALUOP_OR: 		alu_out = alu_a_ | alu_b_;		
      	`ALUOP_XOR: 		alu_out = alu_a_ ^ alu_b_;		
      	`ALUOP_A: 			alu_out = alu_a_;		
      	`ALUOP_A_ADD_4: 	alu_out = alu_a_ + 4;	
      	`ALUOP_LTU: 		alu_out = alu_a_ < alu_b_;	
      	`ALUOP_LT:			alu_out = $signed(alu_a_) < $signed(alu_b_);			
      	`ALUOP_SLL:			alu_out = alu_a_ << alu_b_[4:0];		
      	`ALUOP_SRL:			alu_out = alu_a_ >> alu_b_[4:0];		
      	`ALUOP_SRA:			alu_out = $signed(alu_a_) >>> alu_b_[4:0];
      	`ALUOP_B:			alu_out = alu_b_;
		default: 			alu_out = alu_a_;
	endcase
end

// LSU
LSU LSU_1(
	.clk(clk),
	.write_ram(write_ram_r),
	.funct3(funct3_r),
	.write_data(rs2_value_r),
	.ram_addr(alu_out),

	.read_data(read_data)
);

// mul
always_comb begin
	unique case (funct3_r)
		`F_MUL:		product = $signed(rs1_value_r) * $signed(rs2_value_r);
		`F_MULH:	product = $signed(rs1_value_r) * $signed(rs2_value_r);
		`F_MULHSU:	product = $signed($signed(rs1_value_r) * rs2_value_r);
		`F_MULHU:	product = rs1_value_r * rs2_value_r;
	endcase
end
assign mul_out 	= (funct3_r == `F_MUL) ? product[31:0] : product[63:32];

// div
always_comb begin
	unique case (funct3_r)
		`F_DIV:		div_out = $signed(rs1_value_r) / $signed(rs2_value_r);
		`F_DIVU:	div_out = rs1_value_r / rs2_value_r;
		`F_REM:		div_out = $signed(rs1_value_r) % $signed(rs2_value_r);
		`F_REMU:	div_out = rs1_value_r % rs2_value_r;
	endcase
end
	
always_comb begin
	unique case(sel_rd_value_r)
		0: 	rd_value_ = alu_out;
		1: 	rd_value_ = read_data;
		2: 	rd_value_ = mul_out;
		3: 	rd_value_ = div_out;
	endcase
end

// ALU右邊的+ 
assign base_addr_ 	= sel_jump_r ? pc_rr : rs1_value_r;
assign j_addr_		= base_addr_ + imm_r;
assign jump_addr_ 	= {j_addr_[31:1], (j_addr_[0] & sel_jump_r)};

//forwarding unit
assign sel_rs1_value_ 	= write_regf_en_r & (addr_rd_r == addr_rs1_);
assign sel_rs2_value_ 	= write_regf_en_r & (addr_rd_r == addr_rs2_);
assign rs1_value_ 		= sel_rs1_value_ ? rd_value_ : rs1_value;
assign rs2_value_ 		= sel_rs2_value_ ? rd_value_ : rs2_value;

endmodule
