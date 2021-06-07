//////////////////////////////////
//                              //
//       APB SLAVE              //
//                              //  
//////////////////////////////////

module apb_slave #(
parameter ADDRWIDTH = 2'd3,
parameter DATAWIDTH = 4'd8 
)
(
pclk,            //Input Clock 80MHZ
preset_n,        //ACtive Low Reset
paddr,           //ADDRESS
pwrite,          //READ WRITE SIGNAL  0->READ 1->WRITE
psel,            //Select signal 
penable,         //ENable signal 
pwdata,          //Write Data 
prdata,          //Read data
pready,          //Ready from slave 
pslverr,         //Slave Error signal  
data_rx,         //data RX
data_tx          //data TX
);

input                        pclk      ;
input                        preset_n  ;
input      [ADDRWIDTH-1:0]   paddr     ;
input                        pwrite    ;
input                        psel      ;
input                        penable   ;
input      [DATAWIDTH-1 :0]  pwdata    ;
input      [DATAWIDTH-1 :0]  data_rx   ;
output reg [DATAWIDTH-1 :0]  data_tx   ;
output reg [DATAWIDTH-1 :0]  prdata    ;
output reg                   pready    ;
output reg                   pslverr   ;
            
reg    [1:0]             state ;

localparam IDLE      = 2'b00 ;
localparam W_ENABLE  = 2'b01 ;
localparam R_ENABLE  = 2'b10 ; 

always @(posedge pclk or negedge preset_n ) begin
  if (!preset_n) begin
    state  <= IDLE         ; 
    prdata <= {DATAWIDTH{1'b0}} ;
    pready <= 1'b0         ;
    end

  else begin
    case (state)
      IDLE : begin
        prdata <= {DATAWIDTH{1'b0}};
        if (psel) begin
          if (pwrite) begin
            state <= W_ENABLE;
          end
          else begin
            state <= R_ENABLE;
          end
        end
      end

      W_ENABLE : begin
        if (psel && pwrite && penable) begin
          data_tx <= pwdata ;          
        end
          state <= IDLE;
      end

      R_ENABLE : begin
        if (psel && !pwrite && penable) begin
          prdata <= data_rx  ;
        end
        state <= IDLE ;
      end
      default: begin
        state <= IDLE ;
      end
    endcase
  end
end 
endmodule 
   
   
   
   
   
   