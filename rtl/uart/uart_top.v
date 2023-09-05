//----------------------------------------------------------------------------------------------------------
//	FILE: 		uart_top.v
// 	AUTHOR:		Biggest_apple
// 	
//	ABSTRACT:	MC6850 behavior model -- Asynchronous commuincations interface adapter
// 	KEYWORDS:	fpga, basic module，signal process
// 
// 	MODIFICATION HISTORY:
//	$Log$
//			Biggest_apple 		2023.9.1			create
//								2023.9.3			rebuild 
//								2023.9.5			continue
//-----------------------------------------------------------------------------------------------------------
module mc6850(
	input		clk,			//50mhz
	input		sys_rst_n,		
	input		uart_cs,		//(active high)
	input		uart_rs,		//Register select pin (control register or state register)
	input		uart_en,		//(active high)	One_charactor sends and reads
	
	input		rd_pin,			//Indicate the register states
	input		we_pin,			
	output		[7:0]	mem_rdata,
	input		[7:0]	mem_wdata,
	
	input		uart_irq,		//Uart interrupt request
	input		rx,
	output		tx
);
localparam		BPS_NUM =16'd5208;
wire	tx_pluse;
reg		tx_pluse_d1;
wire	tx_busy;
reg		busy_r0,busy_r1;
wire	tx_done_pluse;

reg		[7:0]	tx_data_buffer;
wire	[7:0]	rx_data;
wire	rx_en;
reg		[7:0]	rx_data_buffer;
//State register 
reg		RDRF;					//Receive data full
reg		TDRE;					//Transmit data register empty
//Control register
reg		CR6,CR7;				//IRQ for tx and rx

assign tx_pluse =uart_cs &&uart_en;
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		busy_r0 <=1'b0;
		busy_r1 <=1'b0;
	end
	else begin
		busy_r0 <=tx_busy;
		busy_r1 <=busy_r0;
	end

always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n)begin
		tx_data_buffer <=8'b0;
		TDRE <=1'b1;
	end
	else if(uart_rs && uart_cs && we_pin) begin
		tx_data_buffer <=mem_wdata;
		TDRE <=1'b0;
	end
	else if(~TDRE && tx_done_pluse) begin
		TDRE <=1'b1;
		tx_data_buffer <=tx_data_buffer;
	end
	else begin
		TDRE <=TDRE;
		tx_data_buffer <=tx_data_buffer;
	end
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		RDRF <=1'b0;
		rx_data_buffer <=8'b0;
	end
	else if(uart_cs && ~RDRF && rx_en) begin
		rx_data_buffer <= rx_data;
		RDRF <=1'b1;
	end
	else if(RDRF && rd_pin) begin
		rx_data_buffer <= rx_data_buffer;
		RDRF <=1'b0;
	end
	else begin
		rx_data_buffer <= rx_data_buffer;
		RDRF <=RDRF;
	end
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n) begin
		CR6 <=1'b0;
		CR7 <=1'b0;
	end
	else if(uart_cs && ~uart_rs && we_pin) begin
		CR6 <=mem_wdata[6];
		CR7 <=mem_wdata[7];
	end
always @(posedge clk or negedge sys_rst_n)
	if(!sys_rst_n)
		tx_pluse_d1 <=1'b0;
	else
		tx_pluse_d1 <=tx_pluse;
assign tx_done_pluse =(busy_r1 && ~busy_r0);
assign uart_irq =(tx_done_pluse && CR6) || (rx_en && CR7);
assign mem_rdata =	(uart_cs ==1'b0)?8'b0:
					(uart_rs ==1'b1 && rd_pin)? rx_data_buffer:
					(uart_rs ==1'b0 && rd_pin)? {TDRE,RDRF,6'b0}:
																	8'b0;
uart_tx #(
    .BPS_NUM	(BPS_NUM)
//  设置波特率为4800时，bit位宽时钟周期个数:50MHz set 10417  40MHz set 8333
//  设置波特率为9600时，bit位宽时钟周期个数:50MHz set 5208   40MHz set 4167
//  设置波特率为115200时，bit位宽时钟周期个数:50MHz set 434  40MHz set 347 12M set 104
)
uart_tx_dut
(
   .clk			(clk),      // clock                                   时钟信号
   .tx_data		(tx_data_buffer),
   .tx_pluse	(tx_pluse_d1),
                   
   .uart_tx		(tx),     	// uart tx transmit data line              发送模块串口发送信号线
   .tx_busy		(tx_busy)  	// uart tx module work states,high is busy;发送模块忙状态指示 --Ignore
);
uart_rx #(
    .BPS_NUM    (BPS_NUM)
//  设置波特率为4800时，  bit位宽时钟周期个数:50MHz set 10417  40MHz set 8333
//  设置波特率为9600时，  bit位宽时钟周期个数:50MHz set 5208   40MHz set 4167
//  设置波特率为115200时，bit位宽时钟周期个数:50MHz set 434    40MHz set 347
)
uart_rx_dut
(
      //input ports
    .clk		(clk),
	.uart_rx	(rx),
    
      //output ports
	.rx_data	(rx_data),
    .rx_en		(rx_en),
    .rx_finish	()
);
endmodule