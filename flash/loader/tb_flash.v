module tb_flash;
wire so;
reg wp, hold, cs, si, sck;

flash_256k flash(so, cs, si, sck);

initial begin
	sck = 0;si = 0;
	#40 si = 0;
	#40 si = 0;
	#40 si = 0;
	#40 si = 0;
	#40 si = 0;
	#40 si = 0;
	#40 si = 1;
	#40 si = 1;
	#40 si = 0;
	#1000000 $stop;
end

always #20 sck = ~sck;

endmodule