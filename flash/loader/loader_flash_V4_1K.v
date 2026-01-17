module loader(sram_data, sram_addr, sram_we, config_data, flash_si, flash_cs, flash_so, prog_run, reset_pic, clk, reset_from8051, cold_boot_reset);
output reg [13:0] sram_data;
output [9:0] sram_addr;
output sram_we;
output prog_run, reset_pic;//控制PIC訊號
output reg [15:0] config_data;
output flash_si, flash_cs;//控制Flash訊號
input flash_so, clk, reset_from8051, cold_boot_reset;

reg [1:0]q;
wire clk_i;
reg [5:0] present_state, next_state;
reg [12:0] addr_count;
reg sram_we, prog_run, reset_pic, flash_si, flash_cs, reset_counter;
reg bit16_count;
reg [3:0] bit16;
reg [15:0] data_temp;
wire end_1K, end_16bit;
reg [15:0] clock_counter;
reg wait_bit16, config_flag;
wire reset;
reg [10:0] sram_addr_temp;

parameter START_STATE_0			= 0;
parameter START_STATE_1			= 1;
parameter START_STATE_2			= 2;
parameter START_STATE_3			= 3;
parameter START_STATE_4			= 4;
parameter START_STATE_5			= 5;
parameter READ_OPCODE_STATE_0	= 6;
parameter READ_OPCODE_STATE_1	= 7;
parameter READ_OPCODE_STATE_2	= 8;
parameter READ_OPCODE_STATE_3	= 9;
parameter READ_OPCODE_STATE_4	= 10;
parameter READ_OPCODE_STATE_5	= 11;
parameter READ_OPCODE_STATE_6	= 12;
parameter READ_OPCODE_STATE_7	= 13;
parameter READ_ADDR_STATE_0		= 14;
parameter READ_ADDR_STATE_1		= 15;
parameter READ_ADDR_STATE_2		= 16;
parameter READ_ADDR_STATE_3		= 17;
parameter READ_ADDR_STATE_4		= 18;
parameter READ_ADDR_STATE_5		= 19;
parameter READ_ADDR_STATE_6		= 20;
parameter READ_ADDR_STATE_7		= 21;
parameter READ_ADDR_STATE_8		= 22;
parameter READ_ADDR_STATE_9		= 23;
parameter READ_ADDR_STATE_10	= 24;
parameter READ_ADDR_STATE_11	= 25;
parameter READ_ADDR_STATE_12	= 26;
parameter READ_ADDR_STATE_13	= 27;
parameter READ_ADDR_STATE_14	= 28;
parameter READ_ADDR_STATE_15	= 29;
parameter READ_ADDR_STATE_16	= 30;
parameter READ_ADDR_STATE_17	= 31;
parameter READ_ADDR_STATE_18	= 32;
parameter READ_ADDR_STATE_19	= 33;
parameter READ_ADDR_STATE_20	= 34;
parameter READ_ADDR_STATE_21	= 35;
parameter READ_ADDR_STATE_22	= 36;
parameter READ_ADDR_STATE_23	= 37;
parameter READ_DUMMY_STATE_0	= 38;
parameter READ_DUMMY_STATE_1	= 39;
parameter READ_DUMMY_STATE_2	= 40;
parameter READ_DUMMY_STATE_3	= 41;
parameter READ_DUMMY_STATE_4	= 42;
parameter READ_DUMMY_STATE_5	= 43;
parameter READ_DUMMY_STATE_6	= 44;
parameter READ_DUMMY_STATE_7	= 45;
parameter READ_STATE_0			= 46;
parameter READ_STATE_1			= 47;
parameter READ_STATE_2			= 48;
parameter RUN_STATE_0			= 49;
parameter RUN_STATE_1			= 50;

assign end_1K = (sram_addr_temp == 11'h400);
assign end_16bit = &bit16;
assign reset = reset_from8051 | cold_boot_reset;
assign sram_addr = sram_addr_temp[9:0];

// always @(posedge clk_in)
	// if(reset) clock_counter <= 0;
	// else clock_counter <= clock_counter + 1;
	
// assign clk = clk_in;
	
//記數SRAM位置
always @(posedge clk)
	if (flash_cs) sram_addr_temp <= 11'h7FF;
	else if(end_16bit)sram_addr_temp <= sram_addr_temp + 1;
	
//複製SRAM資料
always @(posedge clk)
	if(flash_cs) 
	begin
		sram_data <= 14'h0000;
		config_flag <= 0;
	end
	else if(sram_addr==10'h3ff & end_16bit==1 & config_flag)config_data <= data_temp;
	else if(end_16bit)
	begin
		sram_data <= data_temp[13:0];
		config_flag <= 1;
	end
	
//--------------------------------------------------------------------------
// 資料SHIFT暫存器
// genvar i;
// generate
	// for(i=0; i<15; i=i+1) 
	// begin: shift_register
		// always @(posedge clk)
		// begin
			// data_temp[0] <= flash_so;
			// data_temp[i+1] <= data_temp[i];
		// end
	// end
// endgenerate

always @(posedge clk)
	data_temp <= {data_temp[14:0], flash_so};



//--------------------------------------------------------------------------
// 跳狀態
always@(negedge clk or posedge reset)
begin
	if(reset) present_state <= START_STATE_0;
	else 
		case (present_state)
			START_STATE_0:				present_state <= START_STATE_1;
			START_STATE_1:				present_state <= START_STATE_2;
			START_STATE_2:				present_state <= START_STATE_3;
			START_STATE_3:				present_state <= START_STATE_4;
			START_STATE_4:				present_state <= READ_OPCODE_STATE_0;
			READ_OPCODE_STATE_0:		present_state <= READ_OPCODE_STATE_1;
			READ_OPCODE_STATE_1:		present_state <= READ_OPCODE_STATE_2;
			READ_OPCODE_STATE_2:		present_state <= READ_OPCODE_STATE_3;
			READ_OPCODE_STATE_3:		present_state <= READ_OPCODE_STATE_4;
			READ_OPCODE_STATE_4:		present_state <= READ_OPCODE_STATE_5;
			READ_OPCODE_STATE_5:		present_state <= READ_OPCODE_STATE_6;
			READ_OPCODE_STATE_6:		present_state <= READ_OPCODE_STATE_7;
			READ_OPCODE_STATE_7:		present_state <= READ_ADDR_STATE_0;
			READ_ADDR_STATE_0:			present_state <= READ_ADDR_STATE_1;
			READ_ADDR_STATE_1:			present_state <= READ_ADDR_STATE_2;
			READ_ADDR_STATE_2:			present_state <= READ_ADDR_STATE_3;
			READ_ADDR_STATE_3:			present_state <= READ_ADDR_STATE_4;
			READ_ADDR_STATE_4:			present_state <= READ_ADDR_STATE_5;
			READ_ADDR_STATE_5:			present_state <= READ_ADDR_STATE_6;
			READ_ADDR_STATE_6:			present_state <= READ_ADDR_STATE_7;
			READ_ADDR_STATE_7:			present_state <= READ_ADDR_STATE_8;
			READ_ADDR_STATE_8:			present_state <= READ_ADDR_STATE_9;
			READ_ADDR_STATE_9:			present_state <= READ_ADDR_STATE_10;
			READ_ADDR_STATE_10:			present_state <= READ_ADDR_STATE_11;
			READ_ADDR_STATE_11:			present_state <= READ_ADDR_STATE_12;
			READ_ADDR_STATE_12:			present_state <= READ_ADDR_STATE_13;
			READ_ADDR_STATE_13:			present_state <= READ_ADDR_STATE_14;
			READ_ADDR_STATE_14:			present_state <= READ_ADDR_STATE_15;
			READ_ADDR_STATE_15:			present_state <= READ_ADDR_STATE_16;
			READ_ADDR_STATE_16:			present_state <= READ_ADDR_STATE_17;
			READ_ADDR_STATE_17:			present_state <= READ_ADDR_STATE_18;
			READ_ADDR_STATE_18:			present_state <= READ_ADDR_STATE_19;
			READ_ADDR_STATE_19:			present_state <= READ_ADDR_STATE_20;
			READ_ADDR_STATE_20:			present_state <= READ_ADDR_STATE_21;
			READ_ADDR_STATE_21:			present_state <= READ_ADDR_STATE_22;
			READ_ADDR_STATE_22:			present_state <= READ_ADDR_STATE_23;
			READ_ADDR_STATE_23:			present_state <= READ_DUMMY_STATE_0;
			READ_DUMMY_STATE_0:			present_state <= READ_DUMMY_STATE_1;
			READ_DUMMY_STATE_1:			present_state <= READ_DUMMY_STATE_2;
			READ_DUMMY_STATE_2:			present_state <= READ_DUMMY_STATE_3;
			READ_DUMMY_STATE_3:			present_state <= READ_DUMMY_STATE_4;
			READ_DUMMY_STATE_4:			present_state <= READ_DUMMY_STATE_5;
			READ_DUMMY_STATE_5:			present_state <= READ_DUMMY_STATE_6;
			READ_DUMMY_STATE_6:			present_state <= READ_DUMMY_STATE_7;
			READ_DUMMY_STATE_7:			present_state <= READ_STATE_0;
			READ_STATE_0:				present_state <= READ_STATE_1;
			READ_STATE_1:				present_state <= READ_STATE_2;
			READ_STATE_2:				if(end_1K)present_state <= RUN_STATE_0;
										else present_state <= READ_STATE_1;
			RUN_STATE_0:				present_state <= RUN_STATE_1;
			RUN_STATE_1:				present_state <= RUN_STATE_1;
			default:					present_state <= RUN_STATE_0;
		endcase
end

//--------------------------------------------------------------------------
// 控制訊號
always@(posedge clk or posedge reset)
begin
	if(reset)begin prog_run <= 0;reset_pic <= 1;sram_we <= 1;flash_cs <= 1;bit16_count <= 0;flash_si <= 0; wait_bit16 = 0; bit16 <= 4'h0; end
	
	else
		case(present_state)
			START_STATE_0, START_STATE_1, START_STATE_2, START_STATE_3, START_STATE_4, START_STATE_5:
			begin
				flash_cs <= 1;
				flash_si <= 0;
			end
			//-----------------------------------------------------------------
			//read_opcode : 0x0B
			READ_OPCODE_STATE_0, READ_OPCODE_STATE_1, READ_OPCODE_STATE_2, READ_OPCODE_STATE_3:
			begin
				flash_si <= 0;
				flash_cs <= 0;
			end
			
			READ_OPCODE_STATE_4://5
			begin
				flash_si <= 1;
				flash_cs <= 0;
			end
			
			READ_OPCODE_STATE_5://6
			begin
				flash_si <= 0;
				flash_cs <= 0;
			end
		
			READ_OPCODE_STATE_6://8
			begin
				flash_si <= 1;
				flash_cs <= 0;
			end
			
			READ_OPCODE_STATE_7://9
			begin
				flash_si <= 1;
				flash_cs <= 0;
			end
		
			//-----------------------------------------------------------------
			//output read address(24'h000) start
			READ_ADDR_STATE_0, READ_ADDR_STATE_1, READ_ADDR_STATE_2, READ_ADDR_STATE_3, READ_ADDR_STATE_4, READ_ADDR_STATE_5, 
			READ_ADDR_STATE_6, READ_ADDR_STATE_7, READ_ADDR_STATE_8, READ_ADDR_STATE_9, READ_ADDR_STATE_10, READ_ADDR_STATE_11, 
			READ_ADDR_STATE_12, READ_ADDR_STATE_13, READ_ADDR_STATE_14, READ_ADDR_STATE_15, READ_ADDR_STATE_16, READ_ADDR_STATE_17, 
			READ_ADDR_STATE_18, READ_ADDR_STATE_19, READ_ADDR_STATE_20, READ_ADDR_STATE_21, READ_ADDR_STATE_22, READ_ADDR_STATE_23:
			begin
				flash_si <= 0;
				flash_cs <= 0;
			end
			//output read address end
			//-----------------------------------------------------------------
			//output dummy(8'h00) start
			READ_DUMMY_STATE_0, READ_DUMMY_STATE_1, READ_DUMMY_STATE_2, READ_DUMMY_STATE_3, READ_DUMMY_STATE_4, READ_DUMMY_STATE_5, READ_DUMMY_STATE_6, READ_DUMMY_STATE_7:
			begin
				flash_cs <= 0;
			end
			//output dummy end
			//-----------------------------------------------------------------
			//read 2k start
			READ_STATE_0://21
			begin
				flash_cs <= 0;
			end
			
			READ_STATE_1://22
			begin
				flash_cs <= 0;
				if(~wait_bit16)bit16 <= 4'h0;
				else bit16 <= bit16 + 1'b1;
				if(sram_addr_temp == 12'h7ff)sram_we <= 1;
				else sram_we <= ~end_16bit;
			end

			READ_STATE_2://23
			begin
				flash_cs <= 0;
				if(end_1K)next_state <= RUN_STATE_0;
				else
				begin
					wait_bit16 <= 1;
					bit16 <= bit16 + 1'b1;
				end
			end
			//read end
			//-----------------------------------------------------------------
			//PIC running.
			RUN_STATE_0://24
			begin
				prog_run <= 1;
				sram_we <= 1;
			end

			RUN_STATE_1://25
			begin
				prog_run <= 1;
				reset_pic <= 0;  //PIC running.
			end

			
			default:
			begin
				prog_run <= 1;
				sram_we <= 1;
				reset_pic <= 0;  //PIC running.
			end
			
		endcase
end


endmodule