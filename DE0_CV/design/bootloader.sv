`timescale 1ns/100ps

module bootloader (
    // SRAM interface
    output logic [INST_WIDTH-1:0] sram_data,
    output logic [INST_WIDTH-1:0] sram_addr,
    output logic                  sram_we,      // active low write enable

    // Config data                
    output logic [INST_WIDTH-1:0] config_data,

    // Flash interface            
    output logic                  flash_si,     // MOSI
    output logic                  flash_cs,     // CS
    input  logic                  flash_so,     // MISO

    // Control signals            
    output logic                  prog_run,     // release MCU from reset
    //output logic                reset_riscv,

    // Clock and reset            
    input logic                   clk,
    //input logic                 reset_frommcu,
    input logic                   reset
);

	localparam INST_WIDTH          = 'd32;
	localparam INST_MEM_CAPACITY   = 'h400;     // 1024

    // State enumeration
    typedef enum logic [5:0] {
        START_STATE_0           = 6'd0,
        START_STATE_1           = 6'd1,
        START_STATE_2           = 6'd2,
        START_STATE_3           = 6'd3,
        START_STATE_4           = 6'd4,
        START_STATE_5           = 6'd5,
        READ_OPCODE_STATE_0     = 6'd6,
        READ_OPCODE_STATE_1     = 6'd7,
        READ_OPCODE_STATE_2     = 6'd8,
        READ_OPCODE_STATE_3     = 6'd9,
        READ_OPCODE_STATE_4     = 6'd10,
        READ_OPCODE_STATE_5     = 6'd11,
        READ_OPCODE_STATE_6     = 6'd12,
        READ_OPCODE_STATE_7     = 6'd13,
        READ_ADDR_STATE_0       = 6'd14,
        READ_ADDR_STATE_1       = 6'd15,
        READ_ADDR_STATE_2       = 6'd16,
        READ_ADDR_STATE_3       = 6'd17,
        READ_ADDR_STATE_4       = 6'd18,
        READ_ADDR_STATE_5       = 6'd19,
        READ_ADDR_STATE_6       = 6'd20,
        READ_ADDR_STATE_7       = 6'd21,
        READ_ADDR_STATE_8       = 6'd22,
        READ_ADDR_STATE_9       = 6'd23,
        READ_ADDR_STATE_10      = 6'd24,
        READ_ADDR_STATE_11      = 6'd25,
        READ_ADDR_STATE_12      = 6'd26,
        READ_ADDR_STATE_13      = 6'd27,
        READ_ADDR_STATE_14      = 6'd28,
        READ_ADDR_STATE_15      = 6'd29,
        READ_ADDR_STATE_16      = 6'd30,
        READ_ADDR_STATE_17      = 6'd31,
        READ_ADDR_STATE_18      = 6'd32,
        READ_ADDR_STATE_19      = 6'd33,
        READ_ADDR_STATE_20      = 6'd34,
        READ_ADDR_STATE_21      = 6'd35,
        READ_ADDR_STATE_22      = 6'd36,
        READ_ADDR_STATE_23      = 6'd37,
        READ_DUMMY_STATE_0      = 6'd38,
        READ_DUMMY_STATE_1      = 6'd39,
        READ_DUMMY_STATE_2      = 6'd40,
        READ_DUMMY_STATE_3      = 6'd41,
        READ_DUMMY_STATE_4      = 6'd42,
        READ_DUMMY_STATE_5      = 6'd43,
        READ_DUMMY_STATE_6      = 6'd44,
        READ_DUMMY_STATE_7      = 6'd45,
        READ_STATE_0            = 6'd46,
        READ_STATE_1            = 6'd47,
        READ_STATE_2            = 6'd48,
        RUN_STATE_0             = 6'd49,
        RUN_STATE_1             = 6'd50
    } state_t;

    // State machine registers
    state_t present_state, next_state;
    
    // Internal registers
    logic [INST_WIDTH-1:0] sram_addr_temp;
	logic [INST_WIDTH-1:0] data_temp;       
	logic [4:0]            bit32;           // Counts bits shifted in
    logic                  wait_bit32;
    logic                  config_flag;
	logic                  flash_cs_tmp;
	logic                  flash_si_tmp;

    // Combinational logic
    logic end_1K, end_32bit;
	assign end_1K    = (sram_addr_temp == INST_MEM_CAPACITY);
    assign end_32bit = &bit32;
    //assign reset     = reset_frommcu | cold_boot_reset;
    
    // Assign SRAM address
    assign sram_addr = sram_addr_temp-1;
	
	always_ff @(negedge clk) begin
	    flash_cs <= flash_cs_tmp;
		flash_si <= flash_si_tmp;
	end

    // SRAM address counter
    always_ff @(posedge clk) begin
        if (flash_cs_tmp) 
            //sram_addr_temp <= 11'h7FF;
			sram_addr_temp <= 0;
        else if (end_32bit)                 // increase address after 32 bits received
            sram_addr_temp <= sram_addr_temp + 'd4;
    end

    // SRAM data handling
    always_ff @(posedge clk) begin
        if (flash_cs_tmp) begin
            sram_data <= 'd0;
            config_flag <= 1'b0;
        end
        else if (sram_addr == 'h3ff && end_32bit == 'b1 && config_flag) begin       //wrong
            config_data <= data_temp;
        end
        else if (end_32bit) begin
            sram_data <= data_temp[INST_WIDTH-1:0];
            config_flag <= 1'b1;
        end
    end

    // Data shift register
    always_ff @(posedge clk) begin
        data_temp <= {data_temp[30:0], flash_so};     // shift in data from flash
    end

    // State machine - state transitions
    always_ff @(negedge clk or posedge reset) begin
        if (reset) begin
            present_state <= START_STATE_0;
        end
        else begin
            unique case (present_state)
                START_STATE_0:          present_state <= START_STATE_1;
                START_STATE_1:          present_state <= START_STATE_2;
                START_STATE_2:          present_state <= START_STATE_3;
                START_STATE_3:          present_state <= START_STATE_4;
                START_STATE_4:          present_state <= READ_OPCODE_STATE_0;
                READ_OPCODE_STATE_0:    present_state <= READ_OPCODE_STATE_1;
                READ_OPCODE_STATE_1:    present_state <= READ_OPCODE_STATE_2;
                READ_OPCODE_STATE_2:    present_state <= READ_OPCODE_STATE_3;
                READ_OPCODE_STATE_3:    present_state <= READ_OPCODE_STATE_4;
                READ_OPCODE_STATE_4:    present_state <= READ_OPCODE_STATE_5;
                READ_OPCODE_STATE_5:    present_state <= READ_OPCODE_STATE_6;
                READ_OPCODE_STATE_6:    present_state <= READ_OPCODE_STATE_7;
                READ_OPCODE_STATE_7:    present_state <= READ_ADDR_STATE_0;
                READ_ADDR_STATE_0:      present_state <= READ_ADDR_STATE_1;
                READ_ADDR_STATE_1:      present_state <= READ_ADDR_STATE_2;
                READ_ADDR_STATE_2:      present_state <= READ_ADDR_STATE_3;
                READ_ADDR_STATE_3:      present_state <= READ_ADDR_STATE_4;
                READ_ADDR_STATE_4:      present_state <= READ_ADDR_STATE_5;
                READ_ADDR_STATE_5:      present_state <= READ_ADDR_STATE_6;
                READ_ADDR_STATE_6:      present_state <= READ_ADDR_STATE_7;
                READ_ADDR_STATE_7:      present_state <= READ_ADDR_STATE_8;
                READ_ADDR_STATE_8:      present_state <= READ_ADDR_STATE_9;
                READ_ADDR_STATE_9:      present_state <= READ_ADDR_STATE_10;
                READ_ADDR_STATE_10:     present_state <= READ_ADDR_STATE_11;
                READ_ADDR_STATE_11:     present_state <= READ_ADDR_STATE_12;
                READ_ADDR_STATE_12:     present_state <= READ_ADDR_STATE_13;
                READ_ADDR_STATE_13:     present_state <= READ_ADDR_STATE_14;
                READ_ADDR_STATE_14:     present_state <= READ_ADDR_STATE_15;
                READ_ADDR_STATE_15:     present_state <= READ_ADDR_STATE_16;
                READ_ADDR_STATE_16:     present_state <= READ_ADDR_STATE_17;
                READ_ADDR_STATE_17:     present_state <= READ_ADDR_STATE_18;
                READ_ADDR_STATE_18:     present_state <= READ_ADDR_STATE_19;
                READ_ADDR_STATE_19:     present_state <= READ_ADDR_STATE_20;
                READ_ADDR_STATE_20:     present_state <= READ_ADDR_STATE_21;
                READ_ADDR_STATE_21:     present_state <= READ_ADDR_STATE_22;
                READ_ADDR_STATE_22:     present_state <= READ_ADDR_STATE_23;
                READ_ADDR_STATE_23:     present_state <= READ_DUMMY_STATE_0;
                READ_DUMMY_STATE_0:     present_state <= READ_DUMMY_STATE_1;
                READ_DUMMY_STATE_1:     present_state <= READ_DUMMY_STATE_2;
                READ_DUMMY_STATE_2:     present_state <= READ_DUMMY_STATE_3;
                READ_DUMMY_STATE_3:     present_state <= READ_DUMMY_STATE_4;
                READ_DUMMY_STATE_4:     present_state <= READ_DUMMY_STATE_5;
                READ_DUMMY_STATE_5:     present_state <= READ_DUMMY_STATE_6;
                READ_DUMMY_STATE_6:     present_state <= READ_DUMMY_STATE_7;
                READ_DUMMY_STATE_7:     present_state <= READ_STATE_0;
                READ_STATE_0:           present_state <= READ_STATE_1;
                READ_STATE_1:           present_state <= READ_STATE_2;
                READ_STATE_2:           present_state <= end_1K ? RUN_STATE_0 : READ_STATE_1;
                RUN_STATE_0:            present_state <= RUN_STATE_1;
                RUN_STATE_1:            present_state <= RUN_STATE_1;
                default:                present_state <= RUN_STATE_0;
            endcase
        end
    end

    // State machine - output logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            prog_run        <= 1'b0;
            //reset_riscv   <= 1'b1;
            sram_we         <= 1'b1;
            flash_cs_tmp    <= 1'b1;
            flash_si_tmp    <= 1'b0;
            wait_bit32      <= 1'b0;
            bit32           <= 5'h0;
        end
        else begin
            unique case (present_state)
                // Start states
                START_STATE_0, START_STATE_1, START_STATE_2, 
                START_STATE_3, START_STATE_4, START_STATE_5: begin
                    flash_cs_tmp <= 1'b1;
                    flash_si_tmp <= 1'b0;
                end

                // Read opcode states (0x0B = 0000_1011)
                READ_OPCODE_STATE_0, READ_OPCODE_STATE_1, 
                READ_OPCODE_STATE_2, READ_OPCODE_STATE_3: begin
                    flash_si_tmp <= 1'b0;
                    flash_cs_tmp <= 1'b0;
                end

                READ_OPCODE_STATE_4: begin
                    flash_si_tmp <= 1'b1;
                    flash_cs_tmp <= 1'b0;
                end

                READ_OPCODE_STATE_5: begin
                    flash_si_tmp <= 1'b0;
                    flash_cs_tmp <= 1'b0;
                end

                READ_OPCODE_STATE_6: begin
                    flash_si_tmp <= 1'b1;
                    flash_cs_tmp <= 1'b0;
                end

                READ_OPCODE_STATE_7: begin
                    flash_si_tmp <= 1'b1;
                    flash_cs_tmp <= 1'b0;
                end

                // Read address states (24'h000)
                READ_ADDR_STATE_0, READ_ADDR_STATE_1, READ_ADDR_STATE_2, READ_ADDR_STATE_3,
                READ_ADDR_STATE_4, READ_ADDR_STATE_5, READ_ADDR_STATE_6, READ_ADDR_STATE_7,
                READ_ADDR_STATE_8, READ_ADDR_STATE_9, READ_ADDR_STATE_10, READ_ADDR_STATE_11,
                READ_ADDR_STATE_12, READ_ADDR_STATE_13, READ_ADDR_STATE_14, READ_ADDR_STATE_15,
                READ_ADDR_STATE_16, READ_ADDR_STATE_17, READ_ADDR_STATE_18, READ_ADDR_STATE_19,
                READ_ADDR_STATE_20, READ_ADDR_STATE_21, READ_ADDR_STATE_22, READ_ADDR_STATE_23: begin
                    flash_si_tmp <= 1'b0;
                    flash_cs_tmp <= 1'b0;
                end

                // Read dummy states (8'h00)
                READ_DUMMY_STATE_0, READ_DUMMY_STATE_1, READ_DUMMY_STATE_2, READ_DUMMY_STATE_3,
                READ_DUMMY_STATE_4, READ_DUMMY_STATE_5, READ_DUMMY_STATE_6, READ_DUMMY_STATE_7: begin
                    flash_cs_tmp <= 1'b0;
                end

                // Read data states
                READ_STATE_0: begin
                    flash_cs_tmp <= 1'b0;
                end

                READ_STATE_1: begin
                    flash_cs_tmp <= 1'b0;
                    sram_we <= ~end_32bit;
                    
                    if (~wait_bit32) 
                        bit32 <= 5'h0;
                    else 
                        bit32 <= bit32 + 1'b1;                   
                end

                READ_STATE_2: begin
                    flash_cs_tmp <= 1'b0;
                    wait_bit32 <= 1'b1;
                    bit32 <= bit32 + 1'b1;
                end

                // Run states - MCU running
                RUN_STATE_0: begin
                    prog_run <= 1'b1;
					sram_we <= 1'b1;
                    flash_cs_tmp <= 1'b1;      //instruction read finished
                end

                RUN_STATE_1: begin
                    prog_run <= 1'b1;
                    //reset_riscv <= 1'b0;  // MCU running
                end

                default: begin
                    prog_run <= 1'b1;
                    sram_we <= 1'b1;
                    //reset_riscv <= 1'b0;  // MCU running
                end
            endcase
        end
    end

endmodule