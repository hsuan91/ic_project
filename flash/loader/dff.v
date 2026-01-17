module dff_noclr(q, d, clk);
//	this DFF have no "clr" or "reset" 4 it.
//	it's 4 format

output reg q;
input d, clk;

always@(posedge clk)
		q <= d;

endmodule