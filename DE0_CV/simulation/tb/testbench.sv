
module testbench;
  logic rst;
  logic clk;
  
  RISC_V u_RISC_V(
	  .rst      (rst      ),
	  .clk      (clk      )
  );
  
  initial
  begin
    clk = 0;
    rst = 1;
    #40 rst = 0;
    #20000 $stop;
  end
  
  always #10 clk = ~clk;
endmodule