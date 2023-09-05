module rom_tb();
reg	sys_rst	=1'b0;
reg	sys_clk =1'b0;
reg		[14:0]		addr;
wire	[7:0]		rd_data;	
always  #1 sys_clk <=~sys_clk;
always  #4 addr <=addr +1'b1;
rom_32x8b rom_32x8b_dut(
	.clk		(sys_clk),
	.rst		(sys_rst),
	
	.addr		(addr),
	.rd_data	(rd_data)
);
initial begin
	#2	sys_rst <=1'b1; addr <=15'd8190;
	#4	sys_rst <=1'b0;
	
end
endmodule