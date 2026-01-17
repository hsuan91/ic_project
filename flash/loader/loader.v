module loader(count_out, bit16_out, state_out, reset_out, clk_out, sram_data, sram_addr, sram_ce, flash_si, flash_cs, prog_run, reset_pic, flash_so, clk_in, reset);
output reg [13:0] sram_data;
output reg [11:0] sram_addr;
output sram_ce;
output prog_run, reset_pic;//控制PIC訊號
output [5:0]state_out;
output [4:0]bit16_out;
output reset_out, count_out;
output clk_out, flash_si, flash_cs;//控制Flash訊號
input flash_so, clk_in, reset;

reg [1:0]q;
wire clk_i;
reg [5:0] present_state, next_state;
reg [12:0] addr_count;
reg sram_ce, prog_run, reset_pic, flash_si, flash_cs;
reg bit16_count;
reg [3:0] bit16;
reg so_temp;
reg [15:0]data_temp;
wire end_2K, end_16bit;
reg [15:0] clock_counter;

parameter START_STATE_0			= 0;
parameter START_STATE_1			= 1;
parameter READ_OPCODE_STATE_0	= 2;
parameter READ_OPCODE_STATE_1	= 3;
parameter READ_OPCODE_STATE_2	= 4;
parameter READ_OPCODE_STATE_3	= 5;
parameter READ_OPCODE_STATE_4	= 6;
parameter READ_OPCODE_STATE_5	= 7;
parameter READ_OPCODE_STATE_6	= 8;
parameter READ_OPCODE_STATE_7	= 37;
parameter READ_ADDR_STATE_0		= 9;
parameter READ_ADDR_STATE_1		= 10;
parameter READ_ADDR_STATE_2		= 11;
parameter READ_ADDR_STATE_3		= 12;
parameter READ_ADDR_STATE_4		= 13;
parameter READ_ADDR_STATE_5		= 14;
parameter READ_ADDR_STATE_6		= 15;
parameter READ_ADDR_STATE_7		= 16;
parameter READ_ADDR_STATE_8		= 17;
parameter READ_ADDR_STATE_9		= 18;
parameter READ_ADDR_STATE_10	= 19;
parameter READ_ADDR_STATE_11	= 20;
parameter READ_ADDR_STATE_12	= 21;
parameter READ_ADDR_STATE_13	= 22;
parameter READ_ADDR_STATE_14	= 23;
parameter READ_ADDR_STATE_15	= 24;
parameter READ_ADDR_STATE_16	= 25;
parameter READ_ADDR_STATE_17	= 26;
parameter READ_ADDR_STATE_18	= 27;
parameter READ_ADDR_STATE_19	= 28;
parameter READ_ADDR_STATE_20	= 29;
parameter READ_ADDR_STATE_21	= 30;
parameter READ_ADDR_STATE_22	= 31;
parameter READ_ADDR_STATE_23	= 38;
parameter READ_DUMMY_0			= 39;
parameter READ_DUMMY_1			= 40;
parameter READ_DUMMY_2			= 41;
parameter READ_DUMMY_3			= 42;
parameter READ_DUMMY_4			= 43;
parameter READ_DUMMY_5			= 44;
parameter READ_DUMMY_6			= 45;
parameter READ_DUMMY_7			= 46;
parameter READ_STATE_0			= 32;
parameter READ_STATE_1			= 33;
parameter READ_STATE_2			= 34;
parameter RUN_STATE_0			= 35;
parameter RUN_STATE_1			= 36;

assign reset_out = reset;
assign state_out = present_state;
assign bit16_out = bit16;
assign count_out = end_16bit;

//assign addr_sram = addr_count[10:0];
assign end_2K = (sram_addr == 13'h800);
assign end_16bit = &bit16;


always @(posedge clk_in)
	if(reset) clock_counter <= 0;
	else clock_counter <= clock_counter + 1;
	
assign clk = clk_in;	
assign clk_out = clk;
//--------------------------------------------------------------------------
//跳狀態
always@(negedge clk)
	if(reset) present_state <= START_STATE_0;
	else present_state <= next_state;
	
//記數SRAM位置
always @(posedge clk)
	if (flash_cs) sram_addr <= 12'hFFF;
	else if(end_16bit)sram_addr <= sram_addr + 1;
	
//複製SRAM資料
always @(posedge clk)
	if(flash_cs) sram_data <= 14'h0000;
	else if(end_16bit)sram_data = data_temp[13:0];
	
//--------------------------------------------------------------------------
genvar i;
generate
	for(i=0; i<15; i=i+1) 
	begin: shift_register
		always @(posedge clk)
		begin
			data_temp[0] <= flash_so;
			data_temp[i+1] <= data_temp[i];
		end
	end
endgenerate

//--------------------------------------------------------------------------

always @(present_state or end_2K)
begin
	prog_run = 0;reset_pic = 1;sram_ce = 1;flash_cs = 1;bit16_count = 0;
	
	case(present_state) 
		START_STATE_0://0
		begin
			bit16 = 4'hf;
			flash_cs = 1;
			next_state = START_STATE_1;
			flash_si = 0;
		end
		START_STATE_1://1
		begin
			flash_cs = 1;
			next_state = READ_OPCODE_STATE_0;
			flash_si = 0;
		end
		//-----------------------------------------------------------------
		//read_opcode : 0x03
		READ_OPCODE_STATE_0://2
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_OPCODE_STATE_1;
		end

		READ_OPCODE_STATE_1://3
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_OPCODE_STATE_2;
		end
		
		READ_OPCODE_STATE_2://4
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_OPCODE_STATE_3;
		end
		
		READ_OPCODE_STATE_3://5
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_OPCODE_STATE_4;
		end
		
		READ_OPCODE_STATE_4://5
		begin
			flash_si = 1;
			flash_cs = 0;
			next_state = READ_OPCODE_STATE_5;
		end
		
		READ_OPCODE_STATE_5://6
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_OPCODE_STATE_6;
		end
	
		READ_OPCODE_STATE_6://8
		begin
			flash_si = 1;
			flash_cs = 0;
			next_state = READ_OPCODE_STATE_7;
		end
		
		READ_OPCODE_STATE_7://9
		begin
			flash_si = 1;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_0;
		end
		
		//-----------------------------------------------------------------
		//output read address(24'h000) start
		READ_ADDR_STATE_0://A
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_1;
		end
		
		READ_ADDR_STATE_1://B
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_2;
		end
		
		READ_ADDR_STATE_2://C
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_3;
		end
		
		READ_ADDR_STATE_3://D
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_4;
		end
		
		READ_ADDR_STATE_4://E
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_5;
		end
		
		READ_ADDR_STATE_5://F
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_6;
		end
		
		READ_ADDR_STATE_6://10
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_7;
		end
		
		READ_ADDR_STATE_7://11
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_8;
		end
		
		READ_ADDR_STATE_8://12
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_9;
		end
		
		READ_ADDR_STATE_9://13
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_10;
		end
		
		READ_ADDR_STATE_10://14
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_11;
		end
		
		READ_ADDR_STATE_11://15
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_12;
		end
		
		READ_ADDR_STATE_12://16
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_13;
		end
		
		READ_ADDR_STATE_13://17
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_14;
		end
		
		READ_ADDR_STATE_14://18
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_15;
		end
		
		READ_ADDR_STATE_15://19
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_16;
		end
		
		READ_ADDR_STATE_16://1A
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_17;
		end
		
		READ_ADDR_STATE_17://1B
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_18;
		end
		
		READ_ADDR_STATE_18://1C
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_19;
		end
		
		READ_ADDR_STATE_19://1D
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_20;
		end
		
		READ_ADDR_STATE_20://1E
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_21;
		end
		
		READ_ADDR_STATE_21://1F
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_22;
		end
		
		READ_ADDR_STATE_22://20
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_ADDR_STATE_23;
		end
		
		READ_ADDR_STATE_23://20
		begin
			flash_si = 0;
			flash_cs = 0;
			next_state = READ_DUMMY_0;
		end
		//output read address end
		//-----------------------------------------------------------------
		//output read address(24'h000) start
		READ_DUMMY_0:
		begin
			flash_cs = 0;
			next_state = READ_DUMMY_1;
		end
		
		READ_DUMMY_1:
		begin
			flash_cs = 0;
			next_state = READ_DUMMY_2;
		end
		
		READ_DUMMY_2:
		begin
			flash_cs = 0;
			next_state = READ_DUMMY_3;
		end
		
		READ_DUMMY_3:
		begin
			flash_cs = 0;
			next_state = READ_DUMMY_4;
		end
		
		READ_DUMMY_4:
		begin
			flash_cs = 0;
			next_state = READ_DUMMY_5;
		end
		
		READ_DUMMY_5:
		begin
			flash_cs = 0;
			next_state = READ_DUMMY_6;
		end
		
		READ_DUMMY_6:
		begin
			flash_cs = 0;
			next_state = READ_DUMMY_7;
		end
		
		READ_DUMMY_7:
		begin
			flash_cs = 0;
			next_state = READ_STATE_0;
		end
		//-----------------------------------------------------------------

		READ_STATE_0://21
		begin
			flash_cs = 0;
			so_temp = flash_so;
			next_state = READ_STATE_1;
		end
		
		READ_STATE_1://22
		begin
			flash_cs = 0;
			
				so_temp = flash_so;
				bit16 = bit16 + 1'b1;
				sram_ce = ~end_16bit;
				next_state = READ_STATE_2;
		end

		READ_STATE_2://23
		begin
			flash_cs = 0;
			if(end_2K)next_state = RUN_STATE_0;
			else
			begin
				so_temp = flash_so;
				bit16 = bit16 + 1'b1;
				next_state = READ_STATE_1;
			end
		end
		
		RUN_STATE_0://24
		begin
			prog_run = 1;
			sram_ce = 0;
			next_state = RUN_STATE_1;
		end

		RUN_STATE_1://25
		begin
			prog_run = 1;
			sram_ce = 0;
			reset_pic = 0;  //PIC running.
			next_state = RUN_STATE_1;
		end

		
		default:
		begin
			prog_run = 1;
			sram_ce = 0;
			reset_pic = 0;  //PIC running.
			next_state = RUN_STATE_0;
		end
	endcase
end

endmodule