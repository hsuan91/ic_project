//--------------------------------------------------------------------------
//
// Project : Serial Flash Device
//--------------------------------------------------------------------------
// Module  : AT25DF512C.v
//--------------------------------------------------------------------------
//
// Revision History: dwang
// 1.0	: 09/29/2014 initial model for AT25DF512C
//--------------------------------------------------------------------------
// Based on AT25DF512B, changes list:
//	1. Status Reg and Read 1-byte --> 2-byte	
//	2. Write Status Register Byte 2 31h
//	3. Memory Size have 3 options : 256K/512K/1M
//	4. Dual Read 3Bh
//	5. Page Erase 81h
//	6. Reset F0h
//	7. Ultra Deep Power-Down 79h
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------

`timescale 1ns / 10ps

//`define VERBOSE_TASK_ON

module AT25DF512C (
		CSB,
		SCK,
		SI,
		WPB,
          SO,
          HOLDB,
          VCC,
          GND
		);

// ******************************************************************** //
//			Port Declaration:
// ******************************************************************** //

input 	CSB;	// Chip Select!
input	SCK;	// Serial Clock
inout  	SI ; // Bidirectional Signal	20140904   
inout	SO ;	// Bidirectional Signal
input	HOLDB;	 
input	VCC;
input 	GND;
input	WPB;	// Write Protect!

/**********************************************************************
Memory & Registers PreLoading Parameters:
=============================
These parameters are related to Memory and Registers Preloading.
Memory, Block Protection and Security Register can be preloaded, in Hex format.

To pre-load Memory (in Hex format), define parameter
MEMORY_FILE = <filename>, where <filename> is the name of
the pre-load file.
If MEMORY_FILE = "", the Memory is initialized to Erased state (all data = FF).
If the memory is initialized, the status of all pages will be Not-Erased.

To pre-load Block Protection (in Hex format), define
parameter BLOCK_PROT_LOCK = <filename>, where <filename> is the name of
the pre-load file.
If BLOCK_PROT_LOCK = "", the Block Protection Locked is initialized to Erased State
(all data = ff) which is Protected 

To pre-load Block Protection (in Hex format), define
parameter BLOCK_PROT = <filename>, where <filename> is the name of
the pre-load file.
If BLOCK_PROT = "", the Block Protection is initialized to Erased State
(all data = ff) which is Protected 

To pre-load Security Register (only the User Programmable Bytes 0 to 63),
define parameter SECURITY = <filename>, where <filename> is the name
of the pre-load file.
If SECURITY = "", the register is initialized to erased state (all data = FF).

The Factory Programmed Bytes 64 to 127 are always initialized by defining
parameter FACTORY = "factory.txt". As the Factory Programmed Bytes are
accessible to the user for read, a sample of "factory.txt" file
needs to be included in the Verilog Model directory.

**********************************************************************/
parameter DEVICE = "AT25DF512C";
parameter PRELOAD = 1;							// Preload  
parameter MEMORY_FILE = "memory.txt";                       // Memory pre-load
parameter BLOCK_PROTECTION = "block_protection.txt";             // Protection State pre-load
parameter BLOCK_PROTECTION_LOCKED = "block_protection_locked.txt";    // Protection State pre-load
parameter SECURITY = "security.txt";                        // Security Register Bytes[0:63] pre-load
parameter FACTORY = "factory.txt";                     // Security Register Bytes[64:127]


// ********************************************************************* //
//Timing Parameters :
// ******************************************************************** //

// Fixed parameters
parameter fSCK    = 85;			// Serial clock (SCK) Frequency in MHz
parameter fRDDO   = 50;			// SCK Frequency for read Array (3Bh opcode)
parameter fRDLF   = 33;			// SCK Frequency for read Array (Low freq - 03h opcode)
//representation in ns
parameter tSCKH   = 4;			// Clock High Time
parameter tSCKL   = 4;			// Clock Low Time
parameter tCLKR   = 0.1;			// Clock Rise Time, Peak-to-Peak(Slew Rate)
parameter tCLKF   = 0.1;			// Clock Fall Time, Peak-to-Peak(Slew Rate)

parameter tDIS    = 8;			// Output Disable time 8(1.6-3.6V) 6(2.3-3.6V) 
parameter tV	   = 8;			// Output Valid time 8(1.6-3.6V) 6(2.3-3.6V) 
parameter tOH     = 0 ;			// Output Hold time

parameter tHLQZ   = 7 ;			// HOLD! Low to Output High-z
parameter tHHQX   = 7 ;			// HOLD! High to Output Low-z

parameter tWPS    = 20;			// RWrite Protect Setup Time
parameter tWPH    = 100;			// RWrite Protect Hold Time

parameter tEDPD   = 2000;		// Chip Select high to Deep Power-down (1 us)
parameter tEUDPD  = 3000;		// Chip Select high to Ultra Deep Power-down (1 us)
parameter tRDPD   = 8000;		// Chip Select high to Stand-by Mode from DPD
parameter tXUDPD  = 100000;		// Chip Select high to Stand-by Mode from UDPD 
parameter tSWRST  = 60000;		// Software Reset Time
parameter tCSLU   = 20;			// Min Chip Select Low to Exit Ultra Deep Power_Down
parameter tXUDOD  = 100;			// Exit Ultra Deep Power_Down Time


parameter tPP     = 1500000;		// Page Program Time
parameter tBP     = 12000;		// Byte Program Time
parameter tBLKE4  = 50000000;		// Block Erase Time 4-kB
parameter tBLKE32 = 400000000;	// Block Erase Time 32-kB
parameter tCHPE   = 800000000;	// Spec. time is 64s	
parameter tOTPP   = 400000;		// OTP Security Register Program Time 
parameter tWRSR   = 20000000;		// Write Status Register Time

parameter tVCSL   = 70000; 		// Minimum VCC to chip select Low time 
parameter tPUW    = 5000000;  	// Minimum VCC to chip select Low time 

// ********* Memory And Access Related Declarations ************ //
parameter MADDRESS =  16; 			
parameter time_12ns = 12;	// => tMAX -  85MHz
parameter time_20ns = 20;	// => tRDDO - 50MHz
parameter time_30ns = 30;	// => tRDLF - 33MHz
reg tMAX;
reg tRDDO;
reg tRDLF;  


//`define MEM_256K
`define MEM_512K
//`define MEM_1M

`ifdef MEM_256K
	parameter PAGES = 128; 					// total page number
	parameter PA_SIZE = 7; 					// page size 
	parameter [31:0] MAN_ID = 32'h1F_40_00_00 ;	//Manufacture ID
`endif
//`else
`ifdef MEM_512K
	parameter PAGES = 256; 					// total page number
	parameter PA_SIZE = 8; 					// page size 
	parameter [31:0] MAN_ID = 32'h1F_65_01_00 ;	//Manufacture ID
`endif
//`else
`ifdef MEM_1M
	parameter PAGES = 512; 					// total page number
	parameter PA_SIZE = 9; 					// page size 
	parameter [31:0] MAN_ID = 32'h1F_42_00_00 ;	//Manufacture ID
`endif

parameter BA_SIZE = 8;				//BA size
parameter BYTES = 256; 				// page size
parameter MEMSIZE =  PAGES * BYTES; 	// total memory size
reg [7:0] memory [MEMSIZE-1:0];		// memory of selected device
reg [7:0] factory_reg[63:0];			// factory programmed security register
reg [7:0] security_reg[63:0];			// security register
reg [7:0] OTP_reg [127:0];			// factory & security register 
reg [7:0] BP0_reg [0:0];				// Block Protection reg
reg [7:0] BPL_reg [0:0];				// Block Protection Locked reg
reg security_flag;
reg [15:0] status_reg;			// Status register
reg [7:0] int_buffer [255:0];	// internal buffer to store data in page programming mode
reg [7:0] OTP_buffer [63:0];	// internal buffer to store data in page programming mode
// ****************** ***************** ***************** //


// ********* Registers to track the current operation of the device ******** //
reg deep_power_down;	// Device in Deep Power Down Mode
reg zero_power_down;	// Device in Zero Power Down Mode
reg erasing_block4;		// 4kB block erase
reg erasing_block32;	// 32kB block erase
reg erasing_chip;		// chip erase
reg erasing_page;		// page erase
reg byte_prog;			// Byte/page programming
reg otp_sec_prog;		// otp security program 
reg overflow;
reg [5:0] sckcnt;		// SPI clock counter 
reg [7:0] con_byte;      // to store confirmation byte temporarily
reg cmd_1byte;			// 1byte 
reg cmd_2byte;			// 2byte 
reg cmd_4byte;			// 4byte 
reg cmd_5byte;			// 5byte 
reg abort;			// abort register
reg abort_boundary;
reg abort_holdb;
reg HOLD_EN;			// 
reg dummy_phase;
reg no_action;


// ********* Events to trigger some task based on opcode *********** //
event  EDPD;		// Deep Power-down (enable)
event  RDPD;		// Resume from Deep Power-down
event  ZPD;		// Zero Deep Power-down
event  RA;		// Read Array
event  DORA;		// Dual Read Array
event  PE;		// Page Erase
event  BE4;		// Block Erase 4KB
event  BE32;		// Block Erase 32KB
event  CE;		// Chip Erase
event  BP;		// byte /page program
event  WE;		// Write Enable
event  WD;		// Write Disable
event  RSR;		// Read Status Register
event  RST;		// Reset
event  WSR1;		// Write Status Register 1
event  WSR2;		// Write Status Register 2
event  MIR;		// Manufacturer ID Read
event  MIRL;		// Legacy Manufacturer ID Read
event  POSR;		// Program OTP Security Register
event  ROSR;		// Read Otp Register
/******** Other variables/registers ******************/
reg [7:0] read_data;		// register in which opcode/data is read-in
reg [23:0] temp_addr;		// to store mem address temporarily
reg [23:0] current_address;	// to store mem address
reg [7:0] buffer_address;	//
reg [7:0] temp_data;		// temp read data from memory
reg [7:0] data_in; 			// data in for byte programming
reg [7:0] read_dummy;		// register in which dont care data is stored
reg stat_reg_temp1;			// WSR1 temp value for protect/unprotect
reg stat_reg_temp2;			// WSR2 temp value for protect/unprotect
reg [7:0] pp_address;		// specifies the page address for BP/PP
reg [7:0] erase_start_page;	// specifies the page address for BP/PP
reg [11:0] erase_start_4;	// specifies the page address for BP/PP
reg [14:0] erase_start_32;	// specifies the page address for BP/PP
reg [5:0] OTP_address;		// specifies the page address for Program OTP (64 bytes only) 
reg [6:0] OTP_rd_address;	// specifies the page address for Read OTP Security Registers
reg SI_reg;		    	// Signal out reg
reg SI_on;			// Signal out enable signal
reg SO_reg;		    	// Signal out reg
reg SO_on;			// Signal out enable signal
reg BPL;				// Block Protection Locked
reg EPE;				// Erase/Program Error
reg WPP;				// Write Protection Pin Status
reg BP0;				// Block Protection Status
reg WEL;				// Write Enable Latch Status
reg RSTE;				// Reset Command Enable Status
reg RDYnBSY;			// Ready/Busy Status
reg BP0_val;
reg BPL_val;			// WSR1 temp value for BPL
reg mem_initialized;	//
reg foreground_op_enable, background_op_enable;
reg sdindual_en;		// dual input enable 	//20140904
integer j;		     // integers for accessing memory
integer pp;			// specifies no of bytes need to write in memory
integer pp_j;			// holds no of bytes received for OTP page program
integer pp_h;			// holds no of bytes received for page program
integer pp_i;			// holds no of bits received for each byte in page program
integer rd_dummy;		// counter for receiving 8 dummy bit from SO
integer delay;			// waits for Chip Erase to complete
integer h;
integer z;
integer i;
integer a;
integer e_loop;		// use to sampling suspend_request or reset_request during erase operation

reg [5:0]int_address;    // internal address for OTP
reg[23:0] erase_i;       
reg [11:0]erase4_i;
real clk_val;
real clk_val_d;
real clk_diff;
reg full_page; 
reg OE;
wire CLK;
reg vcc_reg;
wire power_en;
reg dout_phase;
reg reset_request;		// Reset request register
reg reset;			// Reset request register


// ****************** Initialize **************** //
initial
begin
    	// start with erased state
    	// Memory Initialization

	for (j=0; j<MEMSIZE; j=j+1)   		// Pre-initiazliation to Erased
  	begin                        		// state is useful if a user wants to
    		memory[j] = 8'hff;       	// initialize just a few locations => user's
  	end
  	mem_initialized = 1'b0;

   	// Now preload, if needed
	if (PRELOAD == 1'b1)
  	begin
     	$readmemh(MEMORY_FILE, memory);
     	mem_initialized = 1;
     	$readmemh(BLOCK_PROTECTION, BP0_reg);
		$readmemh(SECURITY, security_reg);
         	security_flag = 1'b1;
  	end


 	// Initialize Block Protection state and security registers
	BP0_reg[0] = 8'hff;		//mem-protected
	BPL_reg[0] = 8'h00;		//protection un-locked

  	for (j=0; j<64; j=j+1)

  		security_reg[j] = 8'hFF;

  	security_flag = 1'b0;
  	$readmemh(FACTORY, factory_reg);


	// Initialize Block Locked Protection state
	BPL = &BPL_reg[0];

	// Initialize Block Protection state
	BP0 = &BP0_reg[0];
  	
	// Now initialize all registers 
	EPE	 = 1'b0;
	RSTE	 = 1'b0;
	WPP	 = 1'b0;
	WEL	 = 1'b0;

//Byte 1
	status_reg[15]	= BPL;
	status_reg[14]	= 1'b0;	// reserved
	status_reg[13]	= EPE; 	// reserved
	status_reg[12]	= WPP;
	status_reg[11]	= 1'b0;	// reserved
	status_reg[10]	= BP0;
	status_reg[9] 	= WEL;
	status_reg[8] 	= RDYnBSY;
//Byte 2
	status_reg[7]	= 1'b0;	// reserved
	status_reg[6]	= 1'b0;	// reserved
	status_reg[5]	= 1'b0;	// reserved
	status_reg[4]	= RSTE;
	status_reg[3]	= 1'b0;	// reserved
	status_reg[2]	= 1'b0;	// reserved
	status_reg[1] 	= 1'b0;	// reserved
	status_reg[0] 	= RDYnBSY; 

	// There is no activity at this time, chip is in stand-by mode

	deep_power_down	= 1'b0;
	zero_power_down	= 1'b0;
	erasing_block4	= 1'b0;
	erasing_block32 = 1'b0;
	erasing_chip	= 1'b0;
	byte_prog	= 1'b0;
	otp_sec_prog = 1'b0;
	h = 0;
	erase_i = 23'h00000;
	con_byte = 8'h00;
	full_page = 1'b0;
	abort = 1'b0;
	abort_boundary = 1'b0;
	abort_holdb = 1'b0;
	dout_phase = 1'b0;
	dummy_phase = 1'b0;
	no_action = 1'b0;
	sdindual_en = 1'b0;
 
	// Stand-by mode initialization
	current_address  	= 24'b0;
	data_in		  	= 8'b0;
	BPL_val	 		= 1'b0;
	BP0_val	 		= 1'b0;
	rd_dummy		= 0;
	RDYnBSY		 	= 1'b0;

  	// All o/ps are High-impedance
  	SO_on = 1'b0;

  	// Power-up Timing Restrictions
  	foreground_op_enable = 1'b0;
  	background_op_enable = 1'b0;
  	#tVCSL;
  	foreground_op_enable = 1'b1; // Enable foreground op_codes
  	#tPUW;
  	background_op_enable = 1'b1; // Enable background op_codes

end // end of initial

// ********************** Drive SO ********************* //
//bufif1 (SO, SO_reg, SO_on); //SO will be driven only if SO_on is High

assign SI      = SI_on        ? SI_reg       : 1'bz;                  // IO<0>
assign SO      = SO_on        ? SO_reg       : 1'bz;                  // IO<1>


//Power up initialization
always@(VCC)
begin
     # 1 vcc_reg = VCC;
end
assign power_en = (VCC==1'b1 && vcc_reg==1'b0) ? 1'b1 : (VCC==1'b0) ? 1'b0 : power_en;

always @ (power_en or VCC)
begin
     if (VCC==1'b0)
     begin
          foreground_op_enable = 1'b0;
          background_op_enable = 1'b0;
     end
     else if (VCC==1'b1)
     begin
          #tVCSL foreground_op_enable = power_en;
          #tPUW  background_op_enable = power_en;
     end
     else
          $monitor("VCC deasserted before tVCSL period ", VCC);
end

// ********************* Status register ********************* //
always @(WPB)			// Write Protect (WP!) Pin Status
begin
	WPP = WPB;
end

always @(BPL or EPE or WPP or BP0 or WEL or RDYnBSY or RSTE)
begin
	status_reg = {BPL, 1'b0, EPE, WPP, 1'b0, BP0, WEL, RDYnBSY, 3'h0, RSTE, 3'h0, RDYnBSY};
end
// ******* to receive opcode and to switch to respective blocks ******* //
always @(negedge CSB)  // the device will now become active
begin : get_opcode

//	get_data;  // get opcode here

     if (zero_power_down == 1'b1)  // resume from zero power down mode
     begin
          `ifdef VERBOSE_TASK_ON
               $display ("Device is resume from Zero Power mode");
          `endif
		#tXUDPD;
		#tVCSL;
          foreground_op_enable = 1'b1;
          background_op_enable = 1'b1;
          zero_power_down = 1'b0;
          disable get_opcode;
     end
	else if (foreground_op_enable == 1'b0)					// No foreground or background opcode accepted
	begin
		`ifdef VERBOSE_TASK_ON
			$display("No opcode is allowed: %d delay is required before device can be selected", tVCSL);
		`endif
	end
	else if (deep_power_down == 1'b1) 					// Can be only after background has been enabled
	begin
	get_data;  // get opcode here
		case (read_data)
			8'hAB:	-> RDPD;					// Resume from Deep Power-down
			default :	$display("Opcode %h is not allowed: device in Deep Power-down", read_data);
		endcase
	end
   	else 
	begin
	get_data;  // get opcode here
		case (read_data)							// based on opcode, trigger an action
			8'h0B :	begin						// Read Array
						rd_dummy = 1;
						-> RA;
					end
			8'h03 :	begin						// Read Array (low freq)
						rd_dummy = 0;
						-> RA;
					end
			8'h3B :	begin						// Dual Read Array		//20140903
						rd_dummy = 1;
						-> DORA;
					end
	          8'h81 :   if (background_op_enable == 1'b0)
     	                    $display ("Write operations are not allowed before %d delay", tPUW);
          	          else
               	          -> PE ;   				// Page Erase			//20140905
         		8'h20 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> BE4;					// Block erase 4KB
         		8'h52 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> BE32;					// Block erase 32KB
         		8'hD8 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> BE32;					// Block erase 32KB
         		8'h60 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> CE;					// Chip erase
         		8'hC7 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> CE;					// Chip erase
         		8'h62 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> CE;					// Chip erase
         		8'h02 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);
					else
						-> BP;					// Byte Program
         		8'h06 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW); 
					else
						-> WE;					// Write Enable
         		8'h04 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> WD;					// Write Disable
         		8'h01 :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> WSR1;					// Write Status Register Byte1 
         		8'h31 :	if (background_op_enable == 1'b0)							
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> WSR2;					// Write Status Register Byte2 	20140905
			8'h79 :   if (background_op_enable == 1'b0)
					$display ("Write operations are not allowed before %d delay", tPUW);
					else
						-> ZPD ; // Zero Power-down

			8'h9F :	-> MIR;						// Read Manufacturer and Device ID (4byte)
			8'h15 :	-> MIRL;						// Legacy Read Manufacturer and Device ID (4byte)
			8'h05 :	-> RSR;						// Read Status Register
			8'hF0:    -> RST;                            // Reset	20140905
        		8'hB9 :	if (background_op_enable == 1'b0)
					$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> EDPD;					// Enter Deep Power-down 
        		8'h9B :	if (background_op_enable == 1'b0)
						$display("Write operations are not allowed before %d delay", tPUW);	
					else
						-> POSR;					// Program OTP Security Register 
         		8'h77 :	begin						
                   			rd_dummy = 2;
              				-> ROSR;					// Read OTP Security register
              			end
			default :	$display("Unrecognized opcode  %h", read_data);
		endcase
	end
end

// *********************** TASKS / FUNCTIONS ************************** //
// get_data is a task to get 4 bits of data. This data could be an address,
// data or anything. It just obtains 4 bits of data obtained on SI
task get_data;

integer i;
begin
	for (i=7; i>=0; i = i-1)
	begin
		@(posedge CLK);  
		read_data[i] = SI;
	end
end
endtask

// task read_out_array is to read from main Memory
task read_out_array;
input [23:0] read_addr;
integer i;

begin
     begin
		temp_data = memory [read_addr];
     		i = 7;
		while (CSB == 1'b0) // continue transmitting, while, CSB is Low
		begin
			@(negedge CLK);
			dout_phase = 1'b1;
			SO_reg = 1'bx;
			#tV;
			SO_reg = temp_data[i];
			if (i == 0) 
			begin
				`ifdef VERBOSE_TASK_ON
					$display("Read Data: %h read from memory location %h",temp_data,read_addr);
				`endif
				read_addr = read_addr + 1; // next byte
         			i = 7;
				if (read_addr >= MEMSIZE)
				read_addr = 0; // Note that rollover occurs at end of memory,
					temp_data = memory [read_addr];
			end
			else
				i = i-1;	// next bit
	 	end
	end     // reading over, because CSB has gone high

end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// receive data for byte/page programming
task buffer_write;
input [7:0]in_j;
reg [8:0] count;
begin
	count = 0;
	while (CSB==1'b0)
	begin
		for (pp_i=7; pp_i>=0; pp_i = pp_i-1)
		begin
			@(posedge CLK);  
			read_data[pp_i] = SI;
		end
		int_buffer[in_j] = read_data;
      	//$display("The pph value %h,%h ",int_buffer[in_j],in_j);
		in_j = in_j+1;				// next buffer address 
		count = count+1;			// next byte
		pp_h = count;
		if(count >= 256)
			count = 256;
		//$display("One byte of data: %h received for Page Program",read_data);
	end
end
endtask

// Byte program for devices. also used for page program
task byte_program;
input [23:0] write_address;
input [7:0] write_data;
begin
		memory[write_address]= memory[write_address] & write_data;
		`ifdef VERBOSE_TASK_ON
			$display("Byte_Pgm One Byte of data %h written in memory in location %h, %h ", write_data, write_address, memory[write_address]);
		`endif
end
endtask

// Erase a Page 
task page_erase;
input [23:0] erase_address;

reg [8:0] erase_page_i;
reg [23:0] page_addr;

begin   
	erase_start_page = 9'b0_0000_0000;
	page_addr = {erase_address[23:8],8'b0000_0000};
//	$display("Page with start address %h is going to be erased", page_addr);
	for(erase_page_i=erase_start_page; erase_page_i <= 9'b0_1111_1111; erase_page_i=erase_page_i+1)
	begin
         	memory [page_addr + erase_page_i] = 8'hff;				
        	#23438;				///
		if( memory [page_addr + erase_page_i] != 8'hff)
		begin
			$display("Memory is not erased properly!!!");
		end
          if(reset_request == 1'b1)
          begin
               //$display("resetting erase operation");
               #(tSWRST - 23438) ;
               RDYnBSY = 1'b0;
               exit_reset;
               reset = 1'b1;
               disable page_erase;
          end
    end
end
endtask

// Erase a 4kB block
task erase_4kb;
input [23:0] erase_address;

reg [12:0] erase4_i;
reg [23:0] block_addr4;

begin   
	//$display("4kB Block with start address %h is going to be erased", block_addr4);
	erase_start_4 = 13'b0_0000_0000_0000;
	block_addr4 = {erase_address[23:12],12'b0000_0000_0000};
	for(erase4_i=erase_start_4; erase4_i <= 13'b0_1111_1111_1111; erase4_i=erase4_i+1)
	begin
         	memory [block_addr4 + erase4_i] = 8'hff;				
        	#12207;
		if( memory [block_addr4 + erase4_i] != 8'hff)
		begin
			//$display("Memory is not erased properly!!!");
		end
          if(reset_request == 1'b1)
          begin
               //$display("resetting erase operation");
               #(tSWRST - 12207) ;
               RDYnBSY = 1'b0;
               exit_reset;
               reset = 1'b1;							//20140912 software reset test 
//			reset_request = 1'b0;					//20140912 software reset test 
               disable erase_4kb;
          end
    end
end
endtask

// Erase a 32kB block
task erase_32kb;
input [23:0] erase_address;

reg [15:0] erase32_i;
reg [23:0] block_addr32;

begin   
	//$display("32kB Block with start address %h is going to be erased", block_addr32);
        erase_start_32 = 16'b0_000_0000_0000_0000;
        block_addr32 = {erase_address[23:15],15'b000_0000_0000_0000};
	for(erase32_i=erase_start_32; erase32_i <= 16'b0_111_1111_1111_1111; erase32_i=erase32_i+1)
	begin
       		memory [block_addr32 + erase32_i] = 8'hff;				
         //	#9763;
         	#12207;
		if( memory [block_addr32 + erase32_i] != 8'hff)
		begin
			//$display("Memory is not erased properly!!!");
    			EPE = 1'b1;				// Set Error Flag and keep erasing another block
		end
          if(reset_request == 1'b1)
          begin
               //$display("resetting erase operation");
               #(tSWRST - 12207) ;
               RDYnBSY = 1'b0;
               exit_reset;
               reset = 1'b1;
               disable erase_32kb;
          end
    	end
end
endtask


// Chip Erase
task erase_chip;
reg [23:0] erase_i;

begin   
	`ifdef VERBOSE_TASK_ON	
		$display("Chip Erase is going to be started");
	`endif
	for(erase_i=0; erase_i < MEMSIZE; erase_i=erase_i+1)
	begin
         	memory [erase_i] = 8'hff;				
          //	#7629;
          	#12207;
		if( memory [erase_i] != 8'hff)
		begin
			$display("Memory is not erased properly!!!");
    			EPE = 1'b1;				// Set Error Flag and keep erasing another block
		end
          if(reset_request == 1'b1)
          begin
               //$display("resetting erase operation");
               #(tSWRST - 12207) ;
               RDYnBSY = 1'b0;
               exit_reset;
               reset = 1'b1;
               disable erase_chip;
          end
	end
end
endtask

// Software Reset		20140905
task exit_reset;
begin
     erasing_block4 	= 1'b0;
     erasing_block32     = 1'b0;
     erasing_chip		= 1'b0;
     byte_prog			= 1'b0;
     reset_request		= 1'b0;
     WEL				= 1'b0;
end
endtask


// ******************* Execution of Opcodes ********************* //

// ************* Deep Power-down ***************** //
always @(EDPD)
begin : EDPD_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON	
			$display("Device is busy. Deep Power-down command cannot be issued");
		`endif
		disable EDPD_ ;     
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON	
			$display("WARNING: Frequency should be less than fSCK.");
		`endif
	end

	@ (posedge CSB);
	if (abort == 1'b1)
	begin
		`ifdef VERBOSE_TASK_ON	
			$display("Chip Select deasserted at non-even byte boundary.  Abort Deep Power-Down.");
		`endif
		disable EDPD_;
	end
	//RDYnBSY = 1'b1;
	#tEDPD;
	deep_power_down = 1'b1;
	RDYnBSY = 1'b0;
	$display("Device %s enters into Deep Power-down mode. Send 'Resume from Deep Power-down' to resume", DEVICE);    
end

// ************* Resume from Deep Power-down ***************** //
always @(RDPD)
begin : RDPD_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON	
			$display("Device is busy. Deep Power-down command cannot be issued");
		`endif
		disable RDPD_ ;     
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON	
			$display("WARNING: Frequency should be less than fSCK");
		`endif
	end

	@ (posedge CSB);
	if (abort == 1'b1)
	begin
		`ifdef VERBOSE_TASK_ON	
			$display("Chip Select deasserted at non-even byte boundary.  Abort Resume from Deep Power-Down.");
		`endif
		disable RDPD_;
	end
	//RDYnBSY = 1'b1;
	#tRDPD deep_power_down = 1'b0;
	RDYnBSY = 1'b0;
	$display("Device %s Resumes from Deep Power-down mode", DEVICE);
end


/******* Zero  Power-down *****************/
always @(ZPD)
begin : ZPD_
     if (RDYnBSY == 1'b1) // device is already busy
     begin
          `ifdef VERBOSE_TASK_ON
               $display ("Device is busy. Zero Power-down command cannot be issued");
          `endif
          disable ZPD_ ;
     end
     // if it comes here, means, the above if was false.
     @ (posedge CSB);
     #tEUDPD zero_power_down = 1'b1;
     exit_reset;
     foreground_op_enable = 1'b0;
     background_op_enable = 1'b0;
     `ifdef VERBOSE_TASK_ON
          $display("Device %s enters into Zero Power-down mode. Toggle CSBPAD to 'Resume from Zero Power-down", DEVICE);
     `endif
end

// ************* Legacy Manufacturing ID Read ******************** //
always @(MIRL)
begin: MIRL_
	//AT25DF512C.v series allow MIRL while the device is BUSY !!!!
	//if (RDYnBSY == 1'b1) // device is already busy
	//	begin
	//		$display("Legacy Device is busy. Manufacturing ID Read cannot be issued");
	//		disable MIRL_ ;     
	//	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON	
			$display("WARNING: Frequency should be less than fSCK.");
		`endif
	end

	j = 32;
	while (CSB == 1'b0)
	begin
		@(negedge CLK);
		dout_phase = 1'b1;
	 	SO_reg = 1'bx;
		#tV;
		SO_reg = MAN_ID[j-1];
          	if (j == 16)
		begin
			`ifdef VERBOSE_TASK_ON	
				$display("Legacy Manufacture ID and Device ID of Device %s sent", DEVICE);
			`endif
			dout_phase = 1'b0;
              	disable MIRL_;
		end
	  	else
         		j = j - 1;
	end // output next bit on next falling edge of SCK
	`ifdef VERBOSE_TASK_ON	
		$display("Legacy Manufacture ID and Device ID of Device %s sent", DEVICE);
	`endif
end

// ************* Manufacturing ID Read ******************** //
always @(MIR)
begin: MIR_
	//AT25DF161.v series allow MIR while the device is BUSY !!!!
	//if (RDYnBSY == 1'b1) // device is already busy
	//	begin
	//		$display("Device is busy. Manufacturing ID Read cannot be issued");
	//		disable MIR_ ;     
	//	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON	
			$display("WARNING: Frequency should be less than fSCK.");
		`endif
	end

	j = 32;
	while (CSB == 1'b0)
	begin
		@(negedge CLK);
		dout_phase = 1'b1;
	 	SO_reg = 1'bx;
		#tV;
		SO_reg = MAN_ID[j-1];
          	if (j == 0)
		begin
			`ifdef VERBOSE_TASK_ON	
				$display("Manufacture ID and Device ID of Device %s sent", DEVICE);
			`endif
			dout_phase = 1'b0;
              	disable MIR_;
		end
	  	else
         		j = j - 1;
	end // output next bit on next falling edge of SCK
	`ifdef VERBOSE_TASK_ON	
		$display("Manufacture ID and Device ID of Device %s sent", DEVICE);
	`endif
end

                        
// ************* Read Status Register ******************** //
always @ (RSR)
begin : RSR_
	if (tMAX==1'b1)
	begin	
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK");
		`endif
	end
     //	j = 7;
     	j = 15;
    	while (CSB == 1'b0)
    	begin
		@(negedge CLK);
		dout_phase = 1'b1;
	 	SO_reg = 1'bx;
		#tV;
		SO_reg = status_reg[j];
         	if(j == 0)
         	begin
    			//$display("Status register Byte of content of Device %s transmitted", DEVICE);
         		j = 15;
         	end
		else
			j = j - 1;	// next bit
   	end
end

// ************ Write Status Register Byte ******************** //
always @(WSR1)
begin : WSR1_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Device %s is busy. Write Status Register is not allowed", DEVICE);
		`endif
		disable WSR1_;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK");
		`endif
	end

 	get_data;
	BPL_val = read_data [7];
	BP0_val = read_data [2];

	no_action = (BPL_val ~^ BPL) & (BP0_val ~^ BP0);
	
	@ (posedge CSB);
	if ((WEL==1'b1) && (abort==1'b0) && (cmd_2byte==1'b1) && (no_action==1'b0))
	begin
     		WEL = 1'b0;
		casex({WPB,BPL,BP0,BPL_val,BP0_val})
		5'b0_1x_xx:	//WPB=0 & BPL=1
			begin
				`ifdef VERBOSE_TASK_ON
					$display("BPL Hardware locked, BP0 is locked ");
				`endif
				disable WSR1_;
			end
		5'b0_0x_xx:	//WPB=0 & BPL=0
			begin
				`ifdef VERBOSE_TASK_ON
					$display("Not Hardware locked; BPL/BP0 are freely to set/reset");
				`endif
     				RDYnBSY = 1'b1;
				#tWRSR;
				BP0_reg[0] = {8{BP0_val}};	//prot/unprotected
              			BP0 = BP0_val;
				BPL_reg[0] = {8{BPL_val}};	//locked			?????????????????? locked should be no change?
              			BPL = BPL_val;
			end
		5'b1_xx_xx:	//WPB=1
			begin
				`ifdef VERBOSE_TASK_ON
					$display("Not hardware locked; BPL/BP0 are freely set/reset");
				`endif
     				RDYnBSY = 1'b1;
				#tWRSR;
				BP0_reg[0] = {8{BP0_val}};
              			BP0 = BP0_val;
				BPL_reg[0] = {8{BPL_val}};
              			BPL = BPL_val;
			end
		endcase
	end

	else if ((WEL==1'b1) && (abort==1'b0) && (cmd_2byte==1'b1) && no_action==1'b1)
	begin
     		WEL = 1'b0;
		`ifdef VERBOSE_TASK_ON
         		$display("No action is required");
		`endif
	end
	else if ((abort==1'b1) | (WEL==1'b0) | (cmd_2byte==1'b0))
	begin
		`ifdef VERBOSE_TASK_ON
         		$display("WEL bit not set or Chip Select deasserted at non-even byte boundary. Abort Write Status Register");
		`endif
	end
	RDYnBSY = 1'b0;
	`ifdef VERBOSE_TASK_ON
		$display("Write Status Register operation completed");
	`endif
end

//************ Write Status Register Byte 2 *************//			20140905
always @(WSR2)
begin : WSR2_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Device %s is busy. Write Status Register is not allowed", DEVICE);
		`endif
		disable WSR2_;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK");
		`endif
	end

 	get_data;
     @(posedge CSB);
     begin
          if ((abort==1'b1) || (WEL==1'b0) || (cmd_2byte==1'b0))
          begin
               $display("Either Chip Select deasserted at non even byte boundary or WEL bit not set.  Abort Write Status Register ");
               WEL = 1'b0;
               disable WSR2_;
          end
          else if ((abort==1'b0) && (WEL==1'b1) && (cmd_2byte==1'b1))
          begin
               RSTE  = read_data[4] ;
               #tWRSR;
               $display("Write Status Register Byte2  operation completed");
          end
          WEL = 1'b0;
          RDYnBSY = 1'b0;
     end
end



// ************ Write Enable ******************** //
always @(WE)
begin : WE_
	if (RDYnBSY == 1'b1) // device is already busy
    	begin
		`ifdef VERBOSE_TASK_ON
         		$display("Device %s is busy. Write Enable is not allowed", DEVICE);
		`endif
         	disable WE_;
    	end
   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK");
		`endif
	end
      
	@ (posedge CSB);
	if (abort == 1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Chip Select deasserted at non-even byte boundary.  Abort  Write Enable Command");
		`endif
         	disable WE_;
	end
	`ifdef VERBOSE_TASK_ON
		$display("Write Enable Latch Set");
	`endif
	WEL = 1'b1;
end

// ************ Write Disable ******************** //
always @(WD)
begin : WD_
	if (RDYnBSY == 1'b1) // device is already busy
    	begin
		`ifdef VERBOSE_TASK_ON
         		$display("Device %s is busy. Write Disable is not allowed", DEVICE);
		`endif
         	disable WD_;
    	end

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK.");
		`endif
	end

	@ (posedge CSB);
	if (abort==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Chip Select deasserted at non-even byte boundary.  Abort  Write Disable Command");
		`endif
         	disable WD_;
	end
	`ifdef VERBOSE_TASK_ON
		$display("Write Enable Latch Reset");
	`endif
	WEL = 1'b0;
end

// ************ Reset F0 -- D0 ******************** //		//20140905
always @ (RST)
begin:RST_
     if (tMAX==1'b1)
          $display("WARNING: Frequency should be less than fMAX");
	get_data;
	con_byte = read_data[7:0];

     @(posedge CSB);
     if ((abort == 1'b1) | (cmd_2byte==1'b0))
     begin
          $display("Chip Select deasserted at non-even byte boundary.  Abort Reset Command");
          disable RST_;
     end
     if(con_byte != 8'hD0)
     begin
          $display("The Confirmation Byte received is wrong %h.  Abort Reset Command",con_byte);
          disable RST_;
     end
     if(RSTE == 1'b0)
     begin
          $display("RSTE Bit is not set.  Abort Reset Command");
          disable RST_;
     end
     if (RDYnBSY==1'b0) 
     begin
          $display("Reset during not BUSY");
          reset_request = 1'b1;
          #100;
          //#tSWRST;
          exit_reset;
          disable RST_;
     end
     if (otp_sec_prog==1'b1)
     begin
          $display("Chip is not in memory modified mode.  Abort Reset Command");
          disable RST_;
     end
     reset_request = 1'b1;
     $display("The Reset signal Issued and Device Entered into Idle State");
end


// ******************** Read Array ********************** //
always @(RA)
begin : RA_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Device %s is busy. Read Array is not allowed", DEVICE);
		`endif
		disable RA_;
	end
	// if it comes here, means, the above if was false.

	if ((rd_dummy==0)  && (tRDLF==1'b1))						// RD_03h
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fRDLF");
		`endif
	end
	else if ((rd_dummy==1) & (tMAX==1'b1))						// RD_0Bh  
	begin
		`ifdef VERBOSE_TASK_ON
	 		$display(" WARNING: Frequency is greater that fSCK");
		`endif
	end

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {12'h000 , temp_addr[(PA_SIZE+BA_SIZE-1):0]};

     for(i = rd_dummy ; i>0 ; i = i - 1)
     begin
		dummy_phase = 1'b1;
         	for (j = 7; j >= 0; j = j - 1) // these are dont-care, so discarded
		begin
			@(posedge CLK);  
			read_dummy[j] = SI;
	    	end
	    	read_dummy = 8'h0;
		dummy_phase = 1'b0;
	end

	read_out_array(current_address); // read continuously from memory untill CSB deasserted
	current_address = 24'b0;
        
end

// ********************* Dual Read Array ****************** //
always @ (DORA)
begin : DORA_
     if (RDYnBSY == 1'b1) // device is already busy
          begin
               $display("Device is busy. Dual Output read array cannot performed");
               disable DORA_ ;
          end
     if (tRDDO==1'b1)
     $display("WARNING: Frequency should be less than fRDDO");
     get_data;
     temp_addr [23:16] = read_data [7:0];
     get_data;
     temp_addr [15:8] = read_data [7:0];
     get_data;
     temp_addr [7:0] = read_data [7:0];

     current_address = {12'h000 , temp_addr[(PA_SIZE+BA_SIZE-1):0]};


     for(i = rd_dummy ; i>0 ; i = i - 1)
     begin
          for (j=7; j>= 0; j=j-1) // these are dont-care, so discarded
          begin
               @(posedge CLK);
               read_dummy[j] = SI;
          end
          read_dummy = 8'h0;
     end
     sdindual_en = 1'b1;
     dual_out_array(current_address); // read continuously from memory untill CSB deasserted
     current_address = 24'b0;
end


// ********************* Byte Program ********************* //
always @(BP)
begin : BP_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Device %s is busy. Byte Program is not allowed", DEVICE);
		`endif
		disable BP_ ; 
	end
	// if it comes here, means, the above if was false.
        

     	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK");
		`endif
	end

	// to receive 3 bytes of address
	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {12'h000 , temp_addr[(PA_SIZE+BA_SIZE-1):0]};

	buffer_address = current_address[(BA_SIZE-1):0];
     	EPE = 1'b0; 
	buffer_write(buffer_address);								// page program - receives data

	if((abort == 1) | (WEL==1'b0) | (cmd_5byte==1'b0))			// page program should not proceed if CSB deasserted at intermediate points
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Chip Select deasserted in non-even byte boundary or WEL bit is not set. Abort Byte/Page Program command");
		`endif
		WEL = 1'b0;
		disable BP_ ;
	end
    	if(BP0==1'b1) 
    	begin
		`ifdef VERBOSE_TASK_ON
			$display("Memory is Protected. Byte Program cannot be performed", current_address);
		`endif
		WEL = 1'b0;
    		disable BP_ ;
    	end
	else  
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Memory is UnProtected, Byte Program can be performed", current_address);
		`endif
		RDYnBSY	= 1'b1;
		WEL		= 1'b0;
		byte_prog = 1'b1;
		page_program(current_address[7:0]);
		`ifdef VERBOSE_TASK_ON
			$display("Byte write completed");
		`endif

//20140915	test
		if (reset == 1'b1)
		begin
			$display("Device is in reset mode");
			reset = 1'b0;
			disable BP_;
		end

		pp		 = 0;
		pp_h		 = 0;
		pp_i		 = 0;
		RDYnBSY	 = 1'b0;
		byte_prog	 = 1'b0;
		current_address  = 24'h000000;
		pp_address	 = 8'h00;
		data_in		 = 8'b0;
	end
end

task page_program;
input [7:0] pp_address;
begin
   		if(pp_h < 256)
         		full_page = 1'b0;
		else
		begin
         		full_page = 1'b1;
			pp_h = 256;
		end
		for(pp = 0; pp < pp_h; pp = pp+1)
		begin
			data_in = int_buffer[pp_address];
			byte_program({current_address[23:8],pp_address}, data_in);
			pp_address = pp_address + 1'b1;
			if (pp==0)		#tBP;		// First byte program time: tBP 
			else if (pp<256)	#5835;		// Subsequence bytes program time: (tPP-tBP)/255
			else 	;					// already reach up to tPP
               if(reset_request == 1'b1)
               begin
                    #(tSWRST - tBP)  ;                        // reset latency
                    RDYnBSY    = 1'b0;
//				byte_prog = 1'b0;
//				reset_request = 1'b0;
                    reset = 1'b1;
                    exit_reset;
                    disable page_program ;
               end
		end
end
endtask

// ********************* Page Erase ********************* //	20140905
always @(PE)
begin : PE_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Device %s is busy. Page Erase is not allowed", DEVICE);
		`endif
		disable PE_ ;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK.");
		`endif
	end

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {12'h000 , temp_addr[(PA_SIZE+BA_SIZE-1):0]};

	@ (posedge CSB);
	if ((abort==1'b1) | (WEL==1'b0) | (cmd_4byte==1'b0))
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Chip Select deasserted in non-even byte boundary or WEL bit is not set. Abort Byte/Page Program command");
		`endif
		WEL = 1'b0;
		disable PE_ ;
	end
    	EPE = 1'b0; 
	if(BP0==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Memory is Protected. Page Erase cannot be performed", current_address);
		`endif
		WEL = 1'b0;
		disable PE_ ;
	end
	`ifdef VERBOSE_TASK_ON
		$display("Memory is UnProtected, Page Erase can be performed", current_address);
	`endif
	RDYnBSY = 1'b1;
	WEL = 1'b0;
	erasing_page = 1'b1;
	page_erase(current_address);
	`ifdef VERBOSE_TASK_ON
   		$display("Page with start address %h erased", {current_address[23:8],8'h00});
	`endif
//20140915	test
	if (reset == 1'b1)
	begin
		$display("Device is in reset mode");
		reset = 1'b0;
		disable PE_;
	end

	RDYnBSY = 1'b0;
	erasing_page = 1'b0;
	current_address = 24'b0;
end


// ********************* 4kB Block Erase ********************* //
always @(BE4)
begin : BE4_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Device %s is busy. 4KB Block Erase is not allowed", DEVICE);
		`endif
		disable BE4_ ;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK.");
		`endif
	end

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {12'h000 , temp_addr[(PA_SIZE+BA_SIZE-1):0]};

	@ (posedge CSB);
	if ((abort==1'b1) | (WEL==1'b0) | (cmd_4byte==1'b0))
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Chip Select deasserted in non-even byte boundary or WEL bit is not set. Abort Byte/Page Program command");
		`endif
		WEL = 1'b0;
		disable BE4_ ;
	end
    	EPE = 1'b0; 
	if(BP0==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Memory is Protected. 4KB Block Erase cannot be performed", current_address);
		`endif
		WEL = 1'b0;
		disable BE4_ ;
	end
	`ifdef VERBOSE_TASK_ON
		$display("Memory is UnProtected, 4KB Block Erase can be performed", current_address);
	`endif
	RDYnBSY = 1'b1;
	WEL = 1'b0;
	erasing_block4 = 1'b1;
	erase_4kb(current_address);

//20140915	test
	if (reset == 1'b1)
	begin
		$display("Device is in reset mode");
		reset = 1'b0;
		disable BE4_;
	end

	`ifdef VERBOSE_TASK_ON
   		$display("4kB Block with start address %h erased", {current_address[23:12],12'b0});
	`endif
	RDYnBSY = 1'b0;
	erasing_block4 = 1'b0;
	current_address = 24'b0;
end

// ********************* 32kB Block Erase ********************* //
always @(BE32)
begin : BE32_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Device %s is busy. 32KB Block Erase is not allowed", DEVICE);
		`endif
		disable BE32_ ;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK.");
		`endif
	end

	$display("ENTER BE32_");
	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

	current_address = {12'h000 , temp_addr[(PA_SIZE+BA_SIZE-1):0]};

	@ (posedge CSB);
	if ((abort==1'b1) | (WEL==1'b0) | (cmd_4byte==1'b0))
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Chip Select deasserted in non-even byte boundary or WEL is not set. Abort Byte/Page Program command");
		`endif
		WEL = 1'b0;
		disable BE32_ ;
	end
     EPE = 1'b0; 
     if(BP0==1'b1)
    	begin
		`ifdef VERBOSE_TASK_ON
    			$display("Memory is Protected.  32KB Block Erase cannot be performed", current_address);
		`endif
    		WEL = 1'b0;
    		disable BE32_;
    	end
	`ifdef VERBOSE_TASK_ON
		$display("Memory is UnProtected, 32KB Block Erase can be performed", current_address);
	`endif
	RDYnBSY = 1'b1;
	WEL = 1'b0;
	erasing_block32 = 1'b1;
	erase_32kb(current_address);
//20140915	test
	if (reset == 1'b1)
	begin
		$display("Device is in reset mode");
		reset = 1'b0;
		disable BE32_;
	end

	`ifdef VERBOSE_TASK_ON
		$display("32kB Block with start address %h erased", {current_address[23:15],15'b0});
	`endif
	RDYnBSY = 1'b0;
	erasing_block32 = 1'b0;
	current_address = 24'b0;
end

// ********************* Chip Erase ********************* //
always @(CE)
begin : CE_ 
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Device %s is busy. Chip Erase is not allowed", DEVICE);
		`endif
		disable CE_ ;
	end
	// if it comes here, means, the above if was false.

   	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK.");
		`endif
	end

	@(posedge CSB);
	if ((abort==1'b1) || (WEL==1'b0) || (cmd_1byte==1'b0))
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Chip Select deasserted in non-even byte boundary or WEL is not set. Abort Chip Erase command");
		`endif
		WEL = 1'b0;
		disable CE_ ;
	end
     	EPE = 1'b0; 
    	if(BP0==1'b1)
     	begin
		`ifdef VERBOSE_TASK_ON
     			$display("Memory is Protected.  Abort Chip Erase.");
		`endif
       		WEL = 1'b0;
       		disable CE_;
    	end
	`ifdef VERBOSE_TASK_ON
		$display("Chip Erase inprogress");
	`endif
//20140915	test
	if (reset == 1'b1)
	begin
		$display("Device is in reset mode");
		reset = 1'b0;
		disable CE_;
	end

	RDYnBSY = 1'b1;
	WEL = 1'b0;
	erasing_chip = 1'b1;
 	erase_chip;
	`ifdef VERBOSE_TASK_ON
		$display("Chip Erase is completed"); 
	`endif
	RDYnBSY = 1'b0;
	erasing_chip = 1'b0;
end

//**************************frequency validation**********************///
always @ (SCK)
begin
     if(SCK == 1'b1)
     begin
     	clk_val    <= $time;
     	clk_val_d  <= clk_val;
     end
     
end
always @ (SCK)
begin
     clk_diff <= clk_val - clk_val_d;
end

always @ (SCK)
begin
      if (clk_diff  > time_12ns || clk_diff == time_12ns)
      tMAX <= 1'b0;
      else if(clk_diff  < time_12ns)
      tMAX <= 1'b1;

      if (clk_diff  > time_20ns || clk_diff == time_20ns)
      tRDDO <= 1'b0;
      else if(clk_diff  < time_20ns)
      tRDDO <= 1'b1;

      if(clk_diff > time_30ns || clk_diff == time_30ns)
      tRDLF <= 1'b0;
      else if(clk_diff < time_30ns)
      tRDLF <= 1'b1;

end

// ************************************************************* //
wire SI_input_phase      =    ~(dout_phase || dummy_phase);
wire SO_input_phase		=	(sdindual_en && ~dout_phase);		//20140904 SO input

specify
     specparam tCSLS = 6;
     specparam tCSLH = 6;
     specparam tCSHS = 6;
     specparam tCSHH = 6;
     specparam tCSH = 50;
     specparam tHHH = 6;
     specparam tHLS = 6;
     specparam tHLH = 6;
     specparam tHHS = 6;
     specparam tDS     = 2 ;         // Data in Setup time
     specparam tDH     = 1 ;         // Data in Hold time
     specparam tCLKH   = 4;
     specparam tCLKL   = 4;

     $width (posedge SCK, tCLKH);
     $width (negedge SCK, tCLKL);

     $setup (SI, posedge SCK &&& SI_input_phase, tDS);
     $hold (posedge SCK, SI &&& SI_input_phase, tDH);

     $setup (SO, posedge SCK &&& SO_input_phase, tDS);
     $hold  (posedge SCK, SO &&& SO_input_phase, tDH);

     $setup (HOLDB, posedge SCK &&& ~CSB, tHLS);
     $hold (negedge SCK, HOLDB &&& ~CSB, tHLH);
     $setup (HOLDB, negedge SCK &&& ~CSB, tHHS);
     $hold (posedge SCK, HOLDB &&& ~CSB, tHHH);

     $setup (CSB, posedge SCK, tCSLS);
     $hold (posedge SCK, CSB, tCSLH);
     $setup (posedge CSB, posedge SCK, tCSHS);
     $hold (posedge SCK, posedge CSB, tCSHH);
     $width (posedge CSB, tCSH);
endspecify

wire CSB_DEL;
assign #(20, 0) CSB_DEL = CSB;

//**************************Byte Boundary checking**********************///
//SPI Clock Counter
always @(posedge CLK or posedge CSB_DEL)
begin : sckcnt_
	if (CSB_DEL==1'b1)
		sckcnt	<= 0;
	else	
		sckcnt 	<= sckcnt + 1;
end

//
always @(sckcnt)
begin
     if (sdindual_en==1'b1)
          abort_boundary = (|sckcnt[1:0] == 1'b1) ? 1'b1 : 1'b0;
     else
		abort_boundary =  (|sckcnt[2:0] == 1'b1) ? 1'b1 : 1'b0;

end

//Command regs 
always @(posedge CLK or posedge CSB_DEL)
begin : cmd_regs
	if (CSB_DEL == 1'b1)
	begin
		cmd_1byte <=	1'b0; 
		cmd_2byte <=	1'b0;
		cmd_4byte <=	1'b0;
		cmd_5byte <=	1'b0;
	end
	else if (sckcnt == 5'h07)
		cmd_1byte <= 1'b1;
	else if (sckcnt == 5'h0f)
		cmd_2byte <= 1'b1;
	else if (sckcnt == 5'h1f)
		cmd_4byte <= 1'b1;
     else if ((sckcnt == 8'h23) && (sdindual_en==1'b1))		//20140904
		cmd_5byte <= 1'b1;
	else	if (sckcnt == 8'h27)
		cmd_5byte <= 1'b1;
	else
	begin
		cmd_1byte <= cmd_1byte;
		cmd_2byte <= cmd_2byte;
		cmd_4byte <= cmd_4byte;
		cmd_5byte <= cmd_5byte;
	end
end

// For HOLDB pin spec.

assign CLK = ~HOLD_EN & SCK;
//assign #(tHLQZ, tHHQX) SO_EN = ((HOLD_EN==1'b0) & (dout_phase==1'b1)) ? 1'b1 : 1'b0;
//assign #(tHLQZ, tHHQX) SI_EN = ((HOLD_EN==1'b0) & (dout_phase==1'b1) & (sdindual_en==1'b1)) ? 1'b1 : 1'b0;
assign SO_EN = ((HOLD_EN==1'b0) & (dout_phase==1'b1)) ? 1'b1 : 1'b0;
assign SI_EN = ((HOLD_EN==1'b0) & (dout_phase==1'b1) & (sdindual_en==1'b1)) ? 1'b1 : 1'b0;


// hold latch  
always @(HOLDB or SCK or CSB)
begin : hold_en_ 
	if (CSB==1'b1)
	begin
		HOLD_EN	<= 0;
		abort_holdb <= ~HOLDB;
	end
	else	if (SCK==1'b0)
		HOLD_EN 	<= ~HOLDB;
end
/*
reg SO_en;
always @ (posedge HOLDB)
begin
	#tHHQX;
	SO_en = 1;	
end
*/


always @(abort_boundary or abort_holdb)
begin
	abort = abort_boundary | abort_holdb;
end

///// Output control Registers
always @(SO_EN)
begin : SO_on_ 
	SO_on = SO_EN ;
end 

always @(SI_EN)
begin : SI_on_ 
	SI_on = SI_EN ;
end 

//////////////////////////////////////////////////////////////////////////
//Programe OTP Security register
always @ (POSR)
begin :POSR_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Device %s is busy. OTP is not allowed", DEVICE);
		`endif
		disable POSR_;
	end
	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK.");
		`endif
	end

	// to receive 3 bytes of address
	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];

    	current_address = {12'h000 , temp_addr[(PA_SIZE+BA_SIZE-1):0]};
        
	page_otp_program(current_address[5:0]);				// return pp_h value

	if ((abort == 1'b1) || (WEL==1'b0) || (cmd_5byte==1'b0))
	begin
		`ifdef VERBOSE_TASK_ON
			$display("The CSB deasserted at Non even byte boundary or WEL is not set.  Aborting Program OTP Security Register" );
		`endif
         	WEL = 1'b0;
    		disable POSR_;
	end
	if (security_flag == 1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
         		$display("Security OTP Register has been modified before.  Abort Program OTP Security Register");
		`endif
          	WEL = 1'b0;
		disable POSR_ ;
	end
	RDYnBSY = 1'b1;
	WEL		 = 1'b0;
	OTP_address = current_address[5:0];
	otp_sec_prog = 1'b1;
	for(pp = 0; pp < pp_h; pp = pp+1)
	begin
		data_in = OTP_buffer[OTP_address];
		OTP_program(OTP_address, data_in);
		OTP_address = OTP_address + 1'b1;
	end
	security_flag = 1'b1;
	`ifdef VERBOSE_TASK_ON
		$display("OTP write completed");
	`endif
	#tOTPP;
	pp_h		 = 0;
	pp_j		 = 0;
	pp_i		 = 0;
	RDYnBSY		 = 1'b0;
	current_address  = 24'b0;
	OTP_address	 = 8'b0;
	data_in		 = 8'b0;
	otp_sec_prog = 1'b0;
end 

task page_otp_program;
input [5:0]pp_j;
reg [6:0]count_OTP;
begin
	count_OTP = 0;
	while(CSB==1'b0)
	begin
		for (pp_i=7; pp_i>=0; pp_i = pp_i-1)
		begin
			@(posedge CLK);  
			read_data[pp_i] = SI;
		end
		OTP_buffer[pp_j] = read_data;
		`ifdef VERBOSE_TASK_ON
          		$display("The ppj value %h,%h ",read_data,pp_j);
		`endif
		pp_j = pp_j+1;
          	count_OTP = count_OTP+1;
		pp_h = count_OTP;
		if(count_OTP >= 63)
			count_OTP = 63;

		`ifdef VERBOSE_TASK_ON
			$display("One byte of data: %h received for OTP Program",read_data);
		`endif
	end
end
endtask


task OTP_program;
input [5:0] write_address;
input [7:0] write_data;
begin
	security_reg[write_address] = write_data;
	`ifdef VERBOSE_TASK_ON
		$display("One Byte of data %h written in security location %h", write_data, write_address);
	`endif
end
endtask


//Read OTP Security Register
always @(ROSR)
begin : ROSR_
	if (RDYnBSY == 1'b1) // device is already busy
	begin
		`ifdef VERBOSE_TASK_ON
			$display("Device %s is busy. Read OTP is not allowed", DEVICE);
		`endif
		disable ROSR_;
	end
	// if it comes here, means, the above if was false.

	if (tMAX==1'b1)
	begin
		`ifdef VERBOSE_TASK_ON
			$display("WARNING: Frequency should be less than fSCK");
		`endif
	end

	get_data;
	temp_addr [23:16] = read_data [7:0];
	get_data;
	temp_addr [15:8] = read_data [7:0];
	get_data;
	temp_addr [7:0] = read_data [7:0];
	current_address = temp_addr;

	OTP_rd_address = current_address[6:0];

	for(i = rd_dummy ; i>0 ; i = i - 1)
    	begin
		dummy_phase = 1'b1;
        	for (j = 7; j >= 0; j = j - 1) // these are dont-care, so discarded
		begin
			@(posedge CLK);  
			read_dummy[j] = SI;
    		end
    		read_dummy = 8'h0;
		dummy_phase = 1'b0;
	end

	read_OTP_security(OTP_rd_address); // read continuously from memory untill CSB deasserted
	current_address = 24'b0;
end

task read_OTP_security ;
input [6:0] read_addr;
integer i;

begin
	temp_data = OTP_reg [read_addr];		// access the Manu upper 64-bytes
     j = 7;
	while (CSB == 1'b0) // continue transmitting, while, CSB is Low
	begin
		@(negedge CLK);
		dout_phase = 1'b1;
		SO_reg = 1'bx;
		#tV;
		SO_reg = temp_data[j];
		if (j == 0) 
		begin
			`ifdef VERBOSE_TASK_ON
				$display("Read OTP Data: %h read from OTP memory location %h",temp_data,read_addr);
			`endif
			read_addr = read_addr + 1; // next byte
         		j = 7;
			temp_data = OTP_reg [read_addr];
		end
		else
			j = j - 1; // next bit
	end		// reading over, because CSB has gone high
end
endtask


task dual_out_array ;
input [23:0] read_addr;
integer i;

begin
      //$display("Attempt to Read a Suspended Sector.  The data is undefined ");
     temp_data = memory [read_addr];
     i = 3;
     while (CSB == 1'b0) // continue transmitting, while, CSB is Low
     begin
          @(negedge CLK);
          dout_phase = 1'b1;
          SO_reg = 1'bx;
          SI_reg = 1'bx;
          #tV;
          SI_reg = temp_data[i*2];
          SO_reg = temp_data[i*2+1];
          if (i == 0)
          begin
               $display("Dual Read Data: %h read from memory location %h",temp_data,read_addr);
               read_addr = read_addr + 1; // next byte
               i = 3;
               if (read_addr >= MEMSIZE)
                    read_addr = 0; // Note that rollover occurs at end of memory,
               temp_data = memory [read_addr];
          end
          else
               i = i -1; // next bit
     end  // reading over, because CSB has gone high
end
endtask


always @(*)
begin
	for (j=0; j<128; j=j+1)
	begin
		if (j<64)
			OTP_reg[j] = security_reg[j];
		else
			OTP_reg[j] = factory_reg[j-64];
	end
end

// ******** Posedge CSB. Stop all reading, recvng. commands/addresses etc. ********* //

always @(posedge CSB)
begin
	disable RA_;	// Read Array (low freq and normal freq)
	disable DORA_;	// Dual Read Array 
	disable MIR_;	// MIR will stop, if CSB goes high
	disable MIRL_;	// MIRL will stop, if CSB goes high
	disable RSR_;	// Status reading should stop.

	disable read_out_array;		// send data in SO
    	disable dual_out_array;
	disable buffer_write;
	disable page_otp_program;
    	disable read_OTP_security;
	temp_data = 8'b0;
	rd_dummy  = 0;
	dummy_phase = 1'b0;

	#tDIS SO_on = 1'b0;  // SO is now in high-impedance
	SO_reg = 1'b0;
	SI_reg = 1'b0;
	SI_on  = 1'b0;
	dout_phase = 1'b0;
	sdindual_en= 1'b0;
end
       
//----------------------------------------------------------------------------------
// ******** Posedge CSB_DEL.  commands/addresses etc. ********* //

always @(posedge CSB_DEL)
begin
	if (!zero_power_down)
	begin
		disable get_data;		// Stop address/data retrieval
		disable get_opcode;
		read_data = 8'b0;
	end
end

      
endmodule 
