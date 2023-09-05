//----------------------------------------------------------------------------------------------------------
//	FILE: 		mem_map.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	Memory address map logic for UK101
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.9.31			create
//-----------------------------------------------------------------------------------------------------------
module mem_map(
	input		[15:0]	mem_addr,
	input		cpu_clk,
	input		rd_pin,
	input		we_pin,
	
	output		sram_cs,
	output		sram_oe,
	output		sram_we,
	
	output	reg	rom_cs,
	output		rom_oe,
	
	output		uart_cs,
	output		uart_rs,
	output		uart_rd,
	output		uart_we,
	output		uart_en,
	
	output		[14:0]	base_addr
	
);
assign base_addr 	=mem_addr[14:0];
assign sram_oe 		=~rd_pin;
assign rom_oe 		=~rd_pin;
assign sram_we 		=~we_pin;
assign sram_cs 		=mem_addr[15];
assign uart_cs 		=~(mem_addr[15:12] ==8'hff && mem_addr[11] ==1'b0);
assign uart_rs 		=mem_addr[0];
assign uart_rd		=rd_pin;
assign uart_wd		=we_pin;
assign uart_en		=~cpu_clk;

always @ (*)
	casez({mem_addr[15:11]})
		5'b1111_1: rom_cs =1'b0;		//Monitor
		5'b101?_?: rom_cs =1'b0;		//Basic
		default:
			rom_cs =1'b1;
	endcase

endmodule