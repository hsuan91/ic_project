onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /testbench/clk
add wave -noupdate -radix hexadecimal /testbench/u_top/u_risc_v/inst_r
add wave -noupdate -radix hexadecimal /testbench/u_top/u_risc_v/u_Program_Rom/sram_addr
add wave -noupdate -radix hexadecimal /testbench/u_top/u_risc_v/u_Program_Rom/sram_data
add wave -noupdate -radix hexadecimal /testbench/u_top/u_risc_v/u_Program_Rom/Rom_data
add wave -noupdate -radix hexadecimal /testbench/u_top/u_risc_v/u_Program_Rom/mem
add wave -noupdate /testbench/u_top/u_risc_v/u_Reg_file/regs
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
WaveRestoreZoom {0 ps} {5496 ps}
