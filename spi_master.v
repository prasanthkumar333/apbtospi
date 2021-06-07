//////////////////////////////////
//                              //
//       SPI MASTER             //
//                              //  
//////////////////////////////////

module spi_master #(
parameter ADDRWIDTH = 2'd3 ,
parameter DATAWIDTH = 4'd8 
)
(
 reset_n ,     
 clk     ,      
 data_in ,  
 address ,     
 enable  ,  
 rw_en   ,
 rw_ack  , 
 data_out,   
 spi_clk ,
 CS      ,
 MISO    ,
 MOSI    
);

input                        reset_n ;     
input                        clk     ;      
input      [DATAWIDTH-1 :0]  data_in ;  
input      [ADDRWIDTH-1:0]   address ;     
input                        enable  ;  
input                        rw_en   ;        
output reg [DATAWIDTH-1:0]   data_out;   
output                       spi_clk ;
output     [ADDRWIDTH-1:0]   CS      ;
input                        MISO    ;
output reg                   MOSI    ;
output reg                   rw_ack  ;

reg [2:0]             counter;
reg                   clk_enable;
reg                   state;
reg  [ADDRWIDTH-1:0]  ss;
reg  [DATAWIDTH-1 :0] send_data;
localparam IDLE      = 2'b00 ;
localparam WRITE_EN  = 2'b01 ;
localparam READ_EN   = 2'b10 ; 

// ADDRESS DECODER 
generate
  genvar i;
  for (i = 0; i < ADDRWIDTH -1 ; i = i + 1)
        begin
           assign CS[i] = address == i ? 1 : 0 ;
        end
endgenerate 

//Clock enable
  assign spi_clk  = clk & clk_enable ;

always @ (posedge clk or negedge reset_n )
  begin
   if(!reset_n) begin
     MOSI <= 1'b0 ;
     data_out <= {DATAWIDTH{1'b0}} ;
	 counter  <= 3'b000;
	 rw_ack   <= 1'b0 ;
	 clk_enable <= 1'b0 ;
   end
  else begin 
  case (state) 
   IDLE :  begin
        data_out <= {DATAWIDTH{1'b0}};
		MOSI     <= 1'b0 ;
		rw_ack   <= 1'b0 ;
        if (enable) begin
		  if (rw_en) begin 
            state <= WRITE_EN ;
			counter <= 3'd7;
			send_data <= data_in ;
			ss        <= address ;
          end
          else if (!rw_en)begin
            state <= READ_EN;
		   end
		   else begin 
             state <= IDLE ;
           end		   
		   
        end
       end
   WRITE_EN : begin
         if(counter == 3'b000)
		   begin
		    MOSI       <= 1'b0 ;
			rw_ack     <= 1'b1 ;
			clk_enable <= 1'b0 ;
		   end 
		 else 
		   begin 
		     MOSI         <= send_data[7]   ; 
       		 send_data    <= send_data << 1 ;
			 send_data[0] <= MISO           ;
			 counter      <= counter - 1    ;
			 clk_enable   <= 1'b1           ;
		   end
		   end
			
   READ_EN : begin
        data_out <= send_data ;
		rw_ack  <= 1;
		   end			
	default :  begin
        state <= IDLE ;
      end
    endcase	
    end
    end
 endmodule

