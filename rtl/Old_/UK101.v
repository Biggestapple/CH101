module UK101(
	input		sys_clk,
	input		sys_rst_n,
	
	input		rx,
	output		tx
);

wire	clk_div2;
wire	clk_div8;
wire	sys_rst;
wire	irq_in,nmi_in;
wire	[15:0]		addr_pin;
wire	[7:0]		din;
wire	[7:0]		dout;
wire	dout_oe;						//Not used
wire	we_pin,rd_pin;
wire	sync;							//Not used
wire	[7:0]		mem_data;
reg		sync_r0,sync_r1;
reg		core_rdy;

wire	sram_cs,sram_oe,sram_we;
wire	rom_cs,rom_oe;
wire	uart_cs,uart_en,uart_rd,uart_rs,uart_we;
wire	[14:0]		base_addr;

assign sys_rst =~sys_rst_n;
assign 	irq_in =1'b0,
		nmi_in =1'b0;
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

mem_map mem_map_dut(
	.mem_addr	(addr_pin +16'b1010_0000_0000_0000),
	.cpu_clk	(clk_div8),
	.rd_pin		(rd_pin),
	.we_pin		(we_pin),
	
	.sram_cs	(sram_cs),
	.sram_oe	(sram_oe),
	.sram_we	(sram_we),
	
	.rom_cs		(rom_cs),
	.rom_oe		(rom_oe),
	
	.uart_cs	(uart_cs),
	.uart_rs	(uart_rs),
	.uart_rd	(uart_rd),
	.uart_we	(uart_we),
	.uart_en	(uart_en),
	
	.base_addr	(base_addr)
	
);

rom rom32kx8b(
	.rom_addr	(base_addr),
	.rom_data	(mem_data),
	

	.oe			(rom_oe),				//output enable (active low)
	.cs			(rom_cs),				//chip select 	(active low)
	
	.clk		(clk_div2),				//Fpga internal logic
	.sys_rst_n	(sys_rst_n)
	
);
sram sram32kx8b(
	.mem_addr	(base_addr),
	.mem_data	(mem_data),				//mem_bus 		
	.we			(sram_we),				//				(active low)
	.oe			(sram_oe),				//output enable (active low)
	.cs			(sram_cs),				//	Chip select (active low)

	.clk		(clk_div2),
	.sys_rst_n	(sys_rst_n)				//Fpga internal logic
);


mc6850 mc6850_dut(
	.clk		(sys_clk),				//50mhz
	.sys_rst_n	(sys_rst_n),
	
	.mem_data	(mem_data),
	
	.uart_cs	(uart_cs),
	
	.uart_rs	(uart_rs),
	.uart_rd	(uart_rd),
	.uart_we	(uart_we),
	
	.uart_en	(uart_en),
	
	.rx			(rx),
	.tx			(tx)
);
//6502 rdy dect :(
always @(posedge sys_clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		sync_r0 <=1'b0;
		sync_r1 <=1'b0;
		core_rdy <=1'b0;
	end
	else begin
		sync_r0 <=sync;
		sync_r1 <=sync_r0;
		
		if(sync_r1 ==1'b0 && sync_r0 ==1'b1)
			core_rdy <=1'b1;
		else
			core_rdy <=core_rdy;
	end
//Internal bus logic
assign din =(core_rdy ==1'b1)? mem_data:8'b0;
assign mem_data=(rd_pin ==1'b1)? 8'bzzzz_zzzz:
				(we_pin ==1'b1)? dout :
										8'bzzzz_zzzz;
endmodule