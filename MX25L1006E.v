// *============================================================================================== 
// *
// *   MX25L1006E.v - 1M-BIT CMOS Serial Flash Memory
// *
// *           COPYRIGHT 2014 Macronix International Co., Ltd.
// *----------------------------------------------------------------------------------------------
// * Environment  : Cadence NC-Verilog
// * Reference Doc: MX25L1006E REV.1.4,APR.10,2014
// * Creation Date: @(#)$Date: 2014/04/23 09:54:46 $
// * Version      : @(#)$Revision: 1.8 $
// * Description  : There is only one module in this file
// *                module MX25L1006E->behavior model for the 1M-Bit flash
// *----------------------------------------------------------------------------------------------
// * Note 1:model can load initial flash data from file when parameter Init_File = "xxx" was defined; 
// *        xxx: initial flash data file name;default value xxx = "none", initial flash data is "FF".
// * Note 2:power setup time is tVSL = 200_000 ns, so after power up, chip can be enable.
// * Note 3:because it is not checked during the Board system simulation the tCLQX timing is not
// *        inserted to the read function flow temporarily.
// * Note 4:more than one values (min. typ. max. value) are defined for some AC parameters in the
// *        datasheet, but only one of them is selected in the behavior model, e.g. program and
// *        erase cycle time is typical value. For the detailed information of the parameters,
// *        please refer to datasheet and contact with Macronix.
// * Note 5:If you have any question and suggestion, please send your mail to following email address :
// *                                    flash_model@mxic.com.tw
// *============================================================================================== 
// * timescale define
// *============================================================================================== 
`timescale 1ns / 100ps

// *============================================================================================== 
// * product parameter define
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* all the parameters users may need to change                          */
    /*----------------------------------------------------------------------*/
        `define File_Name_SFDP     "none"     // Flash data file name for SFDP region
        `define Vtclqv              6         // 30pf:8ns, 15pf:6ns 

// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* Define controller STATE						    */
    /*----------------------------------------------------------------------*/
	`define		STANDBY_STATE		0
        `define		CMD_STATE		1
        `define		BAD_CMD_STATE		2
module MX25L1006E( SCLK, 
		    CS, 
		    SI, 
		    SO, 
		    WP, 
		    HOLD );

// *============================================================================================== 
// * Declaration of ports (input, output, inout)
// *============================================================================================== 
    input  SCLK;    // Signal of Clock Input
    input  CS;	    // Chip select (Low active)
    inout  SI;	    // Serial Input/Output SIO0
    inout  SO;
    inout  WP;
    inout  HOLD; 

// *============================================================================================== 
// * Declaration of parameter (parameter)
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* Density STATE parameter						    */  		
    /*----------------------------------------------------------------------*/
    parameter	A_MSB		= 16,
		TOP_Add		= 17'h1ffff,
                A_MSB_SFDP       = 6,
                SFDP_TOP_Add     = 7'h7f,
		Sector_MSB	= 4,
		Block_MSB	= 1,
		Block_NUM	= 2;
  
    /*----------------------------------------------------------------------*/
    /* Define ID Parameter						    */
    /*----------------------------------------------------------------------*/
    parameter	ID_MXIC		= 8'hc2,
		ID_Device	= 8'h10,
		Memory_Type	= 8'h20,
		Memory_Density	= 8'h11;

    /*----------------------------------------------------------------------*/
    /* Define Initial Memory File Name					    */
    /*----------------------------------------------------------------------*/
    //parameter   Init_File	= "none"; // initial flash data
	parameter   Init_File	= "../../design/flash_data.txt";
    parameter   Init_File_SFDP	= `File_Name_SFDP;  // initial flash data for SFDP

    /*----------------------------------------------------------------------*/
    /* AC Characters Parameter						    */
    /*----------------------------------------------------------------------*/
    parameter	tSHQZ	= 6,    // CS High to SO Float Time [ns]
		tCLQV	= `Vtclqv,    // Clock Low to Output Valid
		tCLQX	= 0,   	// Output Hold Time
                tHHQX   = 6,    // HOLD to Output Low-z
                tHLQZ   = 6,    // HOLD to Output High-z
             	tBP  	= 9_000,	// Byte program time
             	tSE	= 40_000_000,	// Sector erase time  
		tBE	= 400_000_000,	// Block erase time
		tCE	= 800_000_000,	// chip erase time
		tPP	= 600_000,	// Program time
		tW 	= 5_000_000,	// Write Status time
		tVSL	= 20;	// Time delay to chip select allowed

    specify
	specparam   tSCLK   = 9.6,	// Clock Cycle Time [ns]
		    fSCLK   = 104,	// Clock Frequence except READ instruction[ns] 15pF
		    tRSCLK  = 30,	// Clock Cycle Time for READ instruction[ns] 15pF
		    fRSCLK  = 33,	// Clock Frequence for READ instruction[ns] 15pF
		    tCH	    = 4.7,  	// Clock High Time (min) [ns]
		    tCL	    = 4.7,  	// Clock Low  Time (min) [ns]
                    tCH_R   = 13, 	// Clock High Time for READ(min) [ns]
                    tCL_R   = 13, 	// Clock Low  Time for READ(min) [ns]
		    tSLCH   = 7,	// CS# Active Setup Time (relative to SCLK) (min) [ns]
		    tCHSL   = 7,	// CS# Not Active Hold Time (relative to SCLK)(min) [ns]
		    tSHSL_R = 15,	// CS High Time for read instruction (min) [ns]
		    tSHSL_W = 40,	// CS High Time for write instruction (min) [ns]
		    tDVCH   = 2,	// SI Setup Time (min) [ns]
		    tCHDX   = 5,	// SI Hold Time (min) [ns]
		    tCHSH   = 7,	// CS# Active Hold Time (relative to SCLK) (min) [ns]
		    tSHCH   = 7,	// CS# Not Active Setup Time (relative to SCLK) (min) [ns]
                    tHLCH   = 5,        // HOLD#  Setup Time (relative to SCLK) (min) [ns]
                    tCHHH   = 5,        // HOLD#  Hold  Time (relative to SCLK) (min) [ns]
                    tHHCH   = 5,        // HOLD  Setup Time (relative to SCLK) (min) [ns]
                    tCHHL   = 5,        // HOLD  Hold  Time (relative to SCLK) (min) [ns]
		    tWHSL   = 20,	// Write Protection Setup Time		  
		    tSHWL   = 100,	// Write Protection Hold  Time  
		    tDP	    = 10_000,	// CS# High to Deep Power-down Mode
		    tRES1   = 8_800,	// CS# High to Standby Mode without Electronic Signature Read
		    tRES2   = 8_800,	// CS# High to Standby Mode with Electronic Signature Read
 	            tTSCLK  = 12.5,	// Clock Cycle Time for 2XI/O READ instruction[ns] 15pF
		    fTSCLK  = 80;	// Clock Frequence for 2XI/O READ instruction[ns] 15pF
     endspecify

    /*----------------------------------------------------------------------*/
    /* Define Command Parameter						    */
    /*----------------------------------------------------------------------*/
    parameter	WREN	    = 8'h06, // WriteEnable   
		WRDI	    = 8'h04, // WriteDisable  
		RDID	    = 8'h9F, // ReadID	  
		RDSR	    = 8'h05, // ReadStatus	  
    	        WRSR	    = 8'h01, // WriteStatus   
    	        READ1X	    = 8'h03, // ReadData	  
    	        FASTREAD1X  = 8'h0b, // FastReadData  
                SFDP_READ   = 8'h5a, // enter SFDP read mode
    	        SE	    = 8'h20, // SectorErase   
    	        CE1	    = 8'h60, // ChipErase	  
    	        CE2	    = 8'hc7, // ChipErase	  
    	        PP	    = 8'h02, // PageProgram   
    	        DP	    = 8'hb9, // DeepPowerDown
    	        RDP	    = 8'hab, // ReleaseFromDeepPowerDown 
    	        RES	    = 8'hab, // ReadElectricID 
    	        REMS	    = 8'h90, // ReadElectricManufacturerDeviceID
                BE1	    = 8'h52, // BlockErase	  
                BE2	    = 8'hd8, // BlockErase	  
      	        FASTREAD2X  = 8'h3b; // Fastread dual output;

    /*----------------------------------------------------------------------*/
    /* Declaration of internal-signal                                       */
    /*----------------------------------------------------------------------*/
    reg  [7:0]		 ARRAY[0:TOP_Add];  
    reg  [7:0]		 Status_Reg;	    
    reg  [7:0]		 CMD_BUS;
    reg  [23:0]          SI_Reg;	    
    reg  [7:0]           Dummy_A[0:255];    
    reg  [A_MSB:0]	 Address;	    
    reg  [Sector_MSB:0]	 Sector;	  
    reg  [Block_MSB:0] 	 Block;	   
    reg  [2:0]		 STATE;
    reg  [7:0]           SFDP_ARRAY[0:SFDP_TOP_Add];
    reg     SIO0_Reg;
    reg     SIO1_Reg;
    
    reg     Chip_EN;
    reg	    SI_IN_EN;
    reg     SFDP_Mode;
    reg	    SI_OUT_EN;   
    reg	    SO_OUT_EN;   
    reg     HOLD_OUT_B;
    wire    HOLD_B_INT;
    reg     DP_Mode;	    
    reg     Read_1XIO_Mode;
    reg     Read_1XIO_Chk;
    reg     FastRD_1XIO_Mode;	
    reg     FastRD_2XIO_Mode;	
    reg     PP_1XIO_Mode;
    reg     SE_4K_Mode;
    reg     BE_Mode;
    reg     CE_Mode;
    reg     WRSR_Mode;
    reg     RES_Mode;
    reg     REMS_Mode;
    reg     SCLK_EN;
    reg     RDSR_Mode;
    reg     RDID_Mode;
    reg     Read_2XIO_Mode;
    reg     Read_2XIO_Chk;
    reg     Byte_PGM_Mode;
    reg     Read_SHSL;
    reg     tDP_Chk;
    reg     tRES1_Chk;
    reg     tRES2_Chk;
    wire    Write_SHSL;
    wire    WP_B_INT;
    wire    ISCLK;
    wire    WIP;
    wire    WEL;
    wire    SRWD;
    wire    Dis_CE;
    wire    Dis_WRSR;
    event   WRSR_Event; 
    event   BE_Event;
    event   SE_4K_Event;
    event   CE_Event;
    event   PP_Event;
    integer i;
    integer j;
    integer Bit; 
    integer Bit_Tmp; 
    integer Start_Add;
    integer End_Add;
    integer Page_Size;

    /*----------------------------------------------------------------------*/
    /* initial variable value						    */
    /*----------------------------------------------------------------------*/
    initial begin
	Status_Reg  = 8'b0000_0000;
	CMD_BUS	    = 8'b0000_0000;
	SI_IN_EN    = 1'b0;
	SI_OUT_EN   = 1'b0; 
	SO_OUT_EN   = 1'b0; 
	Address	    = 0;
        Sector      = 0;
        Block       = 0;  
	i	    = 0;
	j	    = 0;
	Bit	    = 0;
	Bit_Tmp	    = 0;
	Start_Add   = 0;
	End_Add	    = 0;
	Page_Size   = 256;
	DP_Mode	    = 1'b0;
	
	Chip_EN	    = 1'b0;
        SCLK_EN     = 1'b1;
        STATE =  `STANDBY_STATE;
        tDP_Chk       = 1'b0;
        tRES1_Chk       = 1'b0;
        tRES2_Chk       = 1'b0;
	Read_1XIO_Mode  = 1'b0;
	Read_1XIO_Chk   = 1'b0;
	Read_2XIO_Mode  = 1'b0;
	Read_2XIO_Chk   = 1'b0;
	PP_1XIO_Mode    = 1'b0;
	SE_4K_Mode      = 1'b0;
	BE_Mode	        = 1'b0;
	CE_Mode	        = 1'b0;
	WRSR_Mode	= 1'b0;
	RES_Mode	= 1'b0;
	REMS_Mode	= 1'b0;
        RDSR_Mode	= 1'b0;
        RDID_Mode	= 1'b0;
        SFDP_Mode = 1'b0;
        Read_SHSL 	= 1'b0;
	Byte_PGM_Mode   = 1'b0;
	FastRD_1XIO_Mode= 1'b0;
	FastRD_2XIO_Mode= 1'b0;
        HOLD_OUT_B      = 1'b1;
    end
    
    /*----------------------------------------------------------------------*/
    /* initial flash data    						    */
    /*----------------------------------------------------------------------*/
    initial 
    begin : memory_initialize
	for ( i = 0; i <=  TOP_Add; i = i + 1 )
	    ARRAY[i] = 8'h00; 
		
		ARRAY[0] = 8'h28;
		ARRAY[1] = 8'h0F;
		ARRAY[8  ] = 8'h00; ARRAY[9  ] = 8'hCE;
		ARRAY[10 ] = 8'h0E; ARRAY[11 ] = 8'h03;
		ARRAY[12 ] = 8'h12; ARRAY[13 ] = 8'h83;
		ARRAY[14 ] = 8'h00; ARRAY[15 ] = 8'h8E;
		ARRAY[16 ] = 8'h08; ARRAY[17 ] = 8'h04;
		ARRAY[18 ] = 8'h00; ARRAY[19 ] = 8'h8F;
		ARRAY[20 ] = 8'h08; ARRAY[21 ] = 8'h0A;
		ARRAY[22 ] = 8'h00; ARRAY[23 ] = 8'h90;
		ARRAY[24 ] = 8'h08; ARRAY[25 ] = 8'h4F;
		ARRAY[26 ] = 8'h00; ARRAY[27 ] = 8'h91;
		ARRAY[28 ] = 8'h29; ARRAY[29 ] = 8'h26;
		ARRAY[30 ] = 8'h28; ARRAY[31 ] = 8'h10;
		ARRAY[32 ] = 8'h21; ARRAY[33 ] = 8'h8B;
		ARRAY[34 ] = 8'h00; ARRAY[35 ] = 8'hB8;
		ARRAY[36 ] = 8'h21; ARRAY[37 ] = 8'h8C;
		ARRAY[38 ] = 8'h00; ARRAY[39 ] = 8'hB9;
		ARRAY[40 ] = 8'h21; ARRAY[41 ] = 8'h8D;
		ARRAY[42 ] = 8'h00; ARRAY[43 ] = 8'hBA;
		ARRAY[44 ] = 8'h21; ARRAY[45 ] = 8'h8E;
		ARRAY[46 ] = 8'h00; ARRAY[47 ] = 8'hBB;
		ARRAY[48 ] = 8'h21; ARRAY[49 ] = 8'h8F;
		ARRAY[50 ] = 8'h00; ARRAY[51 ] = 8'hBC;
		ARRAY[52 ] = 8'h21; ARRAY[53 ] = 8'h90;
		ARRAY[54 ] = 8'h00; ARRAY[55 ] = 8'hBD;
		ARRAY[56 ] = 8'h21; ARRAY[57 ] = 8'h91;
		ARRAY[58 ] = 8'h00; ARRAY[59 ] = 8'hBE;
		ARRAY[60 ] = 8'h21; ARRAY[61 ] = 8'h92;
		ARRAY[62 ] = 8'h00; ARRAY[63 ] = 8'hBF;
		ARRAY[64 ] = 8'h01; ARRAY[65 ] = 8'h83;
		ARRAY[66 ] = 8'h28; ARRAY[67 ] = 8'h22;
		ARRAY[68 ] = 8'h16; ARRAY[69 ] = 8'h83;
		ARRAY[70 ] = 8'h01; ARRAY[71 ] = 8'h85;
		ARRAY[72 ] = 8'h01; ARRAY[73 ] = 8'h86;
		ARRAY[74 ] = 8'h17; ARRAY[75 ] = 8'h8B;
		ARRAY[76 ] = 8'h16; ARRAY[77 ] = 8'h0B;
		ARRAY[78 ] = 8'h16; ARRAY[79 ] = 8'h8B;
		ARRAY[80 ] = 8'h12; ARRAY[81 ] = 8'h83;
		ARRAY[82 ] = 8'h01; ARRAY[83 ] = 8'hB4;
		ARRAY[84 ] = 8'h01; ARRAY[85 ] = 8'hB5;
		ARRAY[86 ] = 8'h00; ARRAY[87 ] = 8'h64;
		ARRAY[88 ] = 8'h30; ARRAY[89 ] = 8'h0A;
		ARRAY[90 ] = 8'h16; ARRAY[91 ] = 8'h83;
		ARRAY[92 ] = 8'h00; ARRAY[93 ] = 8'h81;
		ARRAY[94 ] = 8'h30; ARRAY[95 ] = 8'h50;
		ARRAY[96 ] = 8'h12; ARRAY[97 ] = 8'h83;
		ARRAY[98 ] = 8'h00; ARRAY[99 ] = 8'h81;
		ARRAY[100] = 8'h30; ARRAY[101] = 8'h12;
		ARRAY[102] = 8'h00; ARRAY[103] = 8'h85;
		ARRAY[104] = 8'h30; ARRAY[105] = 8'h34;
		ARRAY[106] = 8'h00; ARRAY[107] = 8'h86;
		ARRAY[108] = 8'h30; ARRAY[109] = 8'h2C;
		ARRAY[110] = 8'h00; ARRAY[111] = 8'h84;
		ARRAY[112] = 8'h30; ARRAY[113] = 8'h38;
		ARRAY[114] = 8'h00; ARRAY[115] = 8'hA8;
		ARRAY[116] = 8'h08; ARRAY[117] = 8'h04;
		ARRAY[118] = 8'h00; ARRAY[119] = 8'hA9;
		ARRAY[120] = 8'h30; ARRAY[121] = 8'h08;
		ARRAY[122] = 8'h00; ARRAY[123] = 8'hAA;
		ARRAY[124] = 8'h08; ARRAY[125] = 8'h28;
		ARRAY[126] = 8'h00; ARRAY[127] = 8'h84;
		ARRAY[128] = 8'h13; ARRAY[129] = 8'h83;
		ARRAY[130] = 8'h08; ARRAY[131] = 8'h00;
		ARRAY[132] = 8'h00; ARRAY[133] = 8'hAB;
		ARRAY[134] = 8'h0A; ARRAY[135] = 8'hA8;
		ARRAY[136] = 8'h08; ARRAY[137] = 8'h29;
		ARRAY[138] = 8'h00; ARRAY[139] = 8'h84;
		ARRAY[140] = 8'h08; ARRAY[141] = 8'h2B;
		ARRAY[142] = 8'h00; ARRAY[143] = 8'h80;
		ARRAY[144] = 8'h0A; ARRAY[145] = 8'hA9;
		ARRAY[146] = 8'h0B; ARRAY[147] = 8'hAA;
		ARRAY[148] = 8'h28; ARRAY[149] = 8'h3E;
		ARRAY[150] = 8'h01; ARRAY[151] = 8'hB6;
		ARRAY[152] = 8'h01; ARRAY[153] = 8'hB7;
		ARRAY[154] = 8'h08; ARRAY[155] = 8'h37;
		ARRAY[156] = 8'h3A; ARRAY[157] = 8'h80;
		ARRAY[158] = 8'h00; ARRAY[159] = 8'hCF;
		ARRAY[160] = 8'h30; ARRAY[161] = 8'h80;
		ARRAY[162] = 8'h02; ARRAY[163] = 8'h4F;
		ARRAY[164] = 8'h1D; ARRAY[165] = 8'h03;
		ARRAY[166] = 8'h28; ARRAY[167] = 8'h56;
		ARRAY[168] = 8'h30; ARRAY[169] = 8'h04;
		ARRAY[170] = 8'h02; ARRAY[171] = 8'h36;
		ARRAY[172] = 8'h18; ARRAY[173] = 8'h03;
		ARRAY[174] = 8'h28; ARRAY[175] = 8'h72;
		ARRAY[176] = 8'h12; ARRAY[177] = 8'h83;
		ARRAY[178] = 8'h08; ARRAY[179] = 8'h36;
		ARRAY[180] = 8'h00; ARRAY[181] = 8'hA8;
		ARRAY[182] = 8'h07; ARRAY[183] = 8'h28;
		ARRAY[184] = 8'h3E; ARRAY[185] = 8'h2C;
		ARRAY[186] = 8'h00; ARRAY[187] = 8'h84;
		ARRAY[188] = 8'h13; ARRAY[189] = 8'h83;
		ARRAY[190] = 8'h08; ARRAY[191] = 8'h00;
		ARRAY[192] = 8'h00; ARRAY[193] = 8'h85;
		ARRAY[194] = 8'h30; ARRAY[195] = 8'h01;
		ARRAY[196] = 8'h07; ARRAY[197] = 8'hB6;
		ARRAY[198] = 8'h18; ARRAY[199] = 8'h03;
		ARRAY[200] = 8'h0A; ARRAY[201] = 8'hB7;
		ARRAY[202] = 8'h30; ARRAY[203] = 8'h00;
		ARRAY[204] = 8'h07; ARRAY[205] = 8'hB7;
		ARRAY[206] = 8'h08; ARRAY[207] = 8'h37;
		ARRAY[208] = 8'h3A; ARRAY[209] = 8'h80;
		ARRAY[210] = 8'h00; ARRAY[211] = 8'hCF;
		ARRAY[212] = 8'h30; ARRAY[213] = 8'h80;
		ARRAY[214] = 8'h02; ARRAY[215] = 8'h4F;
		ARRAY[216] = 8'h1D; ARRAY[217] = 8'h03;
		ARRAY[218] = 8'h28; ARRAY[219] = 8'h70;
		ARRAY[220] = 8'h30; ARRAY[221] = 8'h04;
		ARRAY[222] = 8'h02; ARRAY[223] = 8'h36;
		ARRAY[224] = 8'h1C; ARRAY[225] = 8'h03;
		ARRAY[226] = 8'h28; ARRAY[227] = 8'h58;
		ARRAY[228] = 8'h12; ARRAY[229] = 8'h83;
		ARRAY[230] = 8'h08; ARRAY[231] = 8'h37;
		ARRAY[232] = 8'h00; ARRAY[233] = 8'h9B;
		ARRAY[234] = 8'h08; ARRAY[235] = 8'h36;
		ARRAY[236] = 8'h00; ARRAY[237] = 8'h9A;
		ARRAY[238] = 8'h30; ARRAY[239] = 8'h2C;
		ARRAY[240] = 8'h20; ARRAY[241] = 8'hB2;
		ARRAY[242] = 8'h00; ARRAY[243] = 8'h64;
		ARRAY[244] = 8'h12; ARRAY[245] = 8'h83;
		ARRAY[246] = 8'h01; ARRAY[247] = 8'hB6;
		ARRAY[248] = 8'h01; ARRAY[249] = 8'hB7;
		ARRAY[250] = 8'h08; ARRAY[251] = 8'h37;
		ARRAY[252] = 8'h3A; ARRAY[253] = 8'h80;
		ARRAY[254] = 8'h00; ARRAY[255] = 8'hCF;
		ARRAY[256] = 8'h30; ARRAY[257] = 8'h80;
		ARRAY[258] = 8'h02; ARRAY[259] = 8'h4F;
		ARRAY[260] = 8'h1D; ARRAY[261] = 8'h03;
		ARRAY[262] = 8'h28; ARRAY[263] = 8'h86;
		ARRAY[264] = 8'h30; ARRAY[265] = 8'h04;
		ARRAY[266] = 8'h02; ARRAY[267] = 8'h36;
		ARRAY[268] = 8'h18; ARRAY[269] = 8'h03;
		ARRAY[270] = 8'h28; ARRAY[271] = 8'hAA;
		ARRAY[272] = 8'h12; ARRAY[273] = 8'h83;
		ARRAY[274] = 8'h08; ARRAY[275] = 8'h36;
		ARRAY[276] = 8'h00; ARRAY[277] = 8'hA8;
		ARRAY[278] = 8'h07; ARRAY[279] = 8'h28;
		ARRAY[280] = 8'h3E; ARRAY[281] = 8'h2C;
		ARRAY[282] = 8'h00; ARRAY[283] = 8'h84;
		ARRAY[284] = 8'h13; ARRAY[285] = 8'h83;
		ARRAY[286] = 8'h08; ARRAY[287] = 8'h00;
		ARRAY[288] = 8'h00; ARRAY[289] = 8'h85;
		ARRAY[290] = 8'h30; ARRAY[291] = 8'h05;
		ARRAY[292] = 8'h00; ARRAY[293] = 8'hA8;
		ARRAY[294] = 8'h08; ARRAY[295] = 8'h28;
		ARRAY[296] = 8'h00; ARRAY[297] = 8'h94;
		ARRAY[298] = 8'h08; ARRAY[299] = 8'h34;
		ARRAY[300] = 8'h21; ARRAY[301] = 8'h79;
		ARRAY[302] = 8'h12; ARRAY[303] = 8'h83;
		ARRAY[304] = 8'h00; ARRAY[305] = 8'h86;
		ARRAY[306] = 8'h30; ARRAY[307] = 8'h01;
		ARRAY[308] = 8'h07; ARRAY[309] = 8'hB6;
		ARRAY[310] = 8'h18; ARRAY[311] = 8'h03;
		ARRAY[312] = 8'h0A; ARRAY[313] = 8'hB7;
		ARRAY[314] = 8'h30; ARRAY[315] = 8'h00;
		ARRAY[316] = 8'h07; ARRAY[317] = 8'hB7;
		ARRAY[318] = 8'h08; ARRAY[319] = 8'h37;
		ARRAY[320] = 8'h3A; ARRAY[321] = 8'h80;
		ARRAY[322] = 8'h00; ARRAY[323] = 8'hCF;
		ARRAY[324] = 8'h30; ARRAY[325] = 8'h80;
		ARRAY[326] = 8'h02; ARRAY[327] = 8'h4F;
		ARRAY[328] = 8'h1D; ARRAY[329] = 8'h03;
		ARRAY[330] = 8'h28; ARRAY[331] = 8'hA8;
		ARRAY[332] = 8'h30; ARRAY[333] = 8'h04;
		ARRAY[334] = 8'h02; ARRAY[335] = 8'h36;
		ARRAY[336] = 8'h1C; ARRAY[337] = 8'h03;
		ARRAY[338] = 8'h28; ARRAY[339] = 8'h88;
		ARRAY[340] = 8'h30; ARRAY[341] = 8'h01;
		ARRAY[342] = 8'h12; ARRAY[343] = 8'h83;
		ARRAY[344] = 8'h07; ARRAY[345] = 8'hB4;
		ARRAY[346] = 8'h18; ARRAY[347] = 8'h03;
		ARRAY[348] = 8'h0A; ARRAY[349] = 8'hB5;
		ARRAY[350] = 8'h30; ARRAY[351] = 8'h00;
		ARRAY[352] = 8'h07; ARRAY[353] = 8'hB5;
		ARRAY[354] = 8'h28; ARRAY[355] = 8'h79;
		ARRAY[356] = 8'h12; ARRAY[357] = 8'h83;
		ARRAY[358] = 8'h00; ARRAY[359] = 8'hA5;
		ARRAY[360] = 8'h00; ARRAY[361] = 8'h64;
		ARRAY[362] = 8'h30; ARRAY[363] = 8'h03;
		ARRAY[364] = 8'h12; ARRAY[365] = 8'h83;
		ARRAY[366] = 8'h00; ARRAY[367] = 8'h9A;
		ARRAY[368] = 8'h30; ARRAY[369] = 8'h00;
		ARRAY[370] = 8'h00; ARRAY[371] = 8'h9B;
		ARRAY[372] = 8'h08; ARRAY[373] = 8'h1B;
		ARRAY[374] = 8'h3A; ARRAY[375] = 8'h80;
		ARRAY[376] = 8'h00; ARRAY[377] = 8'hCF;
		ARRAY[378] = 8'h30; ARRAY[379] = 8'h80;
		ARRAY[380] = 8'h02; ARRAY[381] = 8'h4F;
		ARRAY[382] = 8'h1D; ARRAY[383] = 8'h03;
		ARRAY[384] = 8'h28; ARRAY[385] = 8'hC3;
		ARRAY[386] = 8'h30; ARRAY[387] = 8'h01;
		ARRAY[388] = 8'h02; ARRAY[389] = 8'h1A;
		ARRAY[390] = 8'h1C; ARRAY[391] = 8'h03;
		ARRAY[392] = 8'h00; ARRAY[393] = 8'h08;
		ARRAY[394] = 8'h12; ARRAY[395] = 8'h83;
		ARRAY[396] = 8'h01; ARRAY[397] = 8'hA6;
		ARRAY[398] = 8'h01; ARRAY[399] = 8'hA7;
		ARRAY[400] = 8'h08; ARRAY[401] = 8'h1A;
		ARRAY[402] = 8'h3E; ARRAY[403] = 8'hFF;
		ARRAY[404] = 8'h00; ARRAY[405] = 8'h9C;
		ARRAY[406] = 8'h08; ARRAY[407] = 8'h1B;
		ARRAY[408] = 8'h18; ARRAY[409] = 8'h03;
		ARRAY[410] = 8'h3E; ARRAY[411] = 8'h01;
		ARRAY[412] = 8'h3E; ARRAY[413] = 8'hFF;
		ARRAY[414] = 8'h00; ARRAY[415] = 8'h9D;
		ARRAY[416] = 8'h08; ARRAY[417] = 8'h1D;
		ARRAY[418] = 8'h3A; ARRAY[419] = 8'h80;
		ARRAY[420] = 8'h00; ARRAY[421] = 8'h9E;
		ARRAY[422] = 8'h08; ARRAY[423] = 8'h27;
		ARRAY[424] = 8'h3A; ARRAY[425] = 8'h80;
		ARRAY[426] = 8'h02; ARRAY[427] = 8'h1E;
		ARRAY[428] = 8'h1D; ARRAY[429] = 8'h03;
		ARRAY[430] = 8'h28; ARRAY[431] = 8'hDA;
		ARRAY[432] = 8'h08; ARRAY[433] = 8'h26;
		ARRAY[434] = 8'h02; ARRAY[435] = 8'h1C;
		ARRAY[436] = 8'h1C; ARRAY[437] = 8'h03;
		ARRAY[438] = 8'h29; ARRAY[439] = 8'h1E;
		ARRAY[440] = 8'h00; ARRAY[441] = 8'h64;
		ARRAY[442] = 8'h12; ARRAY[443] = 8'h83;
		ARRAY[444] = 8'h08; ARRAY[445] = 8'h26;
		ARRAY[446] = 8'h00; ARRAY[447] = 8'h9C;
		ARRAY[448] = 8'h07; ARRAY[449] = 8'h1C;
		ARRAY[450] = 8'h3E; ARRAY[451] = 8'h02;
		ARRAY[452] = 8'h07; ARRAY[453] = 8'h25;
		ARRAY[454] = 8'h00; ARRAY[455] = 8'h9D;
		ARRAY[456] = 8'h08; ARRAY[457] = 8'h1D;
		ARRAY[458] = 8'h00; ARRAY[459] = 8'h84;
		ARRAY[460] = 8'h13; ARRAY[461] = 8'h83;
		ARRAY[462] = 8'h08; ARRAY[463] = 8'h00;
		ARRAY[464] = 8'h00; ARRAY[465] = 8'h9E;
		ARRAY[466] = 8'h0A; ARRAY[467] = 8'h84;
		ARRAY[468] = 8'h08; ARRAY[469] = 8'h00;
		ARRAY[470] = 8'h00; ARRAY[471] = 8'h9F;
		ARRAY[472] = 8'h08; ARRAY[473] = 8'h26;
		ARRAY[474] = 8'h00; ARRAY[475] = 8'hA0;
		ARRAY[476] = 8'h07; ARRAY[477] = 8'h20;
		ARRAY[478] = 8'h07; ARRAY[479] = 8'h25;
		ARRAY[480] = 8'h00; ARRAY[481] = 8'hA1;
		ARRAY[482] = 8'h08; ARRAY[483] = 8'h21;
		ARRAY[484] = 8'h00; ARRAY[485] = 8'h84;
		ARRAY[486] = 8'h08; ARRAY[487] = 8'h00;
		ARRAY[488] = 8'h00; ARRAY[489] = 8'hA2;
		ARRAY[490] = 8'h0A; ARRAY[491] = 8'h84;
		ARRAY[492] = 8'h08; ARRAY[493] = 8'h00;
		ARRAY[494] = 8'h00; ARRAY[495] = 8'hA3;
		ARRAY[496] = 8'h08; ARRAY[497] = 8'h23;
		ARRAY[498] = 8'h3A; ARRAY[499] = 8'h80;
		ARRAY[500] = 8'h00; ARRAY[501] = 8'hA4;
		ARRAY[502] = 8'h08; ARRAY[503] = 8'h1F;
		ARRAY[504] = 8'h3A; ARRAY[505] = 8'h80;
		ARRAY[506] = 8'h02; ARRAY[507] = 8'h24;
		ARRAY[508] = 8'h1D; ARRAY[509] = 8'h03;
		ARRAY[510] = 8'h29; ARRAY[511] = 8'h02;
		ARRAY[512] = 8'h08; ARRAY[513] = 8'h1E;
		ARRAY[514] = 8'h02; ARRAY[515] = 8'h22;
		ARRAY[516] = 8'h18; ARRAY[517] = 8'h03;
		ARRAY[518] = 8'h29; ARRAY[519] = 8'h12;
		ARRAY[520] = 8'h12; ARRAY[521] = 8'h83;
		ARRAY[522] = 8'h08; ARRAY[523] = 8'h26;
		ARRAY[524] = 8'h00; ARRAY[525] = 8'h9C;
		ARRAY[526] = 8'h07; ARRAY[527] = 8'h1C;
		ARRAY[528] = 8'h3E; ARRAY[529] = 8'h02;
		ARRAY[530] = 8'h07; ARRAY[531] = 8'h25;
		ARRAY[532] = 8'h00; ARRAY[533] = 8'h9D;
		ARRAY[534] = 8'h08; ARRAY[535] = 8'h1D;
		ARRAY[536] = 8'h00; ARRAY[537] = 8'h94;
		ARRAY[538] = 8'h08; ARRAY[539] = 8'h26;
		ARRAY[540] = 8'h00; ARRAY[541] = 8'h9E;
		ARRAY[542] = 8'h07; ARRAY[543] = 8'h1E;
		ARRAY[544] = 8'h07; ARRAY[545] = 8'h25;
		ARRAY[546] = 8'h21; ARRAY[547] = 8'h57;
		ARRAY[548] = 8'h12; ARRAY[549] = 8'h83;
		ARRAY[550] = 8'h08; ARRAY[551] = 8'h1A;
		ARRAY[552] = 8'h00; ARRAY[553] = 8'h85;
		ARRAY[554] = 8'h08; ARRAY[555] = 8'h26;
		ARRAY[556] = 8'h00; ARRAY[557] = 8'h86;
		ARRAY[558] = 8'h30; ARRAY[559] = 8'h01;
		ARRAY[560] = 8'h07; ARRAY[561] = 8'hA6;
		ARRAY[562] = 8'h18; ARRAY[563] = 8'h03;
		ARRAY[564] = 8'h0A; ARRAY[565] = 8'hA7;
		ARRAY[566] = 8'h30; ARRAY[567] = 8'h00;
		ARRAY[568] = 8'h07; ARRAY[569] = 8'hA7;
		ARRAY[570] = 8'h28; ARRAY[571] = 8'hC8;
		ARRAY[572] = 8'h30; ARRAY[573] = 8'hFF;
		ARRAY[574] = 8'h12; ARRAY[575] = 8'h83;
		ARRAY[576] = 8'h07; ARRAY[577] = 8'h9A;
		ARRAY[578] = 8'h18; ARRAY[579] = 8'h03;
		ARRAY[580] = 8'h0A; ARRAY[581] = 8'h9B;
		ARRAY[582] = 8'h30; ARRAY[583] = 8'hFF;
		ARRAY[584] = 8'h07; ARRAY[585] = 8'h9B;
		ARRAY[586] = 8'h28; ARRAY[587] = 8'hBA;
		ARRAY[588] = 8'h13; ARRAY[589] = 8'h8B;
		ARRAY[590] = 8'h08; ARRAY[591] = 8'h03;
		ARRAY[592] = 8'h00; ARRAY[593] = 8'h8C;
		ARRAY[594] = 8'h01; ARRAY[595] = 8'h8D;
		ARRAY[596] = 8'h08; ARRAY[597] = 8'h0C;
		ARRAY[598] = 8'h00; ARRAY[599] = 8'h92;
		ARRAY[600] = 8'h08; ARRAY[601] = 8'h0D;
		ARRAY[602] = 8'h00; ARRAY[603] = 8'h93;
		ARRAY[604] = 8'h30; ARRAY[605] = 8'h01;
		ARRAY[606] = 8'h1C; ARRAY[607] = 8'h8B;
		ARRAY[608] = 8'h39; ARRAY[609] = 8'h00;
		ARRAY[610] = 8'h1E; ARRAY[611] = 8'h0B;
		ARRAY[612] = 8'h39; ARRAY[613] = 8'h00;
		ARRAY[614] = 8'h38; ARRAY[615] = 8'h00;
		ARRAY[616] = 8'h19; ARRAY[617] = 8'h03;
		ARRAY[618] = 8'h29; ARRAY[619] = 8'h39;
		ARRAY[620] = 8'h10; ARRAY[621] = 8'h8B;
		ARRAY[622] = 8'h21; ARRAY[623] = 8'h93;
		ARRAY[624] = 8'h29; ARRAY[625] = 8'h49;
		ARRAY[626] = 8'h30; ARRAY[627] = 8'h01;
		ARRAY[628] = 8'h1D; ARRAY[629] = 8'h0B;
		ARRAY[630] = 8'h39; ARRAY[631] = 8'h00;
		ARRAY[632] = 8'h1E; ARRAY[633] = 8'h8B;
		ARRAY[634] = 8'h39; ARRAY[635] = 8'h00;
		ARRAY[636] = 8'h38; ARRAY[637] = 8'h00;
		ARRAY[638] = 8'h19; ARRAY[639] = 8'h03;
		ARRAY[640] = 8'h29; ARRAY[641] = 8'h49;
		ARRAY[642] = 8'h11; ARRAY[643] = 8'h0B;
		ARRAY[644] = 8'h30; ARRAY[645] = 8'hDD;
		ARRAY[646] = 8'h12; ARRAY[647] = 8'h83;
		ARRAY[648] = 8'h00; ARRAY[649] = 8'h85;
		ARRAY[650] = 8'h30; ARRAY[651] = 8'h10;
		ARRAY[652] = 8'h00; ARRAY[653] = 8'h8C;
		ARRAY[654] = 8'h08; ARRAY[655] = 8'h0C;
		ARRAY[656] = 8'h07; ARRAY[657] = 8'h86;
		ARRAY[658] = 8'h12; ARRAY[659] = 8'h83;
		ARRAY[660] = 8'h08; ARRAY[661] = 8'h12;
		ARRAY[662] = 8'h00; ARRAY[663] = 8'h83;
		ARRAY[664] = 8'h08; ARRAY[665] = 8'h11;
		ARRAY[666] = 8'h00; ARRAY[667] = 8'hCF;
		ARRAY[668] = 8'h08; ARRAY[669] = 8'h10;
		ARRAY[670] = 8'h00; ARRAY[671] = 8'h8A;
		ARRAY[672] = 8'h08; ARRAY[673] = 8'h0F;
		ARRAY[674] = 8'h00; ARRAY[675] = 8'h84;
		ARRAY[676] = 8'h0E; ARRAY[677] = 8'h0E;
		ARRAY[678] = 8'h00; ARRAY[679] = 8'h83;
		ARRAY[680] = 8'h0E; ARRAY[681] = 8'hCE;
		ARRAY[682] = 8'h0E; ARRAY[683] = 8'h4E;
		ARRAY[684] = 8'h00; ARRAY[685] = 8'h09;
		ARRAY[686] = 8'h12; ARRAY[687] = 8'h83;
		ARRAY[688] = 8'h00; ARRAY[689] = 8'h99;
		ARRAY[690] = 8'h00; ARRAY[691] = 8'h64;
		ARRAY[692] = 8'h12; ARRAY[693] = 8'h83;
		ARRAY[694] = 8'h08; ARRAY[695] = 8'h19;
		ARRAY[696] = 8'h00; ARRAY[697] = 8'h84;
		ARRAY[698] = 8'h13; ARRAY[699] = 8'h83;
		ARRAY[700] = 8'h08; ARRAY[701] = 8'h00;
		ARRAY[702] = 8'h00; ARRAY[703] = 8'h97;
		ARRAY[704] = 8'h0A; ARRAY[705] = 8'h84;
		ARRAY[706] = 8'h08; ARRAY[707] = 8'h00;
		ARRAY[708] = 8'h00; ARRAY[709] = 8'h98;
		ARRAY[710] = 8'h08; ARRAY[711] = 8'h14;
		ARRAY[712] = 8'h00; ARRAY[713] = 8'h84;
		ARRAY[714] = 8'h08; ARRAY[715] = 8'h00;
		ARRAY[716] = 8'h00; ARRAY[717] = 8'h95;
		ARRAY[718] = 8'h0A; ARRAY[719] = 8'h84;
		ARRAY[720] = 8'h08; ARRAY[721] = 8'h00;
		ARRAY[722] = 8'h00; ARRAY[723] = 8'h96;
		ARRAY[724] = 8'h08; ARRAY[725] = 8'h19;
		ARRAY[726] = 8'h00; ARRAY[727] = 8'h84;
		ARRAY[728] = 8'h08; ARRAY[729] = 8'h15;
		ARRAY[730] = 8'h00; ARRAY[731] = 8'h80;
		ARRAY[732] = 8'h0A; ARRAY[733] = 8'h84;
		ARRAY[734] = 8'h08; ARRAY[735] = 8'h16;
		ARRAY[736] = 8'h00; ARRAY[737] = 8'h80;
		ARRAY[738] = 8'h08; ARRAY[739] = 8'h14;
		ARRAY[740] = 8'h00; ARRAY[741] = 8'h84;
		ARRAY[742] = 8'h08; ARRAY[743] = 8'h17;
		ARRAY[744] = 8'h00; ARRAY[745] = 8'h80;
		ARRAY[746] = 8'h0A; ARRAY[747] = 8'h84;
		ARRAY[748] = 8'h08; ARRAY[749] = 8'h18;
		ARRAY[750] = 8'h00; ARRAY[751] = 8'h80;
		ARRAY[752] = 8'h00; ARRAY[753] = 8'h08;
		ARRAY[754] = 8'h12; ARRAY[755] = 8'h83;
		ARRAY[756] = 8'h00; ARRAY[757] = 8'h97;
		ARRAY[758] = 8'h01; ARRAY[759] = 8'h96;
		ARRAY[760] = 8'h1C; ARRAY[761] = 8'h17;
		ARRAY[762] = 8'h29; ARRAY[763] = 8'h82;
		ARRAY[764] = 8'h08; ARRAY[765] = 8'h14;
		ARRAY[766] = 8'h00; ARRAY[767] = 8'h95;
		ARRAY[768] = 8'h08; ARRAY[769] = 8'h15;
		ARRAY[770] = 8'h07; ARRAY[771] = 8'h96;
		ARRAY[772] = 8'h10; ARRAY[773] = 8'h03;
		ARRAY[774] = 8'h0D; ARRAY[775] = 8'h94;
		ARRAY[776] = 8'h10; ARRAY[777] = 8'h03;
		ARRAY[778] = 8'h0C; ARRAY[779] = 8'h97;
		ARRAY[780] = 8'h08; ARRAY[781] = 8'h17;
		ARRAY[782] = 8'h1D; ARRAY[783] = 8'h03;
		ARRAY[784] = 8'h29; ARRAY[785] = 8'h7C;
		ARRAY[786] = 8'h08; ARRAY[787] = 8'h16;
		ARRAY[788] = 8'h00; ARRAY[789] = 8'h08;
		ARRAY[790] = 8'h34; ARRAY[791] = 8'h85;
		ARRAY[792] = 8'h34; ARRAY[793] = 8'h00;
		ARRAY[794] = 8'h34; ARRAY[795] = 8'h02;
		ARRAY[796] = 8'h34; ARRAY[797] = 8'h00;
		ARRAY[798] = 8'h34; ARRAY[799] = 8'h46;
		ARRAY[800] = 8'h34; ARRAY[801] = 8'h00;
		ARRAY[802] = 8'h34; ARRAY[803] = 8'hE4;
		ARRAY[804] = 8'h34; ARRAY[805] = 8'h00;
		ARRAY[806] = 8'h30; ARRAY[807] = 8'h66;
		ARRAY[808] = 8'h12; ARRAY[809] = 8'h83;
		ARRAY[810] = 8'h00; ARRAY[811] = 8'h85;
		ARRAY[812] = 8'h30; ARRAY[813] = 8'h05;
		ARRAY[814] = 8'h02; ARRAY[815] = 8'h86;
		ARRAY[816] = 8'h00; ARRAY[817] = 8'h08;

		ARRAY[4096] = 8'h04;
	
	if ( Init_File != "none" )
	    $readmemh(Init_File,ARRAY) ;
        for( i = 0; i <=  SFDP_TOP_Add; i = i + 1 ) begin
            SFDP_ARRAY[i] = 8'hff;
        end
        // define SFDP code
        SFDP_ARRAY[8'h0] =  8'h53;
        SFDP_ARRAY[8'h1] =  8'h46;
        SFDP_ARRAY[8'h2] =  8'h44;
        SFDP_ARRAY[8'h3] =  8'h50;
        SFDP_ARRAY[8'h4] =  8'h00;
        SFDP_ARRAY[8'h5] =  8'h01;
        SFDP_ARRAY[8'h6] =  8'h01;
        SFDP_ARRAY[8'h7] =  8'hff;
        SFDP_ARRAY[8'h8] =  8'h00;
        SFDP_ARRAY[8'h9] =  8'h00;
        SFDP_ARRAY[8'ha] =  8'h01;
        SFDP_ARRAY[8'hb] =  8'h09;
        SFDP_ARRAY[8'hc] =  8'h30;
        SFDP_ARRAY[8'hd] =  8'h00;
        SFDP_ARRAY[8'he] =  8'h00;
        SFDP_ARRAY[8'hf] =  8'hff;
        SFDP_ARRAY[8'h10] =  8'hc2;
        SFDP_ARRAY[8'h11] =  8'h00;
        SFDP_ARRAY[8'h12] =  8'h01;
        SFDP_ARRAY[8'h13] =  8'h04;
        SFDP_ARRAY[8'h14] =  8'h60;
        SFDP_ARRAY[8'h15] =  8'h00;
        SFDP_ARRAY[8'h16] =  8'h00;
        SFDP_ARRAY[8'h17] =  8'hff;
        SFDP_ARRAY[8'h18] =  8'hff;
        SFDP_ARRAY[8'h19] =  8'hff;
        SFDP_ARRAY[8'h1a] =  8'hff;
        SFDP_ARRAY[8'h1b] =  8'hff;
        SFDP_ARRAY[8'h1c] =  8'hff;
        SFDP_ARRAY[8'h1d] =  8'hff;
        SFDP_ARRAY[8'h1e] =  8'hff;
        SFDP_ARRAY[8'h1f] =  8'hff;
        SFDP_ARRAY[8'h20] =  8'hff;
        SFDP_ARRAY[8'h21] =  8'hff;
        SFDP_ARRAY[8'h22] =  8'hff;
        SFDP_ARRAY[8'h23] =  8'hff;
        SFDP_ARRAY[8'h24] =  8'hff;
        SFDP_ARRAY[8'h25] =  8'hff;
        SFDP_ARRAY[8'h26] =  8'hff;
        SFDP_ARRAY[8'h27] =  8'hff;
        SFDP_ARRAY[8'h28] =  8'hff;
        SFDP_ARRAY[8'h29] =  8'hff;
        SFDP_ARRAY[8'h2a] =  8'hff;
        SFDP_ARRAY[8'h2b] =  8'hff;
        SFDP_ARRAY[8'h2c] =  8'hff;
        SFDP_ARRAY[8'h2d] =  8'hff;
        SFDP_ARRAY[8'h2e] =  8'hff;
        SFDP_ARRAY[8'h2f] =  8'hff;
        SFDP_ARRAY[8'h30] =  8'he5;
        SFDP_ARRAY[8'h31] =  8'h20;
        SFDP_ARRAY[8'h32] =  8'h81;
        SFDP_ARRAY[8'h33] =  8'hff;
        SFDP_ARRAY[8'h34] =  8'hff;
        SFDP_ARRAY[8'h35] =  8'hff;
        SFDP_ARRAY[8'h36] =  8'h0f;
        SFDP_ARRAY[8'h37] =  8'h00;
        SFDP_ARRAY[8'h38] =  8'h00;
        SFDP_ARRAY[8'h39] =  8'hff;
        SFDP_ARRAY[8'h3a] =  8'h00;
        SFDP_ARRAY[8'h3b] =  8'hff;
        SFDP_ARRAY[8'h3c] =  8'h08;
        SFDP_ARRAY[8'h3d] =  8'h3b;
        SFDP_ARRAY[8'h3e] =  8'h00;
        SFDP_ARRAY[8'h3f] =  8'hff;
        SFDP_ARRAY[8'h40] =  8'hee;
        SFDP_ARRAY[8'h41] =  8'hff;
        SFDP_ARRAY[8'h42] =  8'hff;
        SFDP_ARRAY[8'h43] =  8'hff;
        SFDP_ARRAY[8'h44] =  8'hff;
        SFDP_ARRAY[8'h45] =  8'hff;
        SFDP_ARRAY[8'h46] =  8'h00;
        SFDP_ARRAY[8'h47] =  8'hff;
        SFDP_ARRAY[8'h48] =  8'hff;
        SFDP_ARRAY[8'h49] =  8'hff;
        SFDP_ARRAY[8'h4a] =  8'h00;
        SFDP_ARRAY[8'h4b] =  8'hff;
        SFDP_ARRAY[8'h4c] =  8'h0c;
        SFDP_ARRAY[8'h4d] =  8'h20;
        SFDP_ARRAY[8'h4e] =  8'h10;
        SFDP_ARRAY[8'h4f] =  8'hd8;
        SFDP_ARRAY[8'h50] =  8'h00;
        SFDP_ARRAY[8'h51] =  8'hff;
        SFDP_ARRAY[8'h52] =  8'h00;
        SFDP_ARRAY[8'h53] =  8'hff;
        SFDP_ARRAY[8'h54] =  8'hff;
        SFDP_ARRAY[8'h55] =  8'hff;
        SFDP_ARRAY[8'h56] =  8'hff;
        SFDP_ARRAY[8'h57] =  8'hff;
        SFDP_ARRAY[8'h58] =  8'hff;
        SFDP_ARRAY[8'h59] =  8'hff;
        SFDP_ARRAY[8'h5a] =  8'hff;
        SFDP_ARRAY[8'h5b] =  8'hff;
        SFDP_ARRAY[8'h5c] =  8'hff;
        SFDP_ARRAY[8'h5d] =  8'hff;
        SFDP_ARRAY[8'h5e] =  8'hff;
        SFDP_ARRAY[8'h5f] =  8'hff;
        SFDP_ARRAY[8'h60] =  8'h00;
        SFDP_ARRAY[8'h61] =  8'h36;
        SFDP_ARRAY[8'h62] =  8'h00;
        SFDP_ARRAY[8'h63] =  8'h27;
        SFDP_ARRAY[8'h64] =  8'hf6;
        SFDP_ARRAY[8'h65] =  8'h4f;
        SFDP_ARRAY[8'h66] =  8'hff;
        SFDP_ARRAY[8'h67] =  8'hff;
        SFDP_ARRAY[8'h68] =  8'hfe;
        SFDP_ARRAY[8'h69] =  8'hc7;
        SFDP_ARRAY[8'h6a] =  8'hff;
        SFDP_ARRAY[8'h6b] =  8'hff;
        SFDP_ARRAY[8'h6c] =  8'hff;
        SFDP_ARRAY[8'h6d] =  8'hff;
        SFDP_ARRAY[8'h6e] =  8'hff;
        SFDP_ARRAY[8'h6f] =  8'hff;

    end

// *============================================================================================== 
// * Input/Output bus operation 
// *============================================================================================== 
    assign   ISCLK  = (SCLK_EN == 1'b1) ? SCLK:1'b0;
    assign   HOLD_B_INT = (CS == 1'b0 ) ? HOLD : 1'b1;
    assign   WP_B_INT   = (CS == 1'b0 ) ? WP : 1'b1;
    assign   SO     = (SO_OUT_EN && HOLD_OUT_B) ? SIO1_Reg : 1'bz ;
    assign   SI     = (SI_OUT_EN && HOLD_OUT_B) ? SIO0_Reg : 1'bz ;

    /*----------------------------------------------------------------------*/
    /*  When  Hold Condtion Operation;                                      */
    /*----------------------------------------------------------------------*/
    always @ ( HOLD_B_INT or negedge SCLK) begin
        if ( HOLD_B_INT == 1'b0 && SCLK == 1'b0) begin
            SCLK_EN =1'b0;
            HOLD_OUT_B<= #tHLQZ 1'b0;
        end
        else if ( HOLD_B_INT == 1'b1 && SCLK == 1'b0) begin
            SCLK_EN =1'b1;
            HOLD_OUT_B<= #tHHQX 1'b1;
        end
    end

// *============================================================================================== 
// * Finite State machine to control Flash operation
// *============================================================================================== 
    /*----------------------------------------------------------------------*/
    /* power on              						    */
    /*----------------------------------------------------------------------*/
    initial begin 
	Chip_EN   <= #tVSL 1'b1;// Time delay to chip select allowed 
    end
    
    /*----------------------------------------------------------------------*/
    /* Command Decode        						    */
    /*----------------------------------------------------------------------*/
    assign WIP	    = Status_Reg[0] ;
    assign WEL	    = Status_Reg[1] ;
    assign SRWD     = Status_Reg[7] ;
    assign Dis_CE   = Status_Reg[3] == 1'b1 || Status_Reg[2] == 1'b1 ;
    assign Dis_WRSR = (WP_B_INT == 1'b0 && Status_Reg[7] == 1'b1) ;

    always @ ( negedge CS ) begin
        SI_IN_EN = 1'b1; 
        Read_SHSL <= #1 1'b0;
        #1;
        tDP_Chk = 1'b0; 
        tRES1_Chk = 1'b0; 
        tRES2_Chk = 1'b0; 
    end


    always @ ( posedge ISCLK or posedge CS ) begin
	if ( CS == 1'b0 ) begin
	    Bit_Tmp = Bit_Tmp + 1; 
	    Bit	= Bit_Tmp - 1;
	    SI_Reg[23:0] = {SI_Reg[22:0], SI};
	end	
  
	if ( Bit == 7 && CS == 1'b0 ) begin
	    STATE = `CMD_STATE;
	    CMD_BUS = SI_Reg[7:0];
	    //$display( $time,"SI_Reg[7:0]= %h ", SI_Reg[7:0] );
	end
	
	case ( STATE )
	    `STANDBY_STATE: 
	        begin
	        end
        
	    `CMD_STATE: 
	        begin
	            case ( CMD_BUS ) 
	            WREN: 
	    		begin
	    		    if ( !DP_Mode && !WIP && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 ) begin	
	    			    // $display( $time, " Enter Write Enable Function ..." );
	    			    write_enable;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE; 
	    		    end 
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE; 
	    		end
		     
	    	    WRDI:   
	    		begin
	                    if ( !DP_Mode && !WIP && Chip_EN ) begin
	                        if ( CS == 1'b1 && Bit == 7 ) begin	
	    			    // $display( $time, " Enter Write Disable Function ..." );
	    			    write_disable;
	                        end
	                        else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE; 
	    		    end 
	                    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE; 
	    		end 
	                 
	    	    RDID:
	    		begin  
	    		    if ( !DP_Mode && !WIP && Chip_EN ) begin 
	    			//$display( $time, " Enter Read ID Function ..." );
                               if ( Bit == 7 ) begin
	    			    RDID_Mode = 1'b1;
                                    Read_SHSL = 1'b1;
                                end 
                            end
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE; 	
	    		end
                      
	            RDSR:
	    		begin 
	    		    if ( !DP_Mode && Chip_EN ) begin 
	    			//$display( $time, " Enter Read Status Function ..." );
                                if ( Bit == 7 ) begin
	    			    RDSR_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
                                end 
                            end
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE; 	
	    		end
           
	            WRSR:
	    		begin
	    		    if ( !DP_Mode && !WIP && WEL && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 15 ) begin
                                    if ( Dis_WRSR ) begin
                                        Status_Reg[1] = 1'b0;
                                    end
                                    else begin
                                        //$display( $time, " Enter Write Status Function ..." );
                                        ->WRSR_Event;
                                        WRSR_Mode = 1'b1;
                                    end
	    			end    
	    			else if ( CS == 1'b1 && Bit < 15 || Bit > 15 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE;
	    		end 
                      
	            READ1X: 
	    		begin
	    		    if ( !DP_Mode && !WIP && Chip_EN ) 
					begin
						//$display( $time, " Enter Read Data Function ..." );
						if ( Bit == 31 ) begin
										Address = SI_Reg [A_MSB:0];
										load_address(Address);
						end
						if ( Bit == 7 ) begin
							Read_1XIO_Mode = 1'b1;
										Read_SHSL = 1'b1;
						end
	    		    end	
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;				
	    		end
                     
	            FASTREAD1X:
	    		begin
	    		    if ( !DP_Mode && !WIP && Chip_EN ) begin
	    			//$display( $time, " Enter Fast Read Data Function ..." );
                                Read_SHSL = 1'b1;
	    			if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
	    			end
	    			if ( Bit == 7 ) begin
	    			    FastRD_1XIO_Mode = 1'b1;
                                    Read_SHSL = 1'b1;
	    			end
	    		    end	
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;				
	    		end

                    SFDP_READ:
                        begin
                            if ( !DP_Mode && !WIP && Chip_EN ) begin
                                //$display( $time, " Enter SFDP read mode ..." );
                                if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
                                end
                                if ( Bit == 7 ) begin
                                    SFDP_Mode = 1;
                                        FastRD_1XIO_Mode = 1'b1;
                                    Read_SHSL = 1'b1;
                                end
                            end
                            else if ( Bit == 7 )
                                STATE <= `BAD_CMD_STATE;
                        end

	            FASTREAD2X:
	    		begin
	    		    if ( !DP_Mode && !WIP && Chip_EN ) begin
	    			//$display( $time, " Enter Fast Read dual output Function ..." );
                                Read_SHSL = 1'b1;
	    			if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
	    			end
	    			FastRD_2XIO_Mode =1'b1;
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;			    
	    		end
                      
	            SE: 
	    		begin
                            if ( !DP_Mode && !WIP && WEL &&  Chip_EN ) begin
	    			if ( Bit == 31 ) begin
	    			    Address =  SI_Reg[A_MSB:0];
	    			end
	    			if ( CS == 1'b1 && Bit == 31 && write_protect(Address) == 1'b0 ) begin
	    			    //$display( $time, " Enter Sector Erase Function ..." );
	    			    ->SE_4K_Event;
	    			    SE_4K_Mode = 1'b1;
	    			end
	    			else if ( CS == 1'b1 && Bit < 31 || Bit > 31 )
	                     	     STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE;
	    		end

	            BE1, BE2: 
	    		begin
	    		    if ( !DP_Mode && !WIP && WEL &&  Chip_EN ) begin
	    			if ( Bit == 31 ) begin
	    			    Address = SI_Reg[A_MSB:0] ;
	    			end
	    			if ( CS == 1'b1 && Bit == 31 && write_protect(Address) == 1'b0 ) begin
	    			    //$display( $time, " Enter Block Erase Function ..." );
	    			    ->BE_Event;
	    			    BE_Mode = 1'b1;
	    			end 
	    			else if ( CS == 1'b1 && Bit < 31 || Bit > 31 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end 
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE;
	    		end
                      
	            CE1, CE2:
	    		begin
	    		    if ( !DP_Mode && !WIP && WEL &&  Chip_EN ) begin

	    			if ( CS == 1'b1 && Bit == 7 && Dis_CE == 0 ) begin
	    			    //$display( $time, " Enter Chip Erase Function ..." );
	    			    ->CE_Event;
	    			    CE_Mode = 1'b1 ;
	    			end 
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end
	    		    else if ( Bit == 7 ) 
	    			STATE <= `BAD_CMD_STATE;
	    		end
                      
	            PP: 
	    		begin
	    		    if ( !DP_Mode && !WIP && WEL && Chip_EN ) begin
	    			if ( Bit == 31 ) begin
                                    Address = SI_Reg [A_MSB:0];
                                    load_address(Address);
	    			end
	    			if ( CS == 1'b0 && Bit == 31 && write_protect(Address) == 1'b0 ) begin
	    			    //$display( $time, " Enter Page Program Function ..." );
				    ->PP_Event;
				    PP_1XIO_Mode = 1'b1;
	    			end
	    			else if ( CS == 1 && (Bit < 39 || ((Bit + 1) % 8 !== 0))) begin
	    			    STATE <= `BAD_CMD_STATE;
	    			end
                            end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;
	    		end
                      
	            DP: 
	    		begin
	    		    if ( !WIP && Chip_EN ) begin
	    			if ( CS == 1'b1 && Bit == 7 && DP_Mode == 1'b0 ) begin
	    			    //$display( $time, " Enter Deep Power Down Function ..." );
	    			    tDP_Chk = 1'b1;
                                    DP_Mode = 1'b1;
	    			end
	    			else if ( Bit > 7 )
	    			    STATE <= `BAD_CMD_STATE;
	    		    end	 
	    		    else if ( Bit == 7 )
	    			STATE <= `BAD_CMD_STATE;
	    		end
                      
                      
	            RDP, RES: 
	    		begin
	    		    if ( !WIP && Chip_EN ) begin
	    			// $display( $time, " Enter Release from Deep Power Down Function ..." );
	    			if ( Bit == 7 ) begin
	    			    RES_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			    if ( DP_Mode == 1'b1 ) begin
	    			       tRES1_Chk = 1'b1;
                                       DP_Mode = 1'b0;
                                    end  
	    			end
	    			if ( Bit == 38 && tRES1_Chk == 1'b1) begin
                                    tRES1_Chk = 1'b0;
                                    tRES2_Chk = 1'b1;
	    			end
	    		    end 
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;			    
	    		end

	            REMS:
	    		begin
	    		    if ( !DP_Mode && !WIP && Chip_EN ) begin
	    			if ( Bit == 31 ) begin
	    			    Address = SI_Reg[A_MSB:0] ;
	    			end
	    			//$display( $time, " Enter Read Electronic Manufacturer & ID Function ..." );
	    			if ( Bit == 7 ) begin
	    			    REMS_Mode = 1'b1;
	    			    Read_SHSL = 1'b1;
	    			end
	    		    end
	    		    else if ( Bit == 7 )
	                     	STATE <= `BAD_CMD_STATE;			    
	    		end

	            default: 
	    		begin
	    		    STATE <= `BAD_CMD_STATE;
	    		end
		    endcase
	        end
                 
	    `BAD_CMD_STATE: 
	        begin
	        end
            
	    default: 
	        begin
	    	    STATE =  `STANDBY_STATE;
	        end
	endcase
    end 

    always @ (posedge CS) begin
	SO_OUT_EN    <= #tSHQZ 1'b0;
	SI_OUT_EN    <= #tSHQZ 1'b0;

	SIO0_Reg <= #tSHQZ 1'bx;
	SIO1_Reg <= #tSHQZ 1'bx;
        #1;
	Bit		= 1'b0;
	Bit_Tmp	        = 1'b0;
	SI_IN_EN	= 1'b0;

	RES_Mode	= 1'b0;
	REMS_Mode	= 1'b0;
	RDSR_Mode	= 1'b0;
	RDID_Mode	= 1'b0;
	Read_1XIO_Mode  = 1'b0;
	Read_1XIO_Chk   = 1'b0;
	Read_2XIO_Chk   = 1'b0;
	FastRD_1XIO_Mode  = 1'b0;
	FastRD_2XIO_Mode  = 1'b0;
        SFDP_Mode    = 1'b0;
	STATE <= `STANDBY_STATE;
        disable read_id;
        disable read_1xio;
        disable read_status;
        disable fastread_1xio;
        disable fastread_2xio;
        disable read_electronic_id;
        disable read_electronic_manufacturer_device_id;
	disable dummy_cycle;
    end 
    
    /*----------------------------------------------------------------------*/
    /*	ALL function trig action            				    */
    /*----------------------------------------------------------------------*/
    always @ ( negedge ISCLK ) begin
        if (Read_1XIO_Mode == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            Read_1XIO_Chk = 1'b1;
        end
        if (FastRD_2XIO_Mode == 1'b1 && CS == 1'b0 && Bit == 7 ) begin
            Read_2XIO_Chk = 1'b1;
        end
    end 

    always @ ( posedge Read_1XIO_Mode ) begin
	read_1xio;
    end 

    always @ ( posedge FastRD_1XIO_Mode ) begin
        fastread_1xio;
    end

    always @ ( posedge FastRD_2XIO_Mode ) begin
        fastread_2xio;
    end

    always @ ( posedge REMS_Mode ) begin
        read_electronic_manufacturer_device_id;
    end

    always @ ( posedge RES_Mode ) begin
        read_electronic_id;
    end
 
    always @ ( posedge RDID_Mode ) begin
	read_id;
    end 

    always @ ( posedge RDSR_Mode ) begin
	read_status;
    end 

    always @ ( WRSR_Event ) begin
	write_status;
    end

    always @ ( BE_Event ) begin
	block_erase;
    end

    always @ ( CE_Event ) begin
	chip_erase;
    end
    
    always @ ( PP_Event ) begin
        page_program( Address );
    end
   
    always @ ( SE_4K_Event ) begin
	sector_erase_4k;
    end

// *========================================================================================== 
// * Module Task Declaration
// *========================================================================================== 
    /*----------------------------------------------------------------------*/
    /*	Description: define a wait dummy cycle task			    */
    /*	INPUT							            */
    /*	    Cnum: cycle number						    */
    /*----------------------------------------------------------------------*/
    task dummy_cycle;
	input [31:0] Cnum;
	begin
	    repeat( Cnum ) begin
		@ ( posedge ISCLK );
	    end
	end
    endtask // dummy_cycle

    /*----------------------------------------------------------------------*/
    /*	Description: define a write enable task				    */
    /*----------------------------------------------------------------------*/
    task write_enable;
	begin
	    //$display( $time, " Old Status Register = %b", Status_Reg );
	    Status_Reg[1] = 1'b1; 
	    // $display( $time, " New Status Register = %b", Status_Reg );
	end
    endtask // write_enable
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a write disable task (WRDI)			    */
    /*----------------------------------------------------------------------*/
    task write_disable;
	begin
	    //$display( $time, " Old Status Register = %b", Status_Reg );
	    Status_Reg[1]  = 1'b0;
	    //$display( $time, " New Status Register = %b", Status_Reg );
	end
    endtask // write_disable
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a read id task (RDID)			    */
    /*----------------------------------------------------------------------*/
    task read_id;
	reg  [23:0] Dummy_ID;
	integer Dummy_Count;
	begin
	    Dummy_ID	= {ID_MXIC, Memory_Type, Memory_Density};
	    Dummy_Count = 0;
	    forever begin
		@ ( negedge ISCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable read_id;
		end
		else begin
		    SO_OUT_EN = 1'b1;
                    {SIO1_Reg, Dummy_ID} <= #tCLQV {Dummy_ID, Dummy_ID[23]};
		end
	    end  // end forever
	end
    endtask // read_id
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a read status task (RDSR)			    */
    /*----------------------------------------------------------------------*/
    task read_status;
	integer Dummy_Count;
	begin
	    Dummy_Count = 8;
	    forever begin
		@ ( negedge ISCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable read_status;
		end
		else begin
		    SO_OUT_EN = 1'b1;
		    if ( Dummy_Count ) begin
			Dummy_Count = Dummy_Count - 1;
			SIO1_Reg    <= #tCLQV Status_Reg[Dummy_Count];
		    end
		    else begin
			Dummy_Count = 7;
			SIO1_Reg    <= #tCLQV Status_Reg[Dummy_Count];
		    end		 
		end
	    end  // end forever
	end
    endtask // read_status

    /*----------------------------------------------------------------------*/
    /*	Description: define a write status task				    */
    /*----------------------------------------------------------------------*/
    task write_status;
    integer tWRSR;
    reg [7:0] Status_Reg_Up;
	begin
	    //$display( $time, " Old Status Register = %b", Status_Reg );
	    Status_Reg_Up = SI_Reg[7:0] ;
	    tWRSR = tW;
	    //SRWD:Status Register Write Protect
            Status_Reg[0]   = 1'b1;
            #tWRSR;
	    Status_Reg[7]   = Status_Reg_Up[7];
	    Status_Reg[3:2] = Status_Reg_Up[3:2]; // bp bits update
	    //WIP : write in process Bit
	    Status_Reg[0]   = 1'b0;
	    //WEL:Write Enable Latch
	     Status_Reg[1]   = 1'b0;
	     WRSR_Mode       = 1'b0;
	end
    endtask // write_status
   
    /*----------------------------------------------------------------------*/
    /*	Description: define a read data task				    */
    /*		     03 AD1 AD2 AD3 X					    */
    /*----------------------------------------------------------------------*/
    task read_1xio;
	integer Dummy_Count, Tmp_Int;
	reg  [7:0]	 OUT_Buf;
	begin
	    Dummy_Count = 8;
            dummy_cycle(24);
            #1; 
            read_array(Address, OUT_Buf);
	    forever begin
		@ ( negedge ISCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable read_1xio;
		end 
		else  begin 
		    SO_OUT_EN	= 1'b1;
		    if ( Dummy_Count ) begin
		    	{SIO1_Reg, OUT_Buf} <= #tCLQV {OUT_Buf, OUT_Buf[7]};
			Dummy_Count = Dummy_Count - 1;
		    end
		    else begin
			Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
			{SIO1_Reg, OUT_Buf} <= #tCLQV  {OUT_Buf, OUT_Buf[7]};
			Dummy_Count = 7 ;
		    end
		end 
	    end  // end forever
	end   
    endtask // read_1xio

    /*----------------------------------------------------------------------*/
    /*	Description: define a fast read data task			    */
    /*		     0B AD1 AD2 AD3 X					    */
    /*----------------------------------------------------------------------*/
    task fastread_1xio;
	integer Dummy_Count, Tmp_Int;
	reg  [7:0]	 OUT_Buf;
	begin
	    Dummy_Count = 8;
	    dummy_cycle(32);
            read_array(Address, OUT_Buf);
	    forever begin
		@ ( negedge ISCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable fastread_1xio;
		end 
		else begin 
		    SO_OUT_EN = 1'b1;
		    if ( Dummy_Count ) begin
			{SIO1_Reg, OUT_Buf} <= #tCLQV {OUT_Buf, OUT_Buf[7]};
			Dummy_Count = Dummy_Count - 1;
		    end
		    else begin
			Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
			{SIO1_Reg, OUT_Buf} <= #tCLQV {OUT_Buf, OUT_Buf[7]};
			Dummy_Count = 7 ;
		    end
		end    
	    end  // end forever
	end   
    endtask // fastread_1xio

    /*----------------------------------------------------------------------*/
    /*	Description: define a fast read dual output data task		    */
    /*		     3B AD1 AD2 AD3 X					    */
    /*----------------------------------------------------------------------*/
    task fastread_2xio;
	integer Dummy_Count;
	reg  [7:0] OUT_Buf;
	begin
	    Dummy_Count = 4 ;
	    dummy_cycle(32);
            read_array(Address, OUT_Buf);
	    forever @ ( negedge ISCLK or  posedge CS ) begin
	        if ( CS == 1'b1 ) begin
		    disable fastread_2xio;
	        end
	        else begin
		    SO_OUT_EN = 1'b1;
		    SI_OUT_EN = 1'b1;
		    SI_IN_EN  = 1'b0;
		    if ( Dummy_Count ) begin
			{SIO1_Reg, SIO0_Reg, OUT_Buf} <= #tCLQV {OUT_Buf, OUT_Buf[1:0]};
	    	 	Dummy_Count = Dummy_Count - 1;
		    end
		    else begin
			Address = Address + 1;
                        load_address(Address);
                        read_array(Address, OUT_Buf);
			{SIO1_Reg, SIO0_Reg, OUT_Buf} <= #tCLQV {OUT_Buf, OUT_Buf[1:0]};
			Dummy_Count = 3 ;
		    end
	        end
	    end//forever  
	end
    endtask // fastread_2xio

    /*----------------------------------------------------------------------*/
    /*	Description: define a block erase task				    */
    /*		     D8 AD1 AD2 AD3					    */
    /*----------------------------------------------------------------------*/
    task block_erase;
	reg [Block_MSB:0] Block; 
	integer i;
	begin
	    Block	=  Address[A_MSB:16];
	    Start_Add	= (Address[A_MSB:16]<<16) + 16'h0;
	    End_Add	= (Address[A_MSB:16]<<16) + 16'hffff;
	    //WIP : write in process Bit
	    Status_Reg[0] =  1'b1;
	    #tBE ;
	    for( i = Start_Add; i <= End_Add; i = i + 1 )
	    begin
	        ARRAY[i] = 8'hff;
	    end
	    //WIP : write in process Bit
	    Status_Reg[0] =  1'b0;//WIP
	    //WEL : write enable latch
	    Status_Reg[1] =  1'b0;//WEL
	    BE_Mode = 1'b0;
	end
    endtask // block_erase

    /*----------------------------------------------------------------------*/
    /*	Description: define a sector 4k erase task			    */
    /*		     20 AD1 AD2 AD3					    */
    /*----------------------------------------------------------------------*/
    task sector_erase_4k;
	integer i;
	begin
	    Sector	=  Address[A_MSB:12]; 
	    Start_Add	= (Address[A_MSB:12]<<12) + 12'h000;
	    End_Add	= (Address[A_MSB:12]<<12) + 12'hfff;	      
	    //WIP : write in process Bit
	    Status_Reg[0] =  1'b1;
	    #tSE;
	    for( i = Start_Add; i <= End_Add; i = i + 1 )
	    begin
	        ARRAY[i] = 8'hff;
	    end
	    //WIP : write in process Bit
	    Status_Reg[0] = 1'b0;//WIP
	    //WEL : write enable latch
	    Status_Reg[1] = 1'b0;//WEL
	    SE_4K_Mode = 1'b0;
	 end
    endtask // sector_erase_4k
    
    /*----------------------------------------------------------------------*/
    /*	Description: define a chip erase task				    */
    /*		     60(C7)						    */
    /*----------------------------------------------------------------------*/
    task chip_erase;
	integer i;
        begin
            Status_Reg[0] =  1'b1;
               #tCE;
            for( i = 0; i <Block_NUM; i = i+1 )
            begin
		Start_Add = (i<<16) + 16'h0;
		End_Add   = (i<<16) + 16'hffff;	
		for( j = Start_Add; j <=End_Add; j = j + 1 )
		begin
		    ARRAY[j] =  8'hff;
		end
            end
            //WIP : write in process Bit
            Status_Reg[0] = 1'b0;//WIP
            //WEL : write enable latch
            Status_Reg[1] = 1'b0;//WEL
	    CE_Mode = 1'b0;
        end
    endtask // chip_erase	

    /*----------------------------------------------------------------------*/
    /*	Description: define a page program task				    */
    /*		     02 AD1 AD2 AD3					    */
    /*----------------------------------------------------------------------*/
    task page_program;
	input  [A_MSB:0]  Address;
	reg    [7:0]	  Offset;
	integer Dummy_Count, Tmp_Int, i;
	begin
	    Dummy_Count = Page_Size;    // page size
	    Tmp_Int = 0;
            Offset  = Address[7:0];
	    /*------------------------------------------------*/
	    /*	Store 256 bytes into a temp buffer - Dummy_A  */
	    /*------------------------------------------------*/
            for (i = 0; i < Dummy_Count ; i = i + 1 ) begin
		Dummy_A[i]  = 8'hff;
            end
	    forever begin
		@ ( posedge ISCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    if ( (Tmp_Int % 8 !== 0) || (Tmp_Int == 1'b0) ) begin
			PP_1XIO_Mode = 0;
			disable page_program;
		    end
		    else begin
		        if ( Tmp_Int > 8 )
			    Byte_PGM_Mode = 1'b0;
                        else 
			    Byte_PGM_Mode = 1'b1;
			update_array ( Address );
		    end
		    disable page_program;
		end
		else begin  // count how many Bits been shifted
		    Tmp_Int = Tmp_Int + 1;
		    if ( Tmp_Int % 8 == 0) begin
                        #1;
		        Dummy_A[Offset] = SI_Reg [7:0];
		        Offset = Offset + 1;   
                        Offset = Offset[7:0];   
                    end  
		end
	    end  // end forever
	end
    endtask // page_program

    /*----------------------------------------------------------------------*/
    /*	Description: define a read electronic ID (RES)			    */
    /*		     AB X X X						    */
    /*----------------------------------------------------------------------*/
    task read_electronic_id;
	reg  [7:0] Dummy_ID;
	begin
            dummy_cycle(24);
	    Dummy_ID = ID_Device;
	    forever begin
		@ ( negedge ISCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable read_electronic_id;
		end 
		else begin  
		    SO_OUT_EN = 1'b1;
		    {SIO1_Reg, Dummy_ID} <= #tCLQV  {Dummy_ID, Dummy_ID[7]};
		end
	    end // end forever	 
	end
    endtask // read_electronic_id
	    
    /*----------------------------------------------------------------------*/
    /*	Description: define a read electronic manufacturer & device ID	    */
    /*----------------------------------------------------------------------*/
    task read_electronic_manufacturer_device_id;
	reg  [15:0] Dummy_ID;
	integer Dummy_Count;
	begin
	    dummy_cycle(24);
	    #1;
	    if ( Address[0] == 1'b0 ) begin
		Dummy_ID = {ID_MXIC,ID_Device};
	    end
	    else begin
		Dummy_ID = {ID_Device,ID_MXIC};
	    end
	    Dummy_Count = 0;
	    forever begin
		@ ( negedge ISCLK or posedge CS );
		if ( CS == 1'b1 ) begin
		    disable read_electronic_manufacturer_device_id;
		end
		else begin
		    SO_OUT_EN =  1'b1;
		    {SIO1_Reg, Dummy_ID} <= #tCLQV  {Dummy_ID, Dummy_ID[15]};
		end
	    end	// end forever
	end
    endtask // read_electronic_manufacturer_device_id

    /*----------------------------------------------------------------------*/
    /*	Description: define a program chip task				    */
    /*	INPUT:address                            			    */
    /*----------------------------------------------------------------------*/
    task update_array;
	input [A_MSB:0] Address;
	integer Dummy_Count, i;
        integer program_time;
	begin
	    Dummy_Count = Page_Size;
            Address = { Address [A_MSB:8], 8'h0 };
            program_time = (Byte_PGM_Mode) ? tBP : tPP;
	    Status_Reg[0]= 1'b1;
	    #program_time ;
	    for ( i = 0; i < Dummy_Count; i = i + 1 ) begin
		ARRAY[Address+ i] = ARRAY[Address + i] & Dummy_A[i];
	    end
	    Status_Reg[0] = 1'b0;
	    Status_Reg[1] = 1'b0;
	    PP_1XIO_Mode = 1'b0;
            Byte_PGM_Mode = 1'b0;
	end
    endtask // update_array

    /*----------------------------------------------------------------------*/
    /*  Description: define read array output task                          */
    /*----------------------------------------------------------------------*/
    task read_array;
        input [A_MSB:0] Address;
        output [7:0]    OUT_Buf;
        begin
          if ( SFDP_Mode == 1 ) begin
                OUT_Buf = SFDP_ARRAY[Address];
          end
          else begin
                OUT_Buf = ARRAY[Address] ;
          end
        end
    endtask //  read_array

    /*----------------------------------------------------------------------*/
    /*  Description: define read array output task                          */
    /*----------------------------------------------------------------------*/
    task load_address;
        inout [A_MSB:0] Address;
        begin
          if ( SFDP_Mode == 1 ) begin
                Address = Address[A_MSB_SFDP:0] ;
          end
        end
    endtask //  load_address

    /*----------------------------------------------------------------------*/
    /*	Description: define a write_protect area function		    */
    /*	INPUT: address							    */
    /*----------------------------------------------------------------------*/ 
    function write_protect;
        input [A_MSB:0] Address;
        begin
            Block  =  Address [A_MSB:16];
            //protect_define
            if (Status_Reg[3:2] == 2'b00) begin
                write_protect = 1'b0;
            end
            else if (Status_Reg[3:2] == 2'b01) begin
                if (Block[Block_MSB:0] == 1) begin
                        write_protect = 1'b1;
                end
                else begin
                        write_protect = 1'b0;
                end
            end
            else
                write_protect = 1'b1;
        end
    endfunction // write_protect


// *============================================================================================== 
// * AC Timing Check Section
// *==============================================================================================
    wire WP_EN;
    wire tSCLK_Chk;
    assign tSCLK_Chk = (~(Read_1XIO_Chk )) && (CS==1'b0);
    assign WP_EN = (!Status_Reg[6]) && SRWD;
    assign  Write_SHSL = !Read_SHSL;

    wire Read_1XIO_Chk_W;
    assign Read_1XIO_Chk_W = Read_1XIO_Chk;
    wire Read_2XIO_Chk_W;
    assign Read_2XIO_Chk_W = Read_2XIO_Chk;
    wire Read_SHSL_W;
    assign Read_SHSL_W = Read_SHSL;
    wire tDP_Chk_W;
    assign tDP_Chk_W = tDP_Chk;
    wire tRES1_Chk_W;
    assign tRES1_Chk_W = tRES1_Chk;
    wire tRES2_Chk_W;
    assign tRES2_Chk_W = tRES2_Chk;
    wire SI_IN_EN_W;
    assign SI_IN_EN_W = SI_IN_EN;

    specify
    	/*----------------------------------------------------------------------*/
    	/*  Timing Check                                                        */
    	/*----------------------------------------------------------------------*/
	$period( posedge  SCLK &&& tSCLK_Chk, tSCLK  );	// SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_1XIO_Chk_W , tRSCLK ); // SCLK _/~ ->_/~
	$period( posedge  SCLK &&& Read_2XIO_Chk_W , tTSCLK ); // SCLK _/~ ->_/~

	$width ( posedge  SCLK &&& ~CS, tCH   );	// SCLK _/~~\_
	$width ( negedge  SCLK &&& ~CS, tCL   );	// SCLK ~\__/~
        $width ( posedge  SCLK &&& Read_1XIO_Chk_W, tCH_R   );       // SCLK _/~~\_
        $width ( negedge  SCLK &&& Read_1XIO_Chk_W, tCL_R   );       // SCLK ~\__/~

	$width ( posedge  CS  &&& Read_SHSL_W, tSHSL_R );	// CS _/~\_
	$width ( posedge  CS  &&& Write_SHSL, tSHSL_W );// CS _/~\_

	$width ( posedge  CS  &&& tDP_Chk_W, tDP );	// CS _/~\_
	$width ( posedge  CS  &&& tRES1_Chk_W, tRES1 );	// CS _/~\_
	$width ( posedge  CS  &&& tRES2_Chk_W, tRES2 );	// CS _/~\_

	$setup ( SI &&& ~CS, posedge SCLK &&& SI_IN_EN_W,  tDVCH );
	$hold  ( posedge SCLK &&& SI_IN_EN_W, SI &&& ~CS,  tCHDX );

	$setup    ( negedge CS, posedge SCLK &&& ~CS, tSLCH );
	$hold     ( posedge SCLK &&& ~CS, posedge CS, tCHSH );
     
	$setup    ( posedge CS, posedge SCLK &&& CS, tSHCH );
	$hold     ( posedge SCLK &&& CS, negedge CS, tCHSL );

        $setup ( negedge HOLD , posedge SCLK &&& ~CS,  tHLCH );
        $hold  ( posedge SCLK &&& ~CS, posedge HOLD ,  tCHHH );

        $setup ( posedge HOLD , posedge SCLK &&& ~CS,  tHHCH );
        $hold  ( posedge SCLK &&& ~CS, negedge HOLD ,  tCHHL );


	$setup ( posedge WP &&& WP_EN, negedge CS,  tWHSL );
	$hold  ( posedge CS, negedge WP &&& WP_EN,  tSHWL );

     endspecify

    integer AC_Check_File;
    // timing check module 
    initial 
    begin 
    	AC_Check_File= $fopen ("ac_check.err" );    
    end

    time  T_CS_P , T_CS_N;
    time  T_WP_P , T_WP_N;
    time  T_SCLK_P , T_SCLK_N;
    time  T_SI;
    time  T_WP;
    time  T_HOLD_P , T_HOLD_N;
    time  T_HOLD;

    initial 
    begin
	T_CS_P = 0; 
	T_CS_N = 0;
	T_WP_P = 0;  
	T_WP_N = 0;
	T_SCLK_P = 0;  
	T_SCLK_N = 0;
	T_SI = 0;
	T_WP = 0;
        T_HOLD_P = 0;
        T_HOLD_N = 0;
        T_HOLD = 0;
    end

    always @ ( posedge SCLK ) begin
        //tSCLK
        if ( $time - T_SCLK_P < tSCLK && $time > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for except READ struction fSCLK =%d Mhz, fSCLK timing violation at %d \n", fSCLK, $time );

        //fRSCLK
        if ( $time - T_SCLK_P < tRSCLK && Read_1XIO_Chk && $time > 0 && ~CS )
            $fwrite (AC_Check_File, "Clock Frequence for READ instruction fRSCLK =%d Mhz, fRSCLK timing violation at %d \n", fRSCLK, $time );

        T_SCLK_P = $time;
        #0;
        //tDVCH
        if ( T_SCLK_P - T_SI < tDVCH && SI_IN_EN && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum Data SI setup time tDVCH=%d ns, tDVCH timing violation at %d \n", tDVCH, $time );

        //tCL
        if ( T_SCLK_P - T_SCLK_N < tCL && ~CS && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum SCLK Low time tCL=%f ns, tCL timing violation at %d \n", tCL, $time );
        //tCL_R
        if ( T_SCLK_P - T_SCLK_N < tCL_R && Read_1XIO_Chk && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum SCLK Low time for read tCL=%f ns, tCL timing violation at %d \n", tCL_R, $time );
        // tSLCH
        if ( T_SCLK_P - T_CS_N < tSLCH  && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# active setup time tSLCH=%d ns, tSLCH timing violation at %d \n", tSLCH, $time );

        // tSHCH
        if ( T_SCLK_P - T_CS_P < tSHCH  && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum CS# not active setup time tSHCH=%d ns, tSHCH timing violation at %d \n", tSHCH, $time );

        //tHLCH
        if ( T_SCLK_P - T_HOLD_N < tHLCH && ~CS  && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum HOLD# setup time tHLCH=%d ns, tHLCH timing violation at %d \n", tHLCH, $time );

        //tHHCH
        if ( T_SCLK_P - T_HOLD_P < tHHCH && ~CS  && T_SCLK_P > 0 )
            $fwrite (AC_Check_File, "minimum HOLD setup time tHHCH=%d ns, tHHCH timing violation at %d \n", tHHCH, $time );
    end

    always @ ( negedge SCLK ) begin
        T_SCLK_N = $time;
        #0;
        //tCH
        if ( T_SCLK_N - T_SCLK_P < tCH && ~CS && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum SCLK High time tCH=%f ns, tCH timing violation at %d \n", tCH, $time );
        //tCH_R
        if ( T_SCLK_N - T_SCLK_P < tCH_R && Read_1XIO_Chk && T_SCLK_N > 0 )
            $fwrite (AC_Check_File, "minimum SCLK High time for read tCH=%f ns, tCH timing violation at %d \n", tCH_R, $time );
    end
 
    always @ ( SI ) begin
        T_SI = $time;
        #0;
        //tCHDX
        if ( T_SI - T_SCLK_P < tCHDX && SI_IN_EN && T_SI > 0 )
            $fwrite (AC_Check_File, "minimum Data SI hold time tCHDX=%d ns, tCHDX timing violation at %d \n", tCHDX, $time );
    end

    always @ ( posedge CS ) begin
        T_CS_P = $time;
        #0;  
	// tCHSH 
        if ( T_CS_P - T_SCLK_P < tCHSH  && T_CS_P > 0 )
	    $fwrite (AC_Check_File, "minimum CS# active hold time tCHSH=%d ns, tCHSH timing violation at %d \n", tCHSH, $time );
    end

    always @ ( negedge CS ) begin
        T_CS_N = $time;
        #0;
	//tCHSL
        if ( T_CS_N - T_SCLK_P < tCHSL  && T_CS_N > 0 )
	    $fwrite (AC_Check_File, "minimum CS# not active hold time tCHSL=%d ns, tCHSL timing violation at %d \n", tCHSL, $time );
	//tSHSL
        if ( T_CS_N - T_CS_P < tSHSL_R && T_CS_N > 0 && Read_SHSL)
            $fwrite (AC_Check_File, "minimum CS# deselect  time tSHSL_R=%d ns, tSHSL timing violation at %d \n", tSHSL_R, $time );
        if ( T_CS_N - T_CS_P < tSHSL_W && T_CS_N > 0 && Write_SHSL)
            $fwrite (AC_Check_File, "minimum CS# deselect  time tSHSL_W=%d ns, tSHSL timing violation at %d \n", tSHSL_W, $time );

	//tDP
        if ( T_CS_N - T_CS_P < tDP && T_CS_N > 0 && tDP_Chk)
            $fwrite (AC_Check_File, "when transit from Standby Mode to Deep-Power Mode, CS# must remain high for at least tDP =%d ns, tDP timing violation at %d \n", tDP, $time );

	//tRES1/2
        if ( T_CS_N - T_CS_P < tRES1 && T_CS_N > 0 && tRES1_Chk)
            $fwrite (AC_Check_File, "when transit from Deep-Power Mode to Standby Mode, CS# must remain high for at least tRES1 =%d ns, tRES1 timing violation at %d \n", tRES1, $time );
        if ( T_CS_N - T_CS_P < tRES2 && T_CS_N > 0 && tRES2_Chk)
            $fwrite (AC_Check_File, "when transit from Deep-Power Mode to Standby Mode, CS# must remain high for at least tRES2 =%d ns, tRES2 timing violation at %d \n", tRES2, $time );


	//tWHSL
        if ( T_CS_N - T_WP_P < tWHSL && WP_EN  && T_CS_N > 0 )
	    $fwrite (AC_Check_File, "minimum WP setup  time tWHSL=%d ns, tWHSL timing violation at %d \n", tWHSL, $time );
    end

    always @ ( posedge WP ) begin
        T_WP_P = $time;
        #0;  
    end

    always @ ( negedge WP ) begin
        T_WP_N = $time;
        #0;
	//tSHWL
        if ( ((T_WP_N - T_CS_P < tSHWL) || ~CS) && WP_EN && T_WP_N > 0 )
	    $fwrite (AC_Check_File, "minimum WP hold time tSHWL=%d ns, tSHWL timing violation at %d \n", tSHWL, $time );
    end

    always @ ( posedge HOLD ) begin
        T_HOLD_P = $time;
        #0;
        //tCHHH
        if ( T_HOLD_P - T_SCLK_P < tCHHH && ~CS  && T_HOLD_P > 0 )
            $fwrite (AC_Check_File, "minimum HOLD# hold time tCHHH=%d ns, tCHHH timing violation at %d \n", tCHHH, $time );

    end

    always @ ( negedge HOLD ) begin
        T_HOLD_N = $time;
        #0;
        //tCHHL
        if ( T_HOLD_N - T_SCLK_P < tCHHL && ~CS  && T_HOLD_N > 0 )
            $fwrite (AC_Check_File, "minimum HOLD hold time tCHHL=%d ns, tCHHL timing violation at %d \n", tCHHL, $time );

    end
endmodule
