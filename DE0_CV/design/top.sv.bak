module top(
    input logic clk,
    input logic rst

    output logic [31:0] regs_31
);

    // flash wires
    logic flash_si;
    logic flash_so;
    logic flash_cs;

    // sram wires
    logic [INST_WIDTH-1:0] sram_data;
    logic [INST_WIDTH-1:0] sram_addr;
    logic                  sram_we;

    // others
    logic [INST_WIDTH-1:0] config_data;
    logic prog_run;

    //========================
    // Bootloader
    //========================
    bootloader u_bootloader (
        .sram_data  (sram_data),
        .sram_addr  (sram_addr),
        .sram_we    (sram_we),

        .config_data (config_data),

        .flash_si (flash_si),
        .flash_cs (flash_cs),
        .flash_so (flash_so),

        .prog_run (prog_run),

        .clk (clk),
        .reset (rst)
    );

    //========================
    // Flash
    //========================
    MX25L1006E u_flash (
        .SCLK (clk),          // clock
        .CS   (flash_cs),
        .SI   (flash_si),
        .SO   (flash_so),
        .WP   (1'b1),         // 1:common op
        .HOLD (1'b1)          // 1:common op
    );

    //========================
    // RISC-V
    //========================
     RISC_V u_risc_v (
        .clk (clk),
        .rst (~prog_run),
        
        .sram_we (sram_we),
        .sram_addr (sram_addr),
        .sram_data (sram_data),

        .regs_31 (regs_31)
    );

endmodule
