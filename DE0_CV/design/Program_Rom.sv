module Program_Rom(
   output logic [31:0] Rom_data,
   input [31:0] Rom_addr
);

   always_comb begin
      case (Rom_addr)
         32'h00000000 : Rom_data = 32'h341CE137; // lui x2 213454
         32'h00000004 : Rom_data = 32'hF0C10113; // addi x2 x2 -244
         32'h00000008 : Rom_data = 32'h00202023; // sw x2 0(x0)
         32'h0000000C : Rom_data = 32'hBD006137; // lui x2 774150
         32'h00000010 : Rom_data = 32'h36510113; // addi x2 x2 869
         32'h00000014 : Rom_data = 32'h00202223; // sw x2 4(x0)
         32'h00000018 : Rom_data = 32'h00F00113; // addi x2 x0 15
         32'h0000001C : Rom_data = 32'h00200423; // sb x2 8(x0)
         32'h00000020 : Rom_data = 32'h00900193; // addi x3 x0 9
         32'h00000024 : Rom_data = 32'h6E056137; // lui x2 450646
         32'h00000028 : Rom_data = 32'hFF510113; // addi x2 x2 -11
         32'h0000002C : Rom_data = 32'h0021A023; // sw x2 0(x3)
         32'h00000030 : Rom_data = 32'h34435137; // lui x2 214069
         32'h00000034 : Rom_data = 32'hDF710113; // addi x2 x2 -521
         32'h00000038 : Rom_data = 32'h0021A223; // sw x2 4(x3)
         32'h0000003C : Rom_data = 32'h00C00113; // addi x2 x0 12
         32'h00000040 : Rom_data = 32'h00218423; // sb x2 8(x3)
         32'h00000044 : Rom_data = 32'h00300693; // addi x13 x0 3
         32'h00000048 : Rom_data = 32'h00050283; // lb x5 0(x10)
         32'h0000004C : Rom_data = 32'h00958303; // lb x6 9(x11)
         32'h00000050 : Rom_data = 32'h026283B3; // mul x7 x5 x6
         32'h00000054 : Rom_data = 32'h00740433; // add x8 x8 x7
         32'h00000058 : Rom_data = 32'h00150513; // addi x10 x10 1
         32'h0000005C : Rom_data = 32'h00358593; // addi x11 x11 3
         32'h00000060 : Rom_data = 32'h00160613; // addi x12 x12 1
         32'h00000064 : Rom_data = 32'hFED642E3; // blt x12 x13 -28
         32'h00000068 : Rom_data = 32'h00871923; // sh x8 18(x14)
         32'h0000006C : Rom_data = 32'h00000413; // addi x8 x0 0
         32'h00000070 : Rom_data = 32'h00000513; // addi x10 x0 0
         32'h00000074 : Rom_data = 32'h00000593; // addi x11 x0 0
         32'h00000078 : Rom_data = 32'h00000613; // addi x12 x0 0
         32'h0000007C : Rom_data = 32'h00270713; // addi x14 x14 2
         32'h00000080 : Rom_data = 32'h00178793; // addi x15 x15 1
         32'h00000084 : Rom_data = 32'h00F585B3; // add x11 x11 x15
         32'h00000088 : Rom_data = 32'hFCD7C0E3; // blt x15 x13 -64
         32'h0000008C : Rom_data = 32'h00000593; // addi x11 x0 0
         32'h00000090 : Rom_data = 32'h00000793; // addi x15 x0 0
         32'h00000094 : Rom_data = 32'h00350283; // lb x5 3(x10)
         32'h00000098 : Rom_data = 32'h00958303; // lb x6 9(x11)
         32'h0000009C : Rom_data = 32'h026283B3; // mul x7 x5 x6
         32'h000000A0 : Rom_data = 32'h00740433; // add x8 x8 x7
         32'h000000A4 : Rom_data = 32'h00150513; // addi x10 x10 1
         32'h000000A8 : Rom_data = 32'h00358593; // addi x11 x11 3
         32'h000000AC : Rom_data = 32'h00160613; // addi x12 x12 1
         32'h000000B0 : Rom_data = 32'hFED642E3; // blt x12 x13 -28
         32'h000000B4 : Rom_data = 32'h00871923; // sh x8 18(x14)
         32'h000000B8 : Rom_data = 32'h00000413; // addi x8 x0 0
         32'h000000BC : Rom_data = 32'h00000513; // addi x10 x0 0
         32'h000000C0 : Rom_data = 32'h00000593; // addi x11 x0 0
         32'h000000C4 : Rom_data = 32'h00000613; // addi x12 x0 0
         32'h000000C8 : Rom_data = 32'h00270713; // addi x14 x14 2
         32'h000000CC : Rom_data = 32'h00178793; // addi x15 x15 1
         32'h000000D0 : Rom_data = 32'h00F585B3; // add x11 x11 x15
         32'h000000D4 : Rom_data = 32'hFCD7C0E3; // blt x15 x13 -64
         32'h000000D8 : Rom_data = 32'h00000593; // addi x11 x0 0
         32'h000000DC : Rom_data = 32'h00000793; // addi x15 x0 0
         32'h000000E0 : Rom_data = 32'h00650283; // lb x5 6(x10)
         32'h000000E4 : Rom_data = 32'h00958303; // lb x6 9(x11)
         32'h000000E8 : Rom_data = 32'h026283B3; // mul x7 x5 x6
         32'h000000EC : Rom_data = 32'h00740433; // add x8 x8 x7
         32'h000000F0 : Rom_data = 32'h00150513; // addi x10 x10 1
         32'h000000F4 : Rom_data = 32'h00358593; // addi x11 x11 3
         32'h000000F8 : Rom_data = 32'h00160613; // addi x12 x12 1
         32'h000000FC : Rom_data = 32'hFED642E3; // blt x12 x13 -28
         32'h00000100 : Rom_data = 32'h00871923; // sh x8 18(x14)
         32'h00000104 : Rom_data = 32'h00000413; // addi x8 x0 0
         32'h00000108 : Rom_data = 32'h00000513; // addi x10 x0 0
         32'h0000010C : Rom_data = 32'h00000593; // addi x11 x0 0
         32'h00000110 : Rom_data = 32'h00000613; // addi x12 x0 0
         32'h00000114 : Rom_data = 32'h00270713; // addi x14 x14 2
         32'h00000118 : Rom_data = 32'h00178793; // addi x15 x15 1
         32'h0000011C : Rom_data = 32'h00F585B3; // add x11 x11 x15
         32'h00000120 : Rom_data = 32'hFCD7C0E3; // blt x15 x13 -64
         32'h00000124 : Rom_data = 32'h01200193; // addi x3 x0 18
         32'h00000128 : Rom_data = 32'h00900213; // addi x4 x0 9
         32'h0000012C : Rom_data = 32'h00019F83; // lh x31 0(x3)
         32'h00000130 : Rom_data = 32'h00218193; // addi x3 x3 2
         32'h00000134 : Rom_data = 32'hFFF20213; // addi x4 x4 -1
         32'h00000138 : Rom_data = 32'hFE021AE3; // bne x4 x0 -12
         default : Rom_data = 32'h00000013;      // NOP
      endcase
   end

endmodule
