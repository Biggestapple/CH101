//----------------------------------------------------------------------------------------------------------
//	FILE: 		sram.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	KM62256 behavior model -- 32kx8 bit CMOS Static Ram
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.9.30			create
//-----------------------------------------------------------------------------------------------------------
module sram(
	input	[14:0]		mem_addr,
	inout	[7:0]		mem_data,	//mem_bus 		
	input	we,						//				(active low)
	input	oe,						//output enable (active low)
	input	cs,						//	Chip select (active low)

	input	clk,
	input	sys_rst_n				//Fpga internal logic
);
wire	rst;
wire	[14:0]		addr;
wire	[7:0]		wr_data,rd_data;
wire	wr_en;
ram32x8b ram32x8b_dut (
  .wr_data		(wr_data),
  .addr			(addr), 
  .wr_en		(wr_en),     
  .clk			(clk),
  .rst			(rst),
  .rd_data		(rd_data)
);
//control logic as follows
assign rst =~sys_rst_n;
assign addr =mem_addr;
assign wr_data =(we ==1'b0 && cs ==1'b0)? mem_data:'d0;
assign wr_en =~we;
assign mem_data =	(we ==1'b0 && oe ==1'b0 && cs ==1'b0)? 8'bzzzz_zzzz: 
					(we ==1'b1 && oe ==1'b0 && cs ==1'b0)? rd_data: 8'bzzzz_zzzz;

endmodule