module Program_Rom (
    input  logic    clk,

    // Bootloader
    input  logic        sram_we,
    input  logic [31:0] sram_addr,
    input  logic [31:0] sram_data,

    // Program Rom output
    output logic [31:0] Rom_data
);

    logic [31:0] mem [0:1023];

    // 當 sram_we 為 0 時，將 bootloader 傳來的資料寫入記憶體
    always_ff @(posedge clk) begin
        if (sram_we == 1'b0) begin
            mem[sram_addr[11:2]] <= sram_data;
        end
    end

    assign Rom_data = mem[sram_addr[11:2]];
 
endmodule