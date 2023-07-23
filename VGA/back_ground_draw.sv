module	back_ground_draw	(	

					input	logic	clk,
					input	logic	resetN,
					input 	logic	[10:0]	pixelX,
					input 	logic	[10:0]	pixelY,

					output	logic	[7:0]	BG_RGB,
					output	logic		boardersDrawReq,
					output	logic		diagonalBoarderDrawReq,
					output	logic		lossDR,
					output 	logic		oneSidedBorderDR,
					output	logic		teleportDR,
					output	logic		speedVarDR,
					output	logic	[10:0]	topleftX,
					output	logic	[10:0]	topleftY,
					output 	logic		BlockDR
);

assign topleftX = pixelX - (pixelX % 32);
assign topleftY = pixelY - (pixelY % 32);

const int	xFrameSize	=	512;
const int	yFrameSize	=	384;
const int	bracketOffset =	32;

logic [2:0] redBits;
logic [2:0] greenBits;
logic [1:0] blueBits;

localparam logic [2:0] DARK_COLOR = 3'b111 ;// bitmap of a dark color
localparam logic [2:0] LIGHT_COLOR = 3'b000 ;// bitmap of a light color

localparam  int LEFT_BORDER_X  = 128 ;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;	 
	end 
	else begin

	// defaults 
		greenBits <= 3'b110 ; 
		redBits <= 3'b111 ;
		blueBits <= 2'b11;
		boardersDrawReq <= 	1'b0 ;
		diagonalBoarderDrawReq <= 1'b0;
		oneSidedBorderDR <= 1'b0;
		BlockDR <= 1'b0;
		lossDR <= 1'b0;
		teleportDR <= 1'b0;
		speedVarDR <= 1'b0;
		
		
		
		if(pixelX > 320 && pixelY > 320 && pixelX <= 352 && pixelY <= 352)	begin
			teleportDR <= 1'b1;
		end
		//Behind Hearts
			if (pixelX > 28 && pixelX < 65 && pixelY > 0 && pixelY < 125)
			begin 
				redBits <= 3'b111 ;	
				greenBits <= 3'b010;	
				blueBits <= 2'b00 ;
				boardersDrawReq <= 	1'b1;
			end
			
		else begin 
		if(pixelX > LEFT_BORDER_X && pixelX < LEFT_BORDER_X + bracketOffset && pixelY > 4*bracketOffset && pixelY < 6*bracketOffset)	begin
			greenBits <= 3'b011;
			redBits <= 3'b111;
			blueBits <= 2'b00;
			boardersDrawReq <= 	1'b1;
			speedVarDR <= 1'b1;
		end
				
		else	begin
		
			if (pixelY < bracketOffset || pixelX < bracketOffset + LEFT_BORDER_X ||
				 pixelX > xFrameSize - bracketOffset) 
			begin
				BlockDR <= 1'b1;
				//redBits <= LIGHT_COLOR;
				boardersDrawReq <= 	1'b1;
			end
			
			if(pixelY > yFrameSize - bracketOffset && pixelY < yFrameSize
																	 && (pixelX > xFrameSize - (2*bracketOffset) ||
																	 pixelX < bracketOffset + LEFT_BORDER_X))
			begin
				BlockDR <= 1'b1;
				//redBits <= LIGHT_COLOR;
				boardersDrawReq <= 	1'b1;
			end
				
			if(pixelX >= xFrameSize - (2*bracketOffset) && pixelX <= xFrameSize - bracketOffset &&
				((xFrameSize - bracketOffset - pixelX) <= (2*bracketOffset - pixelY)) &&
				pixelY <= 2*bracketOffset)
			begin
				BlockDR <= 1'b1;
				//redBits <= LIGHT_COLOR;
				diagonalBoarderDrawReq <= 1'b1;
			end
			
			if(pixelX >= xFrameSize - (3*bracketOffset) && pixelX <= xFrameSize - (2*bracketOffset) &&
				pixelY <= yFrameSize- bracketOffset && pixelY > 160)
			begin
				BlockDR <= 1'b1;
				//redBits <= LIGHT_COLOR;
				boardersDrawReq <= 	1'b1;
			end
		
			if (pixelX <  LEFT_BORDER_X || pixelX > xFrameSize) 
			begin
				BlockDR <= 1'b1;
				//redBits <= LIGHT_COLOR;
				//greenBits <= LIGHT_COLOR;
				//blueBits <= LIGHT_COLOR;
			end
			if(pixelX >= LEFT_BORDER_X + bracketOffset && pixelX <= xFrameSize - bracketOffset &&
				pixelY > 470)
				lossDR <= 1'b1;
			if(pixelX >= xFrameSize - (2*bracketOffset) && pixelX <= xFrameSize - bracketOffset &&
				pixelY == yFrameSize- bracketOffset)
				lossDR <= 1'b1;
			
			
			if(pixelX >= (LEFT_BORDER_X + xFrameSize - bracketOffset)/2 && pixelX <= (LEFT_BORDER_X + xFrameSize + bracketOffset)/2 &&
				pixelY >= yFrameSize/2 - bracketOffset && pixelY <= yFrameSize/2 + bracketOffset)	begin
				//redBits <= LIGHT_COLOR;
				boardersDrawReq <= 	1'b1;
				BlockDR <= 1'b1;
			end
				
			if(pixelX >= LEFT_BORDER_X + 2*bracketOffset && pixelX <= LEFT_BORDER_X + 3*bracketOffset &&
				pixelY >= 5*bracketOffset/2 && pixelY <= 7*bracketOffset/2 &&
				pixelX - pixelY >= LEFT_BORDER_X - bracketOffset/2) begin
				BlockDR <= 1'b1;
				//redBits <= LIGHT_COLOR;
			end
				
			if(pixelX >= LEFT_BORDER_X + 2*bracketOffset && pixelX <= LEFT_BORDER_X + 3*bracketOffset &&
				pixelY == 5*bracketOffset/2)
				boardersDrawReq <= 	1'b1;
				
			if(pixelX == LEFT_BORDER_X + 3*bracketOffset && pixelY >= 5*bracketOffset/2 &&
				pixelY <= 7*bracketOffset/2) begin
				boardersDrawReq <= 	1'b1;
				BlockDR <= 1'b1;
			end
				
			if(pixelX >= LEFT_BORDER_X + 2*bracketOffset && pixelX <= LEFT_BORDER_X + 3*bracketOffset &&
				pixelY >= 5/2*bracketOffset && pixelY <= 7/2*bracketOffset &&
				pixelX - pixelY == LEFT_BORDER_X - bracketOffset/2) begin
				diagonalBoarderDrawReq <= 	1'b1;
				BlockDR <= 1'b1;
			end
				
			if(pixelX >= xFrameSize - 11*bracketOffset/4 && pixelX <= xFrameSize - 9*bracketOffset/4 &&
				pixelY >= bracketOffset && pixelY <= 160)	begin
				oneSidedBorderDR <= 1'b1;
				//greenBits <= LIGHT_COLOR;
				BlockDR <= 1'b1;
			end
		end
		end
	BG_RGB =  {redBits , greenBits , blueBits} ; //collect color nibbles to an 8 bit word 
			


	end; 	
end 
endmodule

