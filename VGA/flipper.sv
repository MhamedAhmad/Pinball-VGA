
module	flipper	(	
 
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0]	pixelX,
					input logic	[10:0]	pixelY,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input	logic	inwards_move,  //change the direction in Y to up  
					input	logic	outside_move, 	//toggle the X direction 
					input logic [3:0]ScoreDig4,
					
					output	logic	[7:0]	Flipper_RGB,
					output	logic		flipperDrawReq,
					output	logic		diagonalFlipperDrawReq
					
);

// a module used to generate the  ball trajectory.  

const int center = 320;
int height;
int width;
assign height =(ScoreDig4 < 3) ? ((ScoreDig4 == 0) ? 16 : 12 ) : 8;
assign width = (ScoreDig4 < 3) ? ((ScoreDig4 == 0) ? 64 : 48 ) : 32;
const int gap = 4;
int  speed;
const int	xFrameSize	=	512;
const int	yFrameSize	=	384;
const int	bracketOffset =	32;
const int LEFT_BORDER_X  = 128 ;
int distance; 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		distance<= 0;
		speed <= 0;
	end
	else begin
	
			if (inwards_move)  
				speed <= -3;
			
			else if(outside_move)
				speed <= 3;
			else
				speed <= 0;
									

		// perform  position and speed integral only 30 times per second 
		
		if (startOfFrame == 1'b1) begin 
					
					if (distance + speed < (xFrameSize - LEFT_BORDER_X) / 2 - bracketOffset - width &&
						 distance + speed > (xFrameSize - LEFT_BORDER_X) / -2 + bracketOffset) //  limit the spped while going down 
							distance <= distance  + speed ; // deAccelerate : slow the speed down every clock tick 
			
		end
	end
end 

always_comb 
begin
	flipperDrawReq <= 	1'b0 ;
	diagonalFlipperDrawReq <= 1'b0;
	Flipper_RGB = 8'b00011100;
	
	if(pixelY >= yFrameSize + gap && pixelY < yFrameSize + gap + height && pixelX < center - distance - width/4 &&
		pixelX > center - distance - 3*width/4)	
			flipperDrawReq <= 1'b1;
	
	if(pixelY >= yFrameSize + 2*gap + height && pixelY < yFrameSize + 2*gap + 2*height 
		&& pixelX < center + distance + 3*width/4 && pixelX >= center + distance + width/4)	
			flipperDrawReq <= 1'b1;	
			
	if(pixelY >= yFrameSize + gap && pixelY < yFrameSize + gap + height && pixelX <= center - distance &&
		pixelX >= center - distance - width/4 && pixelY-pixelX + 100 >= yFrameSize + gap + height - center + distance + 100)	
			diagonalFlipperDrawReq <= 1'b1;
			
	if(pixelY >= yFrameSize + gap && pixelY < yFrameSize + gap + height && pixelX <= center - distance - 3*width/4 &&
		pixelX >= center - distance - width && pixelX+pixelY >= center + yFrameSize - distance - width + gap + height)	
			diagonalFlipperDrawReq <= 1'b1;
			
	if(pixelY >= yFrameSize + 2*gap + height && pixelY < yFrameSize + 2*gap + 2*height 
		&& pixelX <= center + distance + width/4 && pixelX >= center + distance &&
		pixelY+pixelX >= center + yFrameSize + distance + 2*gap + 2*height)	
			diagonalFlipperDrawReq <= 1'b1;
			
	if(pixelY >= yFrameSize + 2*gap + height && pixelY < yFrameSize + 2*gap + 2*height 
		&& pixelX >= center + distance + 3*width/4 && pixelX <= center + distance + width &&
		pixelY-pixelX + 100 >= yFrameSize + 2*gap + 2*height - center - distance - width + 100)	
			diagonalFlipperDrawReq <= 1'b1;
end



endmodule
