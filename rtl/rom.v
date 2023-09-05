//----------------------------------------------------------------------------------------------------------
//	FILE: 		rom.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	St27256 behavior model 32kx8 bit PROM
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.9.1			create
//								2023.9.3			rebulid
//-----------------------------------------------------------------------------------------------------------
module rom(
	input	[14:0]		rom_addr,
	output	[7:0]		rom_data,
	input	clk,					//Fpga internal logic
	input	sys_rst_n
);
wire	rst;
wire	[7:0]		rd_data;
rom_32x8b rom_32x8b_dut(
	.clk		(clk),
	.rst		(rst),
	
	.addr		(rom_addr),
	.rd_data	(rd_data)

);
assign rst =~sys_rst_n;
assign rom_data =rd_data;
endmodule