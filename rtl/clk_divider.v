module clk_gen(
	input		clk,
	input		sys_rst_n,
	
	output		clk_div2,
	output		clk_div8

);

reg	[2:0]	timD;
always @(posedge clk or negedge sys_rst_n)	
	if(!sys_rst_n)
		timD <=3'b0;
	else
		timD <=timD +1'b1;

assign clk_div2 =timD[0];
assign clk_div8 =timD[2];
endmodule