module free_6502tb();

reg			cpu_clk;
reg			mem_clk;
reg			sys_rst;
wire		irq_in,nmi_in;

wire		[15:0]		addr_pin;
wire		[7:0]		dout;
wire		dout_oe;
wire		we_pin,rd_pin;
wire		sync;
reg			[7:0]		din =8'h00;
reg			[7:0]		rom[9:0];
always #2 cpu_clk <=~cpu_clk;
always #1 mem_clk <=~mem_clk;
core_6502 core_6502_dut(
	.clk		(cpu_clk),
	.reset		(sys_rst),
	.irq_in		(irq_in),
	.nmi_in		(nmi_in),
	
	.addr_pin	(addr_pin),
	.din		(din),
	.dout		(dout),
	.dout_oe	(dout_oe),
	.we_pin		(we_pin),
	.rd_pin		(rd_pin),
	.sync		(sync)

);

assign irq_in =1'b0;
assign nmi_in =1'b0;


initial begin
	rom[0] <=8'ha9;
	rom[1] <=8'h01;
	rom[2] <=8'h8d;
	rom[3] <=8'h00;
	rom[4] <=8'h02;
	rom[5] <=8'ha9;
	rom[6] <=8'h05;
	rom[7] <=8'h8d;
	rom[8] <=8'h01;
	rom[9] <=8'h02;
end


always @(posedge mem_clk)
	if(rd_pin && addr_pin[9:0] <=10'h08)
		din <=rom[addr_pin[9:0]];
	else
		din <=din;

initial begin
	#0	cpu_clk <=1'b0;sys_rst <=1'b1;mem_clk <=1'b0;
	#8  sys_rst <=1'b0;
	
	#200 $finish;
end

endmodule