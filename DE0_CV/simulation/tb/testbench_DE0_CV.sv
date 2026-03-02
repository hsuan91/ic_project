module testbench_DE0_CV;
	//////////// CLOCK //////////
	logic 		          	CLOCK_50;
	logic 		          	CLOCK2_50;
	logic 		          	CLOCK3_50;
	logic 		          	CLOCK4_50;

	//////////// SDRAM //////////
	logic		     [12:0]		DRAM_ADDR;
	logic		     [1:0]		DRAM_BA;
	logic		          		DRAM_CAS_N;
	logic		          		DRAM_CKE;
	logic		          		DRAM_CLK;
	logic		          		DRAM_CS_N;
	logic 		  [15:0]		DRAM_DQ;
	logic		          		DRAM_LDQM;
	logic		          		DRAM_RAS_N;
	logic		          		DRAM_UDQM;
	logic		          		DRAM_WE_N;

	//////////// SEG7 //////////
	logic		     [6:0]		HEX0;
	logic		     [6:0]		HEX1;
	logic		     [6:0]		HEX2;
	logic		     [6:0]		HEX3;
	logic		     [6:0]		HEX4;
	logic		     [6:0]		HEX5;

	//////////// KEY //////////
	logic		  	  [3:0]	 	KEY;
	logic 		          	RESET_N;

	//////////// LED //////////
	logic		     [9:0]		LEDR;

	//////////// PS2 //////////
	logic 		          	PS2_CLK;
	logic		          		PS2_CLK2;
	logic		          		PS2_DAT;
	logic		          		PS2_DAT2;

	//////////// microSD Card //////////
	logic		          		SD_CLK;
	logic		          		SD_CMD;
	logic		     [3:0]		SD_DATA;

	//////////// SW //////////
	logic		     [9:0]		SW;

	//////////// VGA //////////
	logic		     [3:0]		VGA_B;
	logic		     [3:0]		VGA_G;
	logic		          		VGA_HS;
	logic		     [3:0]		VGA_R;
	logic		          		VGA_VS;

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	logic		    [35:0]		GPIO_0;

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	logic		    [35:0]		GPIO_1;

	DE0_CV u_DE0_CV(
		.CLOCK_50	(CLOCK_50),
		.CLOCK2_50	(CLOCK2_50),
		.CLOCK3_50	(CLOCK3_50),
		.CLOCK4_50	(CLOCK4_50),

		.DRAM_ADDR	(DRAM_ADDR),
		.DRAM_BA		(DRAM_BA),
		.DRAM_CAS_N	(DRAM_CAS_N),
		.DRAM_CKE	(DRAM_CKE),
		.DRAM_CLK	(DRAM_CLK),
		.DRAM_CS_N	(DRAM_CS_N),
		.DRAM_DQ		(DRAM_DQ),
		.DRAM_LDQM	(DRAM_LDQM),
		.DRAM_RAS_N	(DRAM_RAS_N),
		.DRAM_UDQM	(DRAM_UDQM),
		.DRAM_WE_N	(DRAM_WE_N),

		.HEX0			(HEX0),
		.HEX1			(HEX1),
		.HEX2			(HEX2),
		.HEX3			(HEX3),
		.HEX4			(HEX4),
		.HEX5			(HEX5),

		.KEY			(KEY),
		.RESET_N		(RESET_N),
		.LEDR			(LEDR),

		.PS2_CLK		(PS2_CLK),
		.PS2_CLK2	(PS2_CLK2),
		.PS2_DAT		(PS2_DAT),
		.PS2_DAT2	(PS2_DAT2),

		.SD_CLK		(SD_CLK),
		.SD_CMD		(SD_CMD),
		.SD_DATA		(SD_DATA),

		.SW			(SW),

		.VGA_B		(VGA_B),
		.VGA_G		(VGA_G),
		.VGA_HS		(VGA_HS),
		.VGA_R		(VGA_R),
		.VGA_VS		(VGA_VS),

		.GPIO_0		(GPIO_0),
		.GPIO_1		(GPIO_1)
	);

	
	
	initial
	begin
		
	end
  
	
endmodule
