//////////////////////////////////////////////
//                                          //
//   APB to SPI SLAVE(Dummy for Test )      //
//                                          //  
//////////////////////////////////////////////
module spi_slave(
 spi_clk , // To SPI Slave
 CS      , // To SPI Slave
 MISO    , // From SPI Slave
 MOSI      // To SPI Slave
);
input       spi_clk ;
input [2:0] CS      ;
input       MOSI    ;
output      MISO    ;

reg [7:0] slave_data ;
reg       r_MISO     ;
  
assign  MISO = r_MISO ;
  
always @ (posedge spi_clk )
  begin 
    if(CS != 7)
     begin 
       slave_data <= 33;
      end     
    else if(CS == 7)
      begin
       r_MISO  <= slave_data[7] ; 
       slave_data <= slave_data >> 1 ;   
       slave_data[0] <= MOSI  ;           
      end
  end    
  
endmodule 