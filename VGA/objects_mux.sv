
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // ball 
					input		logic	ballDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] ballRGB, 
					
			//		HEARTS/LIFE
					
					input logic Heart1DrawRequest,
					input logic [7:0] Heart1RGB,
					
					
					input logic Heart2DrawRequest,
					input logic [7:0] Heart2RGB,
					
					
					input logic Heart3DrawRequest,
					input logic [7:0] Heart3RGB,
			 			  
			  
		  // background 
					input		logic	[7:0] backGroundRGB, 
					
					input logic flipperDrawingRequest,
					input logic diagonalFlipperDrawingRequest,
					input logic  [7:0] FlipperRGB,
			  
			  
			// GameOver
			
					input logic [7:0] GameOverbackRGB, 
					input logic GameOverDR,
					
			// DIGITS - SCORE
			
					input logic Dig1DrawRequest,
					input logic [7:0] Dig1RGB,
					
					input logic Dig2DrawRequest,
					input logic [7:0] Dig2RGB,
					
					input logic Dig3DrawRequest,
					input logic [7:0] Dig3RGB,
					
					input logic Dig4DrawRequest,
					input logic [7:0] Dig4RGB,
					
					input logic Dig5DrawRequest,
					input logic [7:0] Dig5RGB,
					
			// Blocks/Flipper
			
					input logic [7:0] boarderRGB, 
					input logic BlockDR,		
		
			// Teleporter
			
					input logic [7:0] TeleporterRGB, 
					input logic TeleporterDR,	
			/////////////////////	
			
				   output	logic	[7:0] RGBOut
					
					

);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		
		
		if (GameOverDR)  RGBOut <= GameOverbackRGB;
			else begin 
				if (Dig1DrawRequest) RGBOut <= Dig1RGB; 
				else if (Dig2DrawRequest) RGBOut <= Dig2RGB;
				else if (Dig3DrawRequest) RGBOut <= Dig3RGB; 
				else if (Dig4DrawRequest) RGBOut <= Dig4RGB;
				else if (Dig5DrawRequest) RGBOut <= Dig5RGB; 
			
				else if (Heart1DrawRequest) RGBOut <= Heart1RGB;
				else if (Heart2DrawRequest) RGBOut <= Heart2RGB;
				else if (Heart3DrawRequest) RGBOut <= Heart3RGB;
		
				else if (ballDrawingRequest == 1'b1 )   
					RGBOut <= ballRGB;  //first priority 
		 
					else if(flipperDrawingRequest == 1'b1 || diagonalFlipperDrawingRequest == 1'b1)
						RGBOut <= (boarderRGB == 8'h00) ? 8'h00 : 8'h6f;
							
						else if(BlockDR)
							RGBOut <= boarderRGB ;
							else if(TeleporterDR && TeleporterRGB != 8'hdb)
								RGBOut <= TeleporterRGB;
							
							else
								RGBOut <= backGroundRGB;
		end
	end
end
	
	

endmodule


