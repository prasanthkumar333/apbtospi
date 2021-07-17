//////////////////////////////////
//                              //
//       Handshake Synchronizer //
//                              //  
//////////////////////////////////
module handshake_syn 
(
pclk,
spi_clk,
preset_n,
penable,
pready,
spi_enable,
spi_ready
);

input pclk;
input spi_clk;
input preset_n;
input penable;
input pready;
output spi_enable;
output spi_ready;

reg spi_ready_r ;
reg spi_enable_r ;  
reg penable_1 ;
reg pready_1  ;
  
  assign spi_enable =  spi_enable_r ;
  assign spi_ready  =  spi_ready_r  ;

// Enable Double Synchronizer 
always @ (posedge spi_clk or negedge preset_n )
   begin 
     if (!preset_n) 
	   begin
	     penable_1  <= 1'b0 ;
		 spi_enable_r <= 1'b0 ;
	   end
	 else
	   begin
	     penable_1  <= penable ;
		 spi_enable_r <= penable_1;
	   end
   
   end 
//  ACK Double Synchronizer 
always @ (posedge pclk or negedge preset_n )
   begin 
     if (!preset_n) 
	   begin
	     pready_1   <= 1'b0 ;
		 spi_ready_r  <= 1'b0 ;
	   end
	 else
	   begin
	     pready_1  <= pready ;
		 spi_ready_r <= pready_1;
	   end
   
   end 

endmodule 

