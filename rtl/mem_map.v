//----------------------------------------------------------------------------------------------------------
//	FILE: 		mem_map.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	Memory address map logic for UK101
//				(0x0000 ~ 0x0fff) --?ROM (BOOT)
//				(0x1000 ~ 0x7FFF) -->RAM
//				(0xA000 ~ 0xBFFF) -->ROM (MICROSOFT BASIC)
//				(0xF000 ~ 0xF7FF)-->UART INTERFACE
//				(0xF800 ~ 0xFFFF) -->MONITOR ROM
//				OTHERS			  -->REVERSE
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.9.1			create
//								2023.9.3			rebuild 
//-----------------------------------------------------------------------------------------------------------
module mem_map(
	input		[15:0]	mem_addr,
	output	reg	[1:0]	din_sel,
	output		[14:0]	base_addr,
	
	
	output	reg	uart_cs,
	output		uart_rs,
	output	reg	sram_cs
);
always @ (*)
	casez(mem_addr[15:11])
		5'b01??_?,5'b001?_?,5'b0001_?:
				  begin
					din_sel <=2'b00;			//Select RAM
					uart_cs <=1'b0;
					sram_cs <=1'b1;
				end
		5'b101?_?,5'b1111_1,5'b0000_?:
				  begin
					din_sel <=2'b01;			//Select ROM
					uart_cs <=1'b0;
					sram_cs <=1'b0;
				end
		5'b1111_0:begin	
					din_sel <=2'b10;			//Select UART
					uart_cs <=1'b1;
					sram_cs <=1'b0;
				end
		default: begin
												//Out of memory
					din_sel <=2'b11;
					uart_cs <=1'b0;
					sram_cs <=1'b0;
		end
	endcase

assign uart_rs =mem_addr[0];					//Reference to UK101
assign base_addr =mem_addr[14:0];
endmodule