module loader(sram_data, sram_addr, sram_we, config_data, flash_si, flash_cs, flash_so, flash_sck, prog_run, reset_pic, clk, cold_boot_reset);
output reg [13:0] sram_data;
output [10:0] sram_addr;
output sram_we;
output prog_run, reset_pic;//控制PIC訊號
output reg [15:0] config_data;
output flash_si, flash_cs, flash_sck;//控制Flash訊號
input flash_so, clk, cold_boot_reset;

reg [1:0]q;
wire clk_i;
reg [6:0] present_state;
reg [12:0] addr_count;
reg sram_we, prog_run, reset_pic, flash_si, flash_cs, flash_sck;
reg [1:0]bit16_count;
reg [3:0] bit16;
reg [15:0] data_temp;
wire end_2K, end_16bit;
reg wait_bit16, config_flag;
wire reset;
reg [11:0] sram_addr_temp;

parameter START_STATE_0			= 0;
parameter START_STATE_1			= 1;
parameter START_STATE_2			= 2;
parameter START_STATE_3			= 3;
parameter START_STATE_4			= 4;
parameter START_STATE_5			= 5;
parameter START_STATE_6			= 6;
parameter START_STATE_7			= 7;
parameter READ_OPCODE_STATE_0	= 8;
parameter READ_OPCODE_STATE_1	= 9;
parameter READ_OPCODE_STATE_2	= 10;
parameter READ_OPCODE_STATE_3	= 11;
parameter READ_OPCODE_STATE_4	= 12;
parameter READ_OPCODE_STATE_5	= 13;
parameter READ_OPCODE_STATE_6	= 14;
parameter READ_OPCODE_STATE_7	= 15;
parameter READ_OPCODE_STATE_8	= 16;
parameter READ_OPCODE_STATE_9	= 17;
parameter READ_OPCODE_STATE_10	= 18;
parameter READ_OPCODE_STATE_11	= 19;
parameter READ_OPCODE_STATE_12	= 20;
parameter READ_OPCODE_STATE_13	= 21;
parameter READ_OPCODE_STATE_14	= 22;
parameter READ_OPCODE_STATE_15	= 23;
parameter READ_ADDR_STATE_0		= 24;
parameter READ_ADDR_STATE_1		= 25;
parameter READ_ADDR_STATE_2		= 26;
parameter READ_ADDR_STATE_3		= 27;
parameter READ_ADDR_STATE_4		= 28;
parameter READ_ADDR_STATE_5		= 29;
parameter READ_ADDR_STATE_6		= 30;
parameter READ_ADDR_STATE_7		= 31;
parameter READ_ADDR_STATE_8		= 32;
parameter READ_ADDR_STATE_9		= 33;
parameter READ_ADDR_STATE_10	= 34;
parameter READ_ADDR_STATE_11	= 35;
parameter READ_ADDR_STATE_12	= 36;
parameter READ_ADDR_STATE_13	= 37;
parameter READ_ADDR_STATE_14	= 38;
parameter READ_ADDR_STATE_15	= 39;
parameter READ_ADDR_STATE_16	= 40;
parameter READ_ADDR_STATE_17	= 41;
parameter READ_ADDR_STATE_18	= 42;
parameter READ_ADDR_STATE_19	= 43;
parameter READ_ADDR_STATE_20	= 44;
parameter READ_ADDR_STATE_21	= 45;
parameter READ_ADDR_STATE_22	= 46;
parameter READ_ADDR_STATE_23	= 47;
parameter READ_ADDR_STATE_24	= 48;
parameter READ_ADDR_STATE_25	= 49;
parameter READ_ADDR_STATE_26	= 50;
parameter READ_ADDR_STATE_27	= 51;
parameter READ_ADDR_STATE_28	= 52;
parameter READ_ADDR_STATE_29	= 53;
parameter READ_ADDR_STATE_30	= 54;
parameter READ_ADDR_STATE_31	= 55;
parameter READ_ADDR_STATE_32	= 56;
parameter READ_ADDR_STATE_33	= 57;
parameter READ_ADDR_STATE_34	= 58;
parameter READ_ADDR_STATE_35	= 59;
parameter READ_ADDR_STATE_36	= 60;
parameter READ_ADDR_STATE_37	= 61;
parameter READ_ADDR_STATE_38	= 62;
parameter READ_ADDR_STATE_39	= 63;
parameter READ_ADDR_STATE_40	= 64;
parameter READ_ADDR_STATE_41	= 65;
parameter READ_ADDR_STATE_42	= 66;
parameter READ_ADDR_STATE_43	= 67;
parameter READ_ADDR_STATE_44	= 68;
parameter READ_ADDR_STATE_45	= 69;
parameter READ_ADDR_STATE_46	= 70;
parameter READ_ADDR_STATE_47	= 71;
parameter READ_DUMMY_STATE_0	= 72;
parameter READ_DUMMY_STATE_1	= 73;
parameter READ_DUMMY_STATE_2	= 74;
parameter READ_DUMMY_STATE_3	= 75;
parameter READ_DUMMY_STATE_4	= 76;
parameter READ_DUMMY_STATE_5	= 77;
parameter READ_DUMMY_STATE_6	= 78;
parameter READ_DUMMY_STATE_7	= 79;
parameter READ_DUMMY_STATE_8	= 80;
parameter READ_DUMMY_STATE_9	= 81;
parameter READ_DUMMY_STATE_10	= 82;
parameter READ_DUMMY_STATE_11	= 83;
parameter READ_DUMMY_STATE_12	= 84;
parameter READ_DUMMY_STATE_13	= 85;
parameter READ_DUMMY_STATE_14	= 86;
parameter READ_DUMMY_STATE_15	= 87;
parameter READ_STATE_0			= 88;
parameter READ_STATE_1			= 89;
parameter READ_STATE_2			= 90;
parameter READ_STATE_3			= 91;
parameter RUN_STATE_0			= 92;
parameter RUN_STATE_1			= 93;

assign end_2K = (sram_addr_temp == 12'h800);
assign end_16bit = &bit16;
assign reset = cold_boot_reset;
assign sram_addr = sram_addr_temp[10:0];
	
// assign clk = clk_in;
	
always @(posedge clk)
	if(reset) bit16_count <= 0;
	else if(end_16bit) bit16_count <= bit16_count + 1;
	else bit16_count <= 0;
	
//記數SRAM位置
always @(posedge clk)
	if (flash_cs) sram_addr_temp <= 12'hFFF;
	else if(bit16_count[0])sram_addr_temp <= sram_addr_temp + 1;
	
//複製SRAM資料
always @(posedge clk)
	if(flash_cs) 
	begin
		sram_data <= 14'h0000;
		config_flag <= 0;
	end
	else if(sram_addr==12'h7ff & bit16_count[0] & config_flag)config_data <= data_temp;
	else if(bit16_count[0])
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

always @(posedge flash_sck)
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
			START_STATE_4:				present_state <= START_STATE_5;
			START_STATE_5:				present_state <= START_STATE_6;
			START_STATE_6:				present_state <= START_STATE_7;
			START_STATE_7:				present_state <= READ_OPCODE_STATE_0;
			READ_OPCODE_STATE_0:		present_state <= READ_OPCODE_STATE_1;
			READ_OPCODE_STATE_1:		present_state <= READ_OPCODE_STATE_2;
			READ_OPCODE_STATE_2:		present_state <= READ_OPCODE_STATE_3;
			READ_OPCODE_STATE_3:		present_state <= READ_OPCODE_STATE_4;
			READ_OPCODE_STATE_4:		present_state <= READ_OPCODE_STATE_5;
			READ_OPCODE_STATE_5:		present_state <= READ_OPCODE_STATE_6;
			READ_OPCODE_STATE_6:		present_state <= READ_OPCODE_STATE_7;
			READ_OPCODE_STATE_7:		present_state <= READ_OPCODE_STATE_8;
			READ_OPCODE_STATE_8:		present_state <= READ_OPCODE_STATE_9;
			READ_OPCODE_STATE_9:		present_state <= READ_OPCODE_STATE_10;
			READ_OPCODE_STATE_10:		present_state <= READ_OPCODE_STATE_11;
			READ_OPCODE_STATE_11:		present_state <= READ_OPCODE_STATE_12;
			READ_OPCODE_STATE_12:		present_state <= READ_OPCODE_STATE_13;
			READ_OPCODE_STATE_13:		present_state <= READ_OPCODE_STATE_14;
			READ_OPCODE_STATE_14:		present_state <= READ_OPCODE_STATE_15;
			READ_OPCODE_STATE_15:		present_state <= READ_ADDR_STATE_0;
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
			READ_ADDR_STATE_23:			present_state <= READ_ADDR_STATE_24;
			READ_ADDR_STATE_24:			present_state <= READ_ADDR_STATE_25;
			READ_ADDR_STATE_25:			present_state <= READ_ADDR_STATE_26;
			READ_ADDR_STATE_26:			present_state <= READ_ADDR_STATE_27;
			READ_ADDR_STATE_27:			present_state <= READ_ADDR_STATE_28;
			READ_ADDR_STATE_28:			present_state <= READ_ADDR_STATE_29;
			READ_ADDR_STATE_29:			present_state <= READ_ADDR_STATE_30;
			READ_ADDR_STATE_30:			present_state <= READ_ADDR_STATE_31;
			READ_ADDR_STATE_31:			present_state <= READ_ADDR_STATE_32;
			READ_ADDR_STATE_32:			present_state <= READ_ADDR_STATE_33;
			READ_ADDR_STATE_33:			present_state <= READ_ADDR_STATE_34;
			READ_ADDR_STATE_34:			present_state <= READ_ADDR_STATE_35;
			READ_ADDR_STATE_35:			present_state <= READ_ADDR_STATE_36;
			READ_ADDR_STATE_36:			present_state <= READ_ADDR_STATE_37;
			READ_ADDR_STATE_37:			present_state <= READ_ADDR_STATE_38;
			READ_ADDR_STATE_38:			present_state <= READ_ADDR_STATE_39;
			READ_ADDR_STATE_39:			present_state <= READ_ADDR_STATE_40;
			READ_ADDR_STATE_40:			present_state <= READ_ADDR_STATE_41;
			READ_ADDR_STATE_41:			present_state <= READ_ADDR_STATE_42;
			READ_ADDR_STATE_42:			present_state <= READ_ADDR_STATE_43;
			READ_ADDR_STATE_43:			present_state <= READ_ADDR_STATE_44;
			READ_ADDR_STATE_44:			present_state <= READ_ADDR_STATE_45;
			READ_ADDR_STATE_45:			present_state <= READ_ADDR_STATE_46;
			READ_ADDR_STATE_46:			present_state <= READ_ADDR_STATE_47;
			READ_ADDR_STATE_47:			present_state <= READ_DUMMY_STATE_0;
			READ_DUMMY_STATE_0:			present_state <= READ_DUMMY_STATE_1;
			READ_DUMMY_STATE_1:			present_state <= READ_DUMMY_STATE_2;
			READ_DUMMY_STATE_2:			present_state <= READ_DUMMY_STATE_3;
			READ_DUMMY_STATE_3:			present_state <= READ_DUMMY_STATE_4;
			READ_DUMMY_STATE_4:			present_state <= READ_DUMMY_STATE_5;
			READ_DUMMY_STATE_5:			present_state <= READ_DUMMY_STATE_6;
			READ_DUMMY_STATE_6:			present_state <= READ_DUMMY_STATE_7;
			READ_DUMMY_STATE_7:			present_state <= READ_DUMMY_STATE_8;
			READ_DUMMY_STATE_8:			present_state <= READ_DUMMY_STATE_9;
			READ_DUMMY_STATE_9:			present_state <= READ_DUMMY_STATE_10;
			READ_DUMMY_STATE_10:		present_state <= READ_DUMMY_STATE_11;
			READ_DUMMY_STATE_11:		present_state <= READ_DUMMY_STATE_12;
			READ_DUMMY_STATE_12:		present_state <= READ_DUMMY_STATE_13;
			READ_DUMMY_STATE_13:		present_state <= READ_DUMMY_STATE_14;
			READ_DUMMY_STATE_14:		present_state <= READ_DUMMY_STATE_15;
			READ_DUMMY_STATE_15:		present_state <= READ_STATE_0;
			READ_STATE_0:				present_state <= READ_STATE_1;
			READ_STATE_1:				present_state <= READ_STATE_2;
			READ_STATE_2:				present_state <= READ_STATE_3;
			READ_STATE_3:				if(end_2K)present_state <= RUN_STATE_0;
										else present_state <= READ_STATE_0;
			RUN_STATE_0:				present_state <= RUN_STATE_1;
			RUN_STATE_1:				present_state <= RUN_STATE_1;
			default:					present_state <= RUN_STATE_0;
		endcase
end

//--------------------------------------------------------------------------
// 控制訊號
always@(posedge clk or posedge reset)
begin
	if(reset)begin prog_run <= 0;reset_pic <= 1;sram_we <= 1;flash_cs <= 1;flash_si <= 0; wait_bit16 <= 0; bit16 <= 4'h0; end
	
	else
		case(present_state)
			START_STATE_0, START_STATE_1, START_STATE_2, START_STATE_3, START_STATE_4:
			begin
				flash_cs <= 1;
				flash_sck <= 0;
				flash_si <= 0;
			end
			START_STATE_5, START_STATE_6, START_STATE_7:
			begin
				flash_cs <= 0;
				flash_sck <= 0;
				flash_si <= 0;
			end
			//-----------------------------------------------------------------
			//read_opcode : 0x0B
			READ_OPCODE_STATE_0:
			begin
				flash_cs <= 0;
				flash_sck <= 0;
				flash_si <= 0;
			end
			
			READ_OPCODE_STATE_1:
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				flash_si <= 0;
			end
			
			READ_OPCODE_STATE_2:
			begin
				flash_cs <= 0;
				flash_sck <= 0;
				flash_si <= 0;
			end
			
			READ_OPCODE_STATE_3:
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				flash_si <= 0;
			end
			
			READ_OPCODE_STATE_4://5
			begin
				flash_cs <= 0;
				flash_sck <= 0;
				flash_si <= 0;
			end
			
			READ_OPCODE_STATE_5://6
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				flash_si <= 0;
			end
		
			READ_OPCODE_STATE_6://8
			begin
				flash_cs <= 0;
				flash_sck <= 0;
				flash_si <= 0;
			end
			
			READ_OPCODE_STATE_7://9
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				flash_si <= 0;
			end
			
			READ_OPCODE_STATE_8://9
			begin
				flash_cs <= 0;
				flash_sck <= 0;
				flash_si <= 1;
			end
			
			READ_OPCODE_STATE_9://9
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				flash_si <= 1;
			end
			
			READ_OPCODE_STATE_10://9
			begin
				flash_cs <= 0;
				flash_sck <= 0;
				flash_si <= 0;
			end
			
			READ_OPCODE_STATE_11://9
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				flash_si <= 0;
			end
			
			READ_OPCODE_STATE_12://9
			begin
				flash_cs <= 0;
				flash_sck <= 0;
				flash_si <= 1;
			end
			
			READ_OPCODE_STATE_13://9
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				flash_si <= 1;
			end
			
			READ_OPCODE_STATE_14://9
			begin
				flash_cs <= 0;
				flash_sck <= 0;
				flash_si <= 1;
			end
			
			READ_OPCODE_STATE_15://9
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				flash_si <= 1;
			end
			
		
			//-----------------------------------------------------------------
			//output read address(24'h000) start
			READ_ADDR_STATE_0, READ_ADDR_STATE_2, READ_ADDR_STATE_4, READ_ADDR_STATE_6, READ_ADDR_STATE_8, READ_ADDR_STATE_10,   
			READ_ADDR_STATE_12, READ_ADDR_STATE_14, READ_ADDR_STATE_16,	READ_ADDR_STATE_18, READ_ADDR_STATE_20, READ_ADDR_STATE_22,
			READ_ADDR_STATE_24, READ_ADDR_STATE_26, READ_ADDR_STATE_28, READ_ADDR_STATE_30, READ_ADDR_STATE_32, READ_ADDR_STATE_34,
			READ_ADDR_STATE_36, READ_ADDR_STATE_38, READ_ADDR_STATE_40, READ_ADDR_STATE_42, READ_ADDR_STATE_44, READ_ADDR_STATE_46:
			begin
				flash_cs <= 0;
				flash_sck <= 0;
				flash_si <= 0;
			end

			READ_ADDR_STATE_1, READ_ADDR_STATE_3, READ_ADDR_STATE_5, READ_ADDR_STATE_7, READ_ADDR_STATE_9, READ_ADDR_STATE_11,
			READ_ADDR_STATE_13, READ_ADDR_STATE_15, READ_ADDR_STATE_17,	READ_ADDR_STATE_19, READ_ADDR_STATE_21, READ_ADDR_STATE_23,
			READ_ADDR_STATE_25, READ_ADDR_STATE_27, READ_ADDR_STATE_29, READ_ADDR_STATE_31, READ_ADDR_STATE_33, READ_ADDR_STATE_35,
			READ_ADDR_STATE_37, READ_ADDR_STATE_39, READ_ADDR_STATE_41, READ_ADDR_STATE_43, READ_ADDR_STATE_45, READ_ADDR_STATE_47:
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				flash_si <= 0;
			end
			
			//output read address end
			//-----------------------------------------------------------------
			//output dummy(8'h00) start
			READ_DUMMY_STATE_0, READ_DUMMY_STATE_2, READ_DUMMY_STATE_4, READ_DUMMY_STATE_6, READ_DUMMY_STATE_8, READ_DUMMY_STATE_10, 
			READ_DUMMY_STATE_12, READ_DUMMY_STATE_14:
			begin
				flash_cs <= 0;
				flash_sck <= 0;
			end
			
			READ_DUMMY_STATE_1, READ_DUMMY_STATE_3, READ_DUMMY_STATE_5, READ_DUMMY_STATE_7, READ_DUMMY_STATE_9, READ_DUMMY_STATE_11, 
			READ_DUMMY_STATE_13, READ_DUMMY_STATE_15:
			begin
				flash_cs <= 0;
				flash_sck <= 1;
			end
			//output dummy end
			//-----------------------------------------------------------------
			//read 2k start
			READ_STATE_0://21
			begin
				flash_cs <= 0;
				flash_sck <= 0;
			end
			
			READ_STATE_1://22
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				if(~wait_bit16)bit16 <= 4'h0;
				else bit16 <= bit16 + 1'b1;
				if(sram_addr_temp == 12'h7ff)sram_we <= 1;
				else sram_we <= ~end_16bit;
			end
			
			READ_STATE_2://22
			begin
				flash_cs <= 0;
				flash_sck <= 0;
			end
			
			READ_STATE_3://23
			begin
				flash_cs <= 0;
				flash_sck <= 1;
				wait_bit16 <= 1;
				bit16 <= bit16 + 1'b1;
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