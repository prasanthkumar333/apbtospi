//////////////////////////////////
//                              //
//   APB to SPI MASTER          //
//                              //  
//////////////////////////////////

module apb_spi_top #(
parameter ADDRWIDTH = 2'd3 ,
parameter DATAWIDTH = 4'd8 
)
(
pclk ,     // APB Clock
spi_clk,   // SPI Clock
preset_n,  // Active Low Reset
paddr,     // Address
psel,      // APB Select 
penable,   // APB Enable 
pwrite,    // Read Write signal 1-> Write 0->Read
pwdata,    // Write DATA 
pready,    // Ready from Slave 
prdata,    // Read Data from slave 
pslverr    // Transfer Failure signal 
);

input                  pclk     ;    
input                  spi_clk  ;  
input                  preset_n ;  
input [ADDRWIDTH-1:0]  paddr    ;    
input                  psel     ;      
input                  penable  ;   
input                  pwrite   ;    
input [DATAWIDTH-1:0]  pwdata   ;    
output                 pready   ;   
output [DATAWIDTH-1:0] prdata   ;    
output                 pslverr  ; 


apb_slave #(.ADDRWIDTH(ADDRWIDTH), .DATAWIDTH(DATAWIDTH))
i_apb_slave (
.pclk      (pclk           ),           
.preset_n  (preset_n       ),        
.paddr     (paddr          ),          
.pwrite    (pwrite         ),          
.psel      (psel           ),            
.penable   (penable        ),        
.pwdata    (pwdata         ),          
.prdata    (prdata         ),          
.pready    (pready         ),          
.pslverr   (pslverr        ),          
.data_rx   (w_spi_data_out ),         
.data_tx   (w_spi_data_in  )  
);

handshake_syn i_handshake_syn (
.pclk      (pclk         ),
.spi_clk   (spi_clk      ),
.preset_n  (preset_n     ),
.penable   (penable      ),
.pready    (w_rw_ack     ),
.spi_enable(w_spi_enable ),
.spi_ready (pready       )
);

spi_master #(.ADDRWIDTH(ADDRWIDTH), .DATAWIDTH(DATAWIDTH))
i_spi_master  (
 .clk     (spi_clk       ), 
 .reset_n (preset_n      ),    
 .data_in (w_spi_data_in ),  
 .address (paddr         ),     
 .enable  (w_spi_enable  ),  
 .rw_en   (pwrite        ),        
 .data_out(w_spi_data    ), 
 .rw_ack  (w_rw_ack      ), 
 .spi_clk (), // To SPI Slave
 .CS      (), // To SPI Slave
 .MISO    (), // From SPI Slave
 .MOSI    ()  // To SPI Slave
);

endmodule 
