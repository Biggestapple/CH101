module UK101(
	input		sys_clk,
	input		sys_rst_n,
	
	input		rx,
	output		tx
);

wire	clk_div2;
wire	clk_div8;
wire	uart_en;
wire	sys_rst;
wire	[1:0]		din_sel;
wire	[7:0]		dout,din;
wire	[15:0]		addr_pin;
wire	irq_in,nmi_in;
wire	dout_oe,we_pin,rd_pin;
wire	sync;
wire	uart_cs,uart_rs,sram_cs;
wire	[14:0]		base_addr;
wire	[7:0]		sram_rdata,rom_rdata,uart_rdata;
reg		cpu_rdy;
reg 	sync_r0,sync_r1;
//Pll   			---//



//Clock generator	---//
clk_gen	clk_gen_dut(
	.clk		(sys_clk),
	.sys_rst_n	(sys_rst_n),

	.clk_div2	(clk_div2),
	.clk_div8	(clk_div8)
);

//6502 core			---//
core_6502 core_6502_dut(
	.clk		(clk_div8),
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
mem_map	mem_map_dut(
	.mem_addr		(addr_pin),
	.din_sel		(din_sel),
	.base_addr		(base_addr),
	
	
	.uart_cs		(uart_cs),
	.uart_rs		(uart_rs),
	.sram_cs		(sram_cs)
);
sram sram32kx8b(
	.clk			(clk_div2),
	.sys_rst_n		(sys_rst_n),
	.mem_addr		(base_addr),
	.sram_cs		(sram_cs),		//(active high)
	
	.mem_rdata		(sram_rdata),
	.mem_wdata		(dout),
	
	.we_pin			(we_pin)		//(active high)
);

rom rom_32kx8b(
	.rom_addr		(base_addr),
	.rom_data		(rom_rdata),
	.clk			(clk_div2),		//Fpga internal logic
	.sys_rst_n		(sys_rst_n)
);

mc6850 mc6850_dut(
	.clk			(sys_clk),		//50mhz
	.sys_rst_n		(sys_rst_n),		
	.uart_cs		(uart_cs),		//(active high)
	.uart_rs		(uart_rs),		//Register select pin (control register or state register)
	.uart_en		(uart_en),		//(active high)	One_charactor sends and reads
	
	.rd_pin			(rd_pin),		//Indicate the register states
	.we_pin			(we_pin),			
	.mem_rdata		(uart_rdata),
	.mem_wdata		(dout),
	
	.uart_irq		(irq_in),		//Uart interrupt request
	.rx				(rx),
	.tx				(tx)
);
always @(posedge sys_clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		sync_r0 <=1'b0;
		sync_r1 <=1'b0;
		cpu_rdy <=1'b0;
	end
	else begin
		sync_r0 <=sync;
		sync_r1 <=sync_r0;
		
		if(~sync_r1 && sync_r0)
			cpu_rdy <=1'b1;
		else
			cpu_rdy <=cpu_rdy;
	end
assign uart_en =dout_oe;			//Noop :)
assign nmi_in =1'b0;
assign sys_rst =~sys_rst_n;
//Data MUX   ---
assign din =((din_sel ==2'b00)? sram_rdata:
			 (din_sel ==2'b01)? rom_rdata:
			 (din_sel ==2'b10)? uart_rdata:
											8'hff) &{8{cpu_rdy}};
endmodule