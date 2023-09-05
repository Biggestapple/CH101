module UK101_tb();
reg	sys_rst_n	=1'b1;
reg	sys_clk =1'b0;
wire	tx,rx;
always  #1 sys_clk <=~sys_clk;

UK101 UK101_dut(
	.sys_clk		(sys_clk),
	.sys_rst_n		(sys_rst_n),
	
	.rx				(rx),
	.tx				(tx)
);

initial begin
	#2	sys_rst_n <=1'b0; 
	#4	sys_rst_n <=1'b1;
	

#1000	$finish;
end
endmodule