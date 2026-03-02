
module testbench;
  logic rst;
  logic clk;
  logic [31:0] regs_31;
  
  top u_top(
	  .rst      (rst      ),
	  .clk      (clk      ),
    //
    .regs_31  (regs_31  )
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