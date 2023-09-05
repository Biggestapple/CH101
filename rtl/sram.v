//----------------------------------------------------------------------------------------------------------
//	FILE: 		sram.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	KM62256 behavior model -- 32kx8 bit CMOS Static Ram
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.9.1			create
//								2023.9.3			rebuild
//-----------------------------------------------------------------------------------------------------------
module sram(
	input	clk,
	input	sys_rst_n,
	input	[14:0]		mem_addr,
	input	sram_cs,					//(active high)
	
	output	[7:0]		mem_rdata,
	input	[7:0]		mem_wdata,
	
	input	we_pin						//(active high)
);
wire	[7:0]		wr_data,rd_data;
wire	[14:0]		addt;
wire	wr_en;
wire	rst;	
ram32x8b ram32x8b_dut (
  .wr_data		(wr_data),
  .addr			(mem_addr), 
  .wr_en		(wr_en),     
  .clk			(clk),
  .rst			(rst),
  .rd_data		(rd_data)
);

assign mem_rdata =rd_data;
assign wr_data =mem_wdata;
assign rst =~sys_rst_n;
assign wr_en =we_pin && sram_cs;
endmodule