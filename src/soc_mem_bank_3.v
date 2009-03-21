// --------------------------------------------------------------------
//
// --------------------------------------------------------------------




module soc_mem_bank_3(
	                      input   [31:0]  mem_data_i,
	                      output  [31:0]  mem_data_o,
	                      input   [31:0]  mem_addr_i,
	                      input   [3:0]   mem_sel_i,
	                      input           mem_we_i,
	                      input           mem_cyc_i,
	                      input           mem_stb_i,
	                      output          mem_ack_o,
	                      output          mem_err_o,
	                      output          mem_rty_o,
	      
	                      input           mem_clk_i, 
	                      input           mem_rst_i
	                    );
                     
	parameter MEM_DEPTH 	= 14; 

  //---------------------------------------------------
  // ram_byte_0
	soc_ram #( 	.DATA_WIDTH(8), .ADDR_WIDTH(MEM_DEPTH), .MEM_INIT(0) )
	i_ram_byte_0				(
		                    .data(mem_data_i[7:0]),
		                    .addr( mem_addr_i[(MEM_DEPTH + 1):2] ),
		                    .we(mem_we_i & mem_sel_i[0]),
		                    .clk(~mem_clk_i),
		                    .q(mem_data_o[7:0])
		                  );
	                    
  //---------------------------------------------------
  // ram_byte_1
	soc_ram #( 	.DATA_WIDTH(8), .ADDR_WIDTH(MEM_DEPTH), .MEM_INIT(0) )
	i_ram_byte_1				(
		                    .data(mem_data_i[15:8]),
		                    .addr( mem_addr_i[(MEM_DEPTH + 1):2] ),
		                    .we(mem_we_i & mem_sel_i[1]),
		                    .clk(~mem_clk_i),
		                    .q(mem_data_o[15:8])
		                  );
		                  
  //---------------------------------------------------
  // ram_byte_2
	soc_ram #( 	.DATA_WIDTH(8), .ADDR_WIDTH(MEM_DEPTH), .MEM_INIT(0) )
	i_ram_byte_2				(
		                    .data(mem_data_i[23:16]),
		                    .addr( mem_addr_i[(MEM_DEPTH + 1):2] ),
		                    .we(mem_we_i & mem_sel_i[2]),
		                    .clk(~mem_clk_i),
		                    .q(mem_data_o[23:16])
		                  );
	                    
  //---------------------------------------------------
  // ram_byte_3
	soc_ram #( 	.DATA_WIDTH(8), .ADDR_WIDTH(MEM_DEPTH), .MEM_INIT(0) )
	i_ram_byte_3				(
		                    .data(mem_data_i[31:24]),
		                    .addr( mem_addr_i[(MEM_DEPTH + 1):2] ),
		                    .we(mem_we_i & mem_sel_i[3]),
		                    .clk(~mem_clk_i),
		                    .q(mem_data_o[31:24])
		                  );
	                    
	                    
	                                               
  //---------------------------------------------------
  // outputs
  assign mem_ack_o = mem_cyc_i & mem_stb_i;
  assign mem_err_o = 1'b0;
  assign mem_rty_o = 1'b0;

endmodule

