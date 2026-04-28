module SRAM (
    input  logic    clk,

    // Bootloader
    input  logic        sram_we,
    input  logic [31:0] sram_addr,
    input  logic [31:0] sram_data,

    // SRAM output
    output logic [31:0] sram_data_out
);

    logic [31:0] mem [0:255];   //1KB

    // 當 sram_we 為 0 時，將 bootloader 傳來的資料寫入記憶體
    always_ff @(posedge clk) begin
        if (sram_we == 1'b0)
            mem[sram_addr[9:2]] <= sram_data;
        else
			sram_data_out = mem[sram_addr[9:2]];
    end
 
endmodule