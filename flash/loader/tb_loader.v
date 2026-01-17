module tb_loader;
wire [13:0]sram_data;//將串列進來的資料轉成並列給SRAM的DATA
wire [11:0]sram_addr;
wire prog_run, reset_pic;//控制PIC的訊號
wire flash_si, flash_cs;//控制Flash的訊號
reg flash_so, clk, reset;

//module loader(sram_data, sram_addr, sram_ce, flash_si, flash_cs, prog_run, reset_pic, flash_so, clk, reset);
loader loader0(sram_data, sram_addr, sram_ce, flash_si, flash_cs, prog_run, reset_pic, flash_so, clk, reset);

initial begin
	clk = 0;reset = 1;
	#40 reset = 0;
	#5000000 $stop;
end

always #20 clk = ~clk;

endmodule