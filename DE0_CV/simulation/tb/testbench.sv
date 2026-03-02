
module testbench;
  logic rst;
  logic clk;
  logic [31:0] regs_31;

  wire flash_so;
  wire flash_cs;
  wire flash_si;
  wire vcc = 1'b1; // ??? wire ?????
  top u_top(
	  .rst      (rst      ),
	  .clk      (clk      ),

    .flash_so (flash_so ),
    .flash_si (flash_si ),
    .flash_cs (flash_cs ),
    //
    .regs_31  (regs_31  )
  );

  //========================
  // Flash
  //========================
  MX25L1006E u_flash (
    .SCLK (clk),
    .CS   (flash_cs),
    .SI   (flash_si),
    .SO   (flash_so),
    .WP   (vcc),   // ??? wire
    .HOLD (vcc)    // ??? wire
);
  
  initial
  begin
    clk = 0;
    rst = 1;
    #40 rst = 0;
    #500000 $stop;
  end
  
  always #10 clk = ~clk;
endmodule