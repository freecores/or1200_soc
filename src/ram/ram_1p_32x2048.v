// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


module ram_1p_32x2048( data, addr, we, clk, q );

  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 11;
  parameter MEM_INIT = "../../sw/load_this_to_ram/qmem.txt";
  
  input [(DATA_WIDTH-1):0] data;
  input [(ADDR_WIDTH-1):0] addr;
  input we;
  input clk;
  output [(DATA_WIDTH-1):0] q;
  
  // Declare the RAM variable
  reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];
  reg [ADDR_WIDTH-1:0] addr_reg;
  
  
  always @ (posedge clk)
    begin
      // Write
      if (we) ram[addr] <= data;
      addr_reg <= addr;
    end
  
  // Read returns NEW data at addr if we == 1'b1. This is the
  // natural behavior of TriMatrix memory blocks in Single Port
  // mode
  assign q = ram[addr_reg];

	generate 
		if( MEM_INIT != 0 )
		  initial
		    $readmemh( MEM_INIT, ram );
	endgenerate		    

endmodule