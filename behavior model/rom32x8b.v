//----------------------------------------------------------------------------------------------------------
//	FILE: 		rom_32x8b.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	St27256 behavior model 32kx8 bit PROM
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.9.31			create
//-----------------------------------------------------------------------------------------------------------
module rom_32x8b(
	input		clk,
	input		rst,
	
	input		[14:0]	addr,
	output		[7:0]	rd_data
);
integer	fd ,index;
integer	err;
reg	[7:0]		bin_buffer;
reg	[320:0]		str;
reg	[7:0]		rom [0 :32767];
reg	[14:0]		addr_buffer;
initial begin
	#2;						//Rom initial
	fd =$fopen("E:\\MicroUK101\\behavior model\\allRom.bin","r");
	$write("Read bin :");
	err =$ferror(fd, str);	//Not "<="
	if(!err) begin
		for(index =0;index <32768; index =index +1) begin
				bin_buffer =$fgetc(fd);
				rom[index] =bin_buffer;
				$write("%h" ,bin_buffer);
			end
		$write("\n Done.\n");
	end
	else
		$write("Fatal Error.-1");
		
	$fclose(fd);
end
always @(posedge clk)
	if(rst)
		addr_buffer <=15'b0;
	else
		addr_buffer <=addr;

assign rd_data =rom[addr_buffer];
endmodule