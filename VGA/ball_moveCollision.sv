// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updaed Eyal Lev Feb 2021


module	ball_moveCollision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input	logic	start,  //change the direction in Y to up  
					input	logic	loss, 	//toggle the X direction 
					input logic collision,  //collision if smiley hits an object
					input	logic	[3:0] HitEdgeCode, //one bit per edge 
					input logic diagonalCollision,
					input logic one_sided_collision,
					input logic teleport,
					input logic [10:0] forced_x,
					input logic [10:0] forced_y,
					input logic speed_var,
					input logic [31:0] forced_speed,

					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside 
					
);

// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 392;
parameter int INITIAL_Y = 337;
parameter int MAX_Y_SPEED = 500;
const int  Y_ACCEL = -1;
const int FRICTION_COEFFICIENT = 3;

const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
// note it must be 2^n 

int Xspeed, topLeftX_FixedPoint, tempXspeed, tempX, speed; // local parameters 
int Yspeed, topLeftY_FixedPoint, tempYspeed, tempY;

int flag, flagStart;
int started;


//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin 
		started <= 0;
		flag <= 0;
		flagStart <= 0;
		
		Yspeed<= -160;
		tempYspeed <= -160;
		
		tempY <= 0;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
		
		Xspeed <= 0;
		tempXspeed <= 0;
		
		
		tempX <= 0;
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		speed <= forced_speed;
	end 
	else begin
			
			if(loss == 1'b1 && Yspeed > 0 && (Xspeed == 0 || topLeftY > 430)) begin 
				started <= 0;
				flag <= 0;
				flagStart <= 0;
				Yspeed<= -160;
				tempY <= 0;
				tempYspeed <= -160;
				topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
				Xspeed <= 0;
				tempXspeed <= 0;
				tempX <= 0;
				topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
			end 
			speed <= forced_speed;
			if(speed_var)	begin
				if(tempXspeed >= 0 && tempYspeed >= 0)	begin
					if(tempXspeed > tempYspeed)	begin
						tempYspeed <= speed * tempYspeed / tempXspeed;
						tempXspeed <= speed;
					end
					else	begin
						tempXspeed <= speed * tempXspeed / tempYspeed;
						tempYspeed <= speed;
					end
				end
				
				if(tempXspeed >= 0 && tempYspeed < 0)	begin
					if(tempXspeed > -tempYspeed)	begin
						tempYspeed <= speed * tempYspeed / tempXspeed;
						tempXspeed <= speed;
					end
					else	begin
						tempXspeed <= -speed * tempXspeed / tempYspeed;
						tempYspeed <= -speed;
					end
				end
				
				if(tempXspeed < 0 && tempYspeed >= 0)	begin
					if(-tempXspeed > tempYspeed)	begin
						tempYspeed <= -speed * tempYspeed / tempXspeed;
						tempXspeed <= -speed;
					end
					else	begin
						tempXspeed <= speed * tempXspeed / tempYspeed;
						tempYspeed <= speed;
					end
				end
				
				if(tempXspeed < 0 && tempYspeed < 0)	begin
					if(-tempXspeed > -tempYspeed)	begin
					tempYspeed <= -speed * tempYspeed / tempXspeed;
						tempXspeed <= -speed;
					end
					else	begin
						tempXspeed <= -speed * tempXspeed / tempYspeed;
						tempYspeed <= -speed;
					end
				end
			end
			
			if(teleport)	begin
				if(forced_x > 160 && forced_x < 235 && forced_y > 35 && forced_y < 110)	begin
					tempX <= forced_x + 80;
					tempY <= forced_y;
				end
				else if(forced_x > 270 && forced_x <= 340 && forced_y >= 125 && forced_y < 230)	begin
					tempX <= forced_x;
					tempY <= forced_y / 2;
				end
				else	begin
					tempX <= forced_x;
					tempY <= forced_y;
				end
			end
			
			if(diagonalCollision && (HitEdgeCode[1] == 2'b1 && HitEdgeCode[2] == 2'b1) && ((Xspeed > 0 && Xspeed > Yspeed) || (Yspeed < 0 && -Yspeed > -Xspeed)) && flag == 0)begin
				tempXspeed <= Yspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
				tempYspeed <= Xspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
				flag <= 1;
			end
			
			if(diagonalCollision && (HitEdgeCode[0] == 2'b1 && HitEdgeCode[3] == 2'b1) && ((Xspeed < 0 && -Xspeed > -Yspeed) || (Yspeed > 0 && Yspeed > Xspeed)) && flag == 0)begin
				tempXspeed <= Yspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
				tempYspeed <= Xspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
				flag <= 1;
			end
			
			if(diagonalCollision && (HitEdgeCode[2] == 2'b1 && HitEdgeCode[3] == 2'b1) && ((Xspeed < 0 && -Xspeed > Yspeed)  || (Yspeed < 0 && -Yspeed > Xspeed)) && flag == 0)begin
			tempXspeed <= -Yspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
			tempYspeed <= -Xspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
			flag <= 1;
			end
			
			if(diagonalCollision && (HitEdgeCode[1] == 2'b1 && HitEdgeCode[0] == 2'b1) && ((Xspeed > 0 && Xspeed > -Yspeed) || (Yspeed > 0 && Yspeed > -Xspeed)) && flag == 0)begin
			tempXspeed <= -Yspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
			tempYspeed <= -Xspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
			flag <= 1;
			end

			if(one_sided_collision && tempXspeed > 0)	begin
				tempXspeed <= -Xspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
				tempYspeed <= Yspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
			end
			
			if (collision && HitEdgeCode == 4'b1000 && tempXspeed < 0 && flag == 0) begin  // hit right border of brick  
				tempXspeed <= -Xspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ; 
				tempYspeed <= Yspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
			end	
			
			if (collision && HitEdgeCode == 4'b10 && tempXspeed > 0 && flag == 0) begin  // hit right border of brick  
				tempXspeed <= -Xspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;  
				tempYspeed <= Yspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
			end	
	
			if (collision && HitEdgeCode == 4'b1 && tempYspeed > 0 && flag == 0) begin
				tempYspeed <= -Yspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
				tempXspeed <= Xspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
			end	
			
			if (collision && HitEdgeCode == 4'b100 && tempYspeed < 0 && flag == 0) begin
				tempYspeed <= -Yspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
				tempXspeed <= Xspeed * (100 - (FRICTION_COEFFICIENT)) / 100  ;
			end
						
			

		// perform  position and speed integral only 30 times per second 
		
		if (startOfFrame == 1'b1) begin 
		
				if(started == 1'b0 && start == 1'b1)
					started <= 1'b1;
				else if(started == 1'b1 && start == 1'b1 && tempYspeed > -MAX_Y_SPEED && !flagStart)
					tempYspeed <= tempYspeed - 3; 
				else if(started == 1'b1) begin
					flag <= 0;
					flagStart <= 1;
					if(tempX > 0 )	begin
						topLeftX_FixedPoint <= tempX * FIXED_POINT_MULTIPLIER;
						topLeftY_FixedPoint <= tempY * FIXED_POINT_MULTIPLIER;
						tempX <= 0;
						tempY <= 0;
					end
					else begin
						topLeftX_FixedPoint  <= topLeftX_FixedPoint + tempXspeed;
						topLeftY_FixedPoint  <= topLeftY_FixedPoint + tempYspeed; // position interpolation 
					end
					
					Xspeed <= tempXspeed;
					if (tempYspeed < MAX_Y_SPEED ) //  limit the spped while going down 
							tempYspeed <= tempYspeed  - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick 
					Yspeed <= tempYspeed;
					
				end
		end
	end
end 


//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule
