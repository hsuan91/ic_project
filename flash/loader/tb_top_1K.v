`timescale 1ns / 100ps
module tb_top;
wire [13:0]sram_data;//將串列進來的資料轉成並列給SRAM的DATA
wire [9:0]sram_addr;
wire [15:0] config_data;
wire prog_run, reset_pic;//控制PIC的訊號
reg clk, reset_from8051, cold_boot_reset;
wire wp, hold;

// module loader(sram_data, sram_addr, sram_we, config_data, flash_si, flash_cs, flash_so, prog_run, reset_pic, clk, reset_from8051, cold_boot_reset);
loader loader0(sram_data, sram_addr, sram_we, config_data, flash_si, flash_cs, flash_so, prog_run, reset_pic, clk, reset_from8051, cold_boot_reset);

//module flash_256k(so, cs, si, sck);
//flash_256k flash(flash_so, flash_cs, flash_si, clk);

//module MX25L1006E( SCLK, CS, SI, SO, WP, HOLD );
MX25L1006E flash (clk, flash_cs, flash_si, flash_so, wp, hold);

initial begin
	clk = 0;reset_from8051 = 1;cold_boot_reset = 1;
	force wp = 1; 
	force hold = 1;
	// #40 reset = 0;
	// #4000 reset = 1;
	#80 reset_from8051 = 0;cold_boot_reset = 0;
	#1500000 $stop;
end

always #20 clk = ~clk;


endmodule