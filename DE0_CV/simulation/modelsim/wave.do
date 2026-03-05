onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/clk
add wave -noupdate -radix hexadecimal /testbench/u_top/u_risc_v/inst_r
add wave -noupdate -radix hexadecimal /testbench/u_top/u_risc_v/u_Program_Rom/sram_addr
add wave -noupdate -radix hexadecimal /testbench/u_top/u_risc_v/u_Program_Rom/sram_data
add wave -noupdate -radix hexadecimal /testbench/u_top/u_risc_v/u_Program_Rom/Rom_data
add wave -noupdate -radix hexadecimal /testbench/u_top/u_risc_v/u_Program_Rom/mem
add wave -noupdate -expand /testbench/u_top/u_risc_v/u_Reg_file/regs
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[0]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[1]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[2]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[3]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[4]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[5]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[6]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[7]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[8]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[9]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[10]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[11]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[12]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[13]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[14]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[15]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[16]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[17]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[18]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[19]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[20]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[21]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[22]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[23]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[24]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[25]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[26]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[27]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[28]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[29]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[30]}
add wave -noupdate -radix hexadecimal {/testbench/u_top/u_risc_v/u_Reg_file/regs[31]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1543 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {494819 ps} {500315 ps}
