//----------------------------------------------------------------------------------------------------------
//	FILE: 		ram32x8b.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	KM62256 behavior model -- 32kx8 bit CMOS Static Ram
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.9.30			create
//-----------------------------------------------------------------------------------------------------------
module ram32x8b(
  input		[7:0]	wr_data,
  input		[14:0]	addr, 
  input		wr_en,     
  
  input		clk,
  input		rst,
  output	[7:0]	rd_data
);
reg		[7:0]	ram[0:32767];
integer index;
initial begin
	for(index =0;index <32768; index =index +1)
		ram[index] <=8'b0;
end
always @(posedge clk)
	if(rst)
		for(index =0;index <32768; index =index +1)
			ram[index] <=8'b0;
	else if(wr_en)
		ram[addr] <=wr_data;


assign rd_data =ram[addr];
endmodule