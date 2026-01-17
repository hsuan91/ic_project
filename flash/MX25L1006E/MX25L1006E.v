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
    parameter   Init_File	= "none"; // initial flash data
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
		tVSL	= 200_000;	// Time delay to chip select allowed

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
	    ARRAY[i] = 8'hff; 
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
	    		    if ( !DP_Mode && !WIP && Chip_EN ) begin
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
