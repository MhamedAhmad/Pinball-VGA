
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_Ball,
			input	logic	drawing_request_1,
         input	logic	drawing_request_2,//Added
			input logic	drawing_request_3, 
			input logic	drawing_request_4,
			input logic loss_drawing_request,
			input logic one_sided_border_DR,
			input logic teleportDR,
			input logic speedVarDR,
			input logic [31:0] RandomScore,
			
			
			
			output logic collision, // active in case of collision between two objects
			output logic diagonalCollision,
			output logic loss,
			output logic one_sided_collision,
			output logic teleport,
			output logic speed_var,
			output logic [2:0]countlife,
			output logic GameOver,
			output logic BallFlippCollis,
			output logic [3:0]ScoreDig1,
			output logic [3:0]ScoreDig2,
			output logic [3:0]ScoreDig3,
			output logic [3:0]ScoreDig4,
			output logic [3:0]ScoreDig5,
			output logic soundEnable,
			output logic [3:0]frequency
);

// drawing_request_Ball   -->  smiley
// drawing_request_1      -->  boarders
// drawing_request_2      -->  diagonal boarders
// drawing_request_3      -->  flipper
// drawing_request_4      -->  diagonal flipper

assign collision = (drawing_request_Ball &&  (drawing_request_1 || drawing_request_3));// normal collision
assign diagonalCollision = (	(drawing_request_2 || drawing_request_4) && drawing_request_Ball);
assign loss = (drawing_request_Ball &&  loss_drawing_request);
assign one_sided_collision = (drawing_request_Ball &&  one_sided_border_DR);
assign GameOver = (!countlife);
assign soundEnable = (count != 0);


assign BallFlippCollis = (drawing_request_Ball && (drawing_request_4 || drawing_request_3) );
assign ScoreDig1 = 0; 
assign ScoreDig2 = (Score%10);
assign ScoreDig3 = (Score/10)%10; 
assign ScoreDig4 = (Score/100)%10;
assign ScoreDig5 = (Score/1000)%10;

logic previousFlag;
logic previousFlagScore;

logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions
logic flagScore; 
logic [31:0] Score; 
logic [3:0] count;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		previousFlag <= 0;
		flagScore <= 1'b0;
		previousFlagScore <= 1'b0;
		teleport <= 1'b0 ; 
		speed_var <= 1'b0 ;
		countlife <= 3'b11;
		Score <= 0;
		count <= 7;
		frequency <= 7;
		
	end 
	else	begin
	if(startOfFrame) 
		if(count != 0)
			count <= count - 1;
	if(!GameOver) begin 

		teleport <= 1'b0 ; 
		speed_var <= 1'b0 ;
		if(startOfFrame) 
				begin flag <= 1'b0 ; // reset for next time 
						previousFlagScore <= flagScore;
						flagScore <= 1'b0;
				end 
				
			if ( (collision || diagonalCollision || one_sided_collision)  && (flag == 1'b0)) begin 
				flag	<= 1'b1; // to enter only once 
				if(!previousFlag)	begin
					count <= 3;
					frequency <= 3;
				end
			end
			if ( drawing_request_Ball && teleportDR  && (flag == 1'b0)) begin
				flag	<= 1'b1; // to enter only once 
				teleport <= 1'b1 ; 
				if(!previousFlag) begin
					count <= 5;
					frequency <= 5;
				end
			end
			if ( drawing_request_Ball && speedVarDR  && (flag == 1'b0)) begin 
				flag	<= 1'b1; // to enter only once 
				speed_var <= 1'b1 ; 
				if(!previousFlag) begin
					count <= 3;
					frequency <= 3;
				end
			end
			
			
			if (loss && flag == 1'b0)
			begin  
					flag	<= 1'b1; // to enter only once 
					countlife <= countlife -1;
					if(countlife==1'b1) begin
						count <= 10;
						frequency <= 10;
					end
					else begin
						count <=7;
						frequency <= 7;
					end
					countlife <= countlife -1;
			end 
			
			
			if (BallFlippCollis && !flagScore && !previousFlagScore) 
			begin 
					flagScore <= 1'b1; 
					if(Score < 100) begin
						if(Score + RandomScore >= 100 && countlife !=3'b11)
							countlife <= countlife + 1;
					end
					else if(Score < 300) begin
						if(Score + RandomScore >= 300 && countlife !=3'b11)
							countlife <= countlife + 1;
					end
					Score <= Score + RandomScore;
					count <= 2;
					frequency <= 2;
			end
			
			if (BallFlippCollis)
				flagScore <= 1'b1;
		end
	end 
end


endmodule
