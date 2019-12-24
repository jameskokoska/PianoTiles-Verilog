module Finale
	(	SW,
		CLOCK_50,						//	On Board 50 MHz
		KEY,								// On Board Keys
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,  							//	VGA Blue[9:0]
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
		PS2_CLK,
		PS2_DAT
	);
	input [9:0]SW;
	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));

		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "backdrop.mif";
	
	wire		[7:0]	ps2_key_data;
	reg [7:0] last_data_received;
	wire				ps2_key_pressed;
	inout				PS2_CLK;
	inout				PS2_DAT;

	
	PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
	);


			
	wire [2:0] colour, colourset;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	assign colourset = SW[9:7];
	wire [9:0] count;
	wire [13:0] clear_count;
	wire [9:0]seg_count;
	wire donebox, boxpos1, boxpos2, boxpos3, boxpos4, plot, countEn, clear_en, doneshift, shift_en, check_en, correct, colourred, donecheck, donegame, checkgame, colourgreen, seg_en, doneseg, segpos1,segpos2,segpos3,segpos4,segpos5,segpos6,segpos7, restart0, randorestart, restart1;
	wire timer_en;
	wire [6:0] deltax;
	wire [14:0]progress_count;
	wire doneprogress, progress_en, progresspos;
	wire [14:0]redcount;
	wire clearred;
	wire [29:0]animate_count;
	wire animate_en;
	wire increment_en;
	wire [11:0]score;
	
	
	wire inputkey1, inputkey2, inputkey3, inputkey4;
	assign inputkey1 = ~KEY[3];
	assign inputkey2 = ~KEY[2];
	assign inputkey3 = ~KEY[1];
	assign inputkey4 = ~KEY[0];
	assign writeEn = plot;
	
	reg gamemode;
	
	always @(posedge CLOCK_50) begin
	if (KEY[0] == 0) begin
		last_data_received <= 8'h00;
	end
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
	if (ps2_key_data == 8'h05)
		gamemode<=0;
	else if (ps2_key_data == 8'h06)
		gamemode<=1;
	end
	
	datapath dp(CLOCK_50, resetn, x, y, count_en, count, clear_en, clear_count, colourset, colour, donebox, boxpos1, boxpos2, boxpos3, boxpos4, shift_en, doneshift, correct, check_en, colourred, inputkey1, inputkey2, inputkey3, inputkey4, donecheck, checkgame, colourgreen, donegame, seg_en, segpos1,segpos2,segpos3,segpos4,segpos5,segpos6,segpos7, deltax, doneseg, seg_count, restart0, randorestart, last_data_received, progress_count, doneprogress, progress_en, progresspos, redcount, clearred_en, animate_count, animate_en, gamemode, increment_en, score, restart1); //datapath																																																																																																																																		 
   control con(CLOCK_50, resetn, plot, count_en, count, clear_en, clear_count, inputkey1, inputkey2, inputkey3, inputkey4, donebox, boxpos1, boxpos2, boxpos3, boxpos4, shift_en, check_en, colourred, doneshift, correct, donecheck, timer_en, donegame, checkgame, colourgreen, counterout, doneseg, seg_count, seg_en, segpos1,segpos2,segpos3,segpos4,segpos5,segpos6,segpos7,deltax, restart0, randorestart, last_data_received, ps2_key_pressed, progress_count, doneprogress, progress_en, progresspos, redcount, clearred_en, animate_count, animate_en, gamemode, increment_en, restart1, score); //control
	
	wire [26:0]q;
	wire [11:0]counterout;
	output [6:0]HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	counterRateDivider dcount(CLOCK_50,q,gamemode);
	assign enable = (q == 0)?1:0;
	
	countern ucount(CLOCK_50, enable, counterout,~restart0, ~restart1, timer_en, gamemode, last_data_received);
	seg7 display0(counterout[3:0], HEX0);	
	seg7 display1(counterout[7:4], HEX1);	
	seg7 display2(counterout[11:8], HEX2);	
	
	seg7 display3(score[3:0], HEX3);
	seg7 display4(score[7:4], HEX4);
	seg7 display5(score[11:8], HEX5);
endmodule

module counterRateDivider(clock, q, gamemode);
	input clock;
	output reg [26:0] q;
	input gamemode;
	always @(posedge clock)
		begin
			if (q == 0 && gamemode == 0)	
				q <= 27'b000010000010111100000111111;
			else if (q == 0 && gamemode == 1)
				q <= 27'b010111110101111000001111111;
			else 
				q <= q - 1;
		end
endmodule

module countern(clock, enable, q, reset0, reset1, timer_en, gamemode, key);
	parameter n=12;
	input clock, enable, reset0, reset1, timer_en, gamemode;
	input [7:0]key;
	output reg [n-1:0] q;			
	always @(posedge clock)
		begin	
			if (!reset0 && gamemode == 0) begin
				q[3:0] <= 4'b1001;
				q[7:4] <= 4'b1001;
				q[11:8] <= 4'b1001;
			end
			if (key == 8'h06) begin
				q[3:0] <= 4'b0000;
				q[7:4] <= 4'b0011;
				q[11:8] <= 4'b0000;
			end
			else if (!reset1 && gamemode == 1) begin
				q[3:0] <= 4'b0000;
				q[7:4] <= 4'b0011;
				q[11:8] <= 4'b0000;
			end

			else if (enable && timer_en) begin
				q <= q - 1;
				if (q[3:0] == 4'b0) begin
					q[3:0] <=4'b1001;
					q[7:4] <= q[7:4] - 1;
					
					if(q[7:4]==4'b0) begin
						q[7:4]<=4'b1001;
						q[11:8]<= q[11:8] - 1;
					
						if(q[11:8]==4'b0) begin
							q[11:8]<=4'b0000;
							q[7:4]<=4'b0000;
							q[3:0]<=4'b0000;
						end
					end
				end
			end
		end
endmodule


module datapath(
   input clk,
   input resetn,
   output reg [7:0] data_x, //passed to vga
	output reg [6:0] data_y,
   input count_en,
   output reg [9:0] count,
	input clear_en,
	output reg [13:0]clear_count,
	input [2:0]colourset, 
	output reg [2:0]colour,
	output reg donebox,
	input boxpos1, boxpos2, boxpos3, boxpos4,
	input shift_en,
	output reg doneshift,
	output reg correct,
	input check_en, colourred,
	input inputkey1, inputkey2, inputkey3, inputkey4,
	output reg donecheck,
	input checkgame, colourgreen,
	output reg donegame,
	input seg_en, segpos1,segpos2,segpos3,segpos4,segpos5,segpos6,segpos7,
	input [6:0]deltax,
	output reg doneseg,
	output reg [9:0]seg_count,
	input restart, randorestart,
	input [7:0]ps2_key_data,
	output reg [14:0]progress_count, 
	output reg doneprogress,
	input progress_en, progresspos,
	output reg [14:0]redcount,
	input clearred_en,
	output reg [29:0]animate_count, 
	input animate_en,
	input gamemode,
	input increment_en,
	output reg [11:0] score,
	input restart1
   );
	reg [7:0]x;
	reg [6:0]y;
	reg [121:0] queue = 120'b11010010110001011000111101001010011101001000100011010010010101100010110110000001110011010110001001001110110001000101110011;
	reg [7:0] progpos;
	//reg [99:0] queue = 100'b11001100101010011110001111011111;

	always @ (posedge clk)begin
		if(resetn==0 || restart1 || ps2_key_data == 8'h06 || ps2_key_data == 8'h05)begin
			score <= 0;
		end
		else if(increment_en && gamemode==1)begin
			score <= score + 1'b1;
		end
		else if (score[3:0]>4'b1001) begin
				score[3:0] <=4'b0;
				score[7:4] <= score[7:4] + 1;
				
				if(score[7:4]==4'b1001) begin
					score[7:4]<=4'b0;
					score[11:8]<= score[11:8] + 1;
				
					if(score[11:8]==4'b1001) begin
						score[11:8]<=4'b1001;
						score[7:4]<=4'b1001;
						score[3:0]<=4'b1001;
					end
				end
		end
	end
	
	always @ (negedge clk) begin
		if(resetn==0 || restart) begin
			queue<=122'b11010010110001011000111101001010011101001000100011010010010101100010110110000001110011010110001001001110110001000101110011;
			//queue <= 100'b11001100101010011110001111011111;
			doneshift <= 0;
		end
		else if(shift_en == 1 && gamemode == 0) begin
			queue<= {1'b0, queue[121:1]};
			doneshift <= 1;
		end
		else if(shift_en == 1 && gamemode == 1) begin
			queue<= {queue[0], queue[121:1]};
			doneshift <= 1;
		end
		else if(randorestart) begin
			queue<= {queue[0], queue[121:1]};
		end
	end
	
	//seg pos	 
	 //boxpos
	 always@(posedge clk) begin
		if(!resetn || restart) begin
			x<= 0;
			y<=0;
			progpos<=0;
			donebox<=1'b0;
			doneseg<=1'b0;
			doneprogress<=1'b0;
		end
		else if (boxpos1) begin
			y<=7'b1011001;
			if (queue[1:0] == 2'b00)
				x<=8'b00010010;
			else if (queue[1:0] == 2'b01)
				x<=8'b00110001;
			else if (queue[1:0] == 2'b10)
				x<=8'b01010001;
			else if (queue[1:0] == 2'b11)
				x<=8'b01110000;
			donebox<=1'b1;
		end
		else if (boxpos2) begin
			y<=7'b0111011;
			if (queue[3:2] == 2'b00)
				x<=8'b00010010;
			else if (queue[3:2] == 2'b01)
				x<=8'b00110001;
			else if (queue[3:2] == 2'b10)
				x<=8'b01010001;
			else if (queue[3:2] == 2'b11)
				x<=8'b01110000;
			donebox<=1'b1;
		end
		else if (boxpos3) begin
			y<=7'b0011101;
			if (queue[5:4] == 2'b00)
				x<=8'b00010010;
			else if (queue[5:4] == 2'b01)
				x<=8'b00110001;
			else if (queue[5:4] == 2'b10)
				x<=8'b01010001;
			else if (queue[5:4] == 2'b11)
				x<=8'b01110000;
			donebox<=1'b1;
		end
		else if (boxpos4) begin
			y<=7'b0;
			if (queue[7:6] == 2'b00)
				x<=8'b00010010;
			else if (queue[7:6] == 2'b01)
				x<=8'b00110001;
			else if (queue[7:6] == 2'b10)
				x<=8'b01010001;
			else if (queue[7:6] == 2'b11)
				x<=8'b01110000;
			donebox<=1'b1;
		end
		else if (segpos1 && seg_en==0) begin
			x<=8'd25 + deltax;
			y<=7'd30;
			doneseg<=1'b1;
		end
		else if (segpos2 && seg_en==0) begin
			x<=8'd46 + deltax;
			y<=7'd30;
			doneseg<=1'b1;
		end
		else if (segpos3 && seg_en==0) begin
			x<=8'd46 + deltax;
			y<=7'd60;
			doneseg<=1'b1;
		end
		else if (segpos4 && seg_en==0) begin
			x<=8'd25 + deltax;
			y<=7'd81;
			doneseg<=1'b1;
		end
		else if (segpos5 && seg_en==0) begin
			x<=8'd25 + deltax;
			y<=7'd60;
			doneseg<=1'b1;
		end
		else if (segpos6 && seg_en==0) begin
			x<=8'd25 + deltax;
			y<=7'd30;
			doneseg<=1'b1;
		end
		else if (segpos7 && seg_en==0) begin
			x<=8'd25 + deltax;
			y<=7'd55;
			doneseg<=1'b1;
		end
		else if (progresspos == 1) begin
			x<=0;
			y<=7'd119 - progpos;
			progpos <= progpos + 2'd2;
			doneprogress<=1'b1;
		end
		
		else if (clear_en) begin
			x <= 8'b00010001;
		end
	 end
	 
	 //Check
	 always @(posedge clk)begin
		if(!resetn || restart) begin
			correct<= 0;
			donecheck<=0;
		end
		else if(check_en)begin
			if (queue[1:0] == 2'b00 && ps2_key_data == 8'h15) begin
				correct <= 1'b1;
				donecheck <= 1'b1;
				end
			else if (queue[1:0] == 2'b01 && ps2_key_data == 8'h1d) begin
				correct <= 1'b1;
				donecheck <= 1'b1;
				end
			else if (queue[1:0] == 2'b10 && ps2_key_data == 8'h24) begin
				correct <= 1'b1;
				donecheck <= 1'b1;
				end
			else if (queue[1:0] == 2'b11 && ps2_key_data == 8'h2d) begin
				correct <= 1'b1;
				donecheck <= 1'b1;
				end
			else begin
				correct <= 1'b0;
				donecheck <= 1'b1;
			end
		end
	 end
	 
	 
	 always @(posedge clk) begin
		if(count_en) begin
			count <= count + 1;
		end
		else begin
			count <=0;
		end
	end
	     
	always @(posedge clk) begin
		if(clear_en) begin
			clear_count <= clear_count + 1;
		end
		else
			clear_count <= 0;
	end
	
	always @(posedge clk) begin
		if(clearred_en) begin
			redcount <= redcount + 1;
		end
		else
			redcount <= 0;
	end
	
	
	always @(posedge clk) begin
		if(seg_en) begin
			seg_count <= seg_count + 1;
		end
		else begin
			seg_count <=0;
		end
	end
	
	always @(posedge clk) begin
		if(progress_en) begin
			progress_count <= progress_count + 1;
		end
		else begin
			progress_count <=0;
		end
	end
	
	always @(posedge clk) begin
		if(animate_en) begin
			animate_count <= animate_count + 1;
		end
		else begin
			animate_count <=0;
		end
	end
			
	 always @(*) begin
			if(!resetn || restart) begin
				data_x<=8'b00000000;
				data_y<=7'b0000000;
			end
			else if(count_en) begin
				data_x <= x + {3'b0,count[4:0]};
				data_y <= y + {2'b0, count[9:5]};
			end

			else if(seg_en) begin
				if(segpos2 || segpos3 || segpos5 || segpos6) begin
					data_x <= x + {3'b0, seg_count[9:5]};
					data_y <= y + {2'b0, seg_count[4:0]};
				end
				
				else begin
					data_x <= x + {3'b0, seg_count[4:0]};
					data_y <= y + {2'b0, seg_count[9:5]};
				end
			end
			else if(progress_en)begin
				data_x <= x + progress_count[7:0];
				data_y <= y + progress_count[14:8];
			end
			else if(clear_en) begin
				data_x <= x + {1'b0, clear_count[6:0]};
				data_y <= clear_count[13:7];
			end
			else if(clearred_en) begin
				data_x <= x + redcount[7:0];
				data_y <= y + redcount[14:8];
			end
			else begin
				data_x <= 8'b0;
				data_y <= 7'b0;
			end
		end
		
		always @(negedge clk) begin
			if(!resetn || restart) begin
				donegame <= 1'b0;
			end
			else if(checkgame) begin
				if(queue==100'b0)
					donegame<=1'b1;
				else
					donegame<=1'b0;
			end
		end
		always @(*) begin
			if (colourgreen) 
				colour<=3'b010;
			else if(clear_en)
				colour<=3'b111;
			else if (colourred)
				colour<=3'b100;
			else if (count_en || seg_en)
				colour<=colourset;
			else
				colour<=3'b000;
		end
endmodule

module control(
    input clk,
    input resetn,
    output reg plot,
    output reg count_en,
	 input [9:0]count,
    output reg clear_en,
	 input [13:0]clear_count,
    input inputkey1, inputkey2, inputkey3, inputkey4, donebox,
	 output reg boxpos1, boxpos2, boxpos3, boxpos4,
	 output reg shift_en, check_en, colourred,
	 input doneshift, correct, donecheck,
	 output reg timer_en,
	 input donegame,
	 output reg checkgame, colourgreen,
	 input [11:0]counterout,
	 input doneseg,
	 input [9:0]seg_count,
	 output reg seg_en, segpos1,segpos2,segpos3,segpos4,segpos5,segpos6,segpos7,
	 output reg [6:0] deltax,
	 output reg restart0, randorestart,
	 input [7:0]ps2_key_data,
	 input ps2_key_pressed,
	 input [14:0]progress_count,
	 input doneprogress,
	 output reg progress_en,
	 output reg progresspos,
	 input [14:0]redcount,
	 output reg clearred_en,
	 input [29:0]animate_count,
	 output reg animate_en,
	 input gamemode,
	 output reg increment_en,
	 output reg restart1,
	 input [11:0]score
    );
    reg [6:0] current_state, next_state; 
	 
    
    localparam  
					 START	= 7'd0,
					 UNSTART = 7'd1,
					 CLEAR   = 7'd2,
					 BOXPOS1	= 7'd3,
					 DRAW1   = 7'd4,
					 BOXPOS2	= 7'd5,
					 DRAW2   = 7'd6,
					 BOXPOS3	= 7'd7,
					 DRAW3   = 7'd8,
					 BOXPOS4	= 7'd9,
					 DRAW4   = 7'd10,
                WAIT    = 7'd11,
					 UNWAIT  = 7'd12,
					 CHECK	= 7'd13,
					 DONECHECK = 7'd14,
					 INCORRECTPOS = 7'd15,
					 DRAWRED	=	7'd16,
					 GAMEOVER = 7'd17,
					 GREENSCREEN = 7'd18,
					 STOP		=	7'd19,
				    UNSTOP	= 	7'd20,
					 SHIFT1  = 7'd21,
					 SHIFT2  = 7'd22,
					 SEGPOS1_1 = 7'd23,
					 SEGDRAW1_1 = 7'd24,
					 SEGPOS2_1 = 7'd25,
					 SEGDRAW2_1 = 7'd26,
					 SEGPOS3_1 = 7'd27,
					 SEGDRAW3_1 = 7'd28,
					 SEGPOS4_1 = 7'd29,
					 SEGDRAW4_1 = 7'd30,
					 SEGPOS5_1 = 7'd31,
					 SEGDRAW5_1 = 7'd32,
					 SEGPOS6_1 = 7'd33,
					 SEGDRAW6_1 = 7'd34,
					 SEGPOS7_1 = 7'd35,
					 SEGDRAW7_1 = 7'd36,
					 SEGPOS1_2 = 7'd37,
					 SEGDRAW1_2 = 7'd38,
					 SEGPOS2_2 = 7'd39,
					 SEGDRAW2_2 = 7'd40,
					 SEGPOS3_2 = 7'd41,
					 SEGDRAW3_2 = 7'd42,
					 SEGPOS4_2 = 7'd43,
					 SEGDRAW4_2 = 7'd44,
					 SEGPOS5_2 = 7'd45,
					 SEGDRAW5_2 = 7'd46,
					 SEGPOS6_2 = 7'd47,
					 SEGDRAW6_2 = 7'd48,
					 SEGPOS7_2 = 7'd49,
					 SEGDRAW7_2 = 7'd50,
					 SEGPOS1_3 = 7'd51,
					 SEGDRAW1_3 = 7'd52,
					 SEGPOS2_3 = 7'd53,
					 SEGDRAW2_3 = 7'd54,
					 SEGPOS3_3 = 7'd55,
					 SEGDRAW3_3 = 7'd56,
					 SEGPOS4_3 = 7'd57,
					 SEGDRAW4_3 = 7'd58,
					 SEGPOS5_3 = 7'd59,
					 SEGDRAW5_3 = 7'd60,
					 SEGPOS6_3 = 7'd61,
					 SEGDRAW6_3 = 7'd62,
					 SEGPOS7_3 = 7'd63,
					 SEGDRAW7_3 = 7'd64,
					 KEYWAIT = 7'd65,
					 RANDOM = 7'd66,
					 PROGRESSPOS = 7'd67,
					 PROGRESSDRAW = 7'd68,
					 CLEARRED = 7'd69,
					 ANIMATE1 = 7'd70,
					 ANIMATE2 = 7'd71,
					 ANIMATE3 = 7'd72,
					 ANIMATE4 = 7'd73, 
					 ANIMATE5 = 7'd74,
					 ANIMATE6 = 7'd75,
					 ANIMATE7 = 7'd76,
					 ANIMATE8 = 7'd77,
					 ANIMATE9 = 7'd78,
					 ANIMATE10 = 7'd79,
					 ANIMATE11 = 7'd80,
					 ANIMATE12 = 7'd81,
					 ANIMATE13 = 7'd82,
					 ANIMATE14 = 7'd83,
					 ANIMATE15 = 7'd84,
					 ANIMATE16 = 7'd85,
					 ANIMATE17 = 7'd86,
					 ANIMATE18 = 7'd87,
					 ANIMATE19 = 7'd88,
					 ANIMATE20 = 7'd89,
					 ANIMATE21 = 7'd90,
					 TIMERCHECK1 = 7'd91,
					 TIMERCHECK2 = 7'd92,
					 STOP1 = 7'd93;
					 
					 


    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
				
				START: 
					next_state = (ps2_key_pressed==1) ? UNSTART : START;
				UNSTART: 
					next_state = (ps2_key_pressed==0) ? PROGRESSPOS : UNSTART;
				PROGRESSPOS:
					next_state = doneprogress ? PROGRESSDRAW : PROGRESSPOS;
				PROGRESSDRAW:
					next_state = (progress_count > 15'b000001010100000) ? CLEAR : PROGRESSDRAW;
				CLEAR: 
					next_state = (clear_count > 14'b11110001111111) ? BOXPOS1 : CLEAR;
						
				BOXPOS1:
					next_state = donebox ? DRAW1 : BOXPOS1;
				
				DRAW1: 
					next_state = (count > 10'b1111011110) ? BOXPOS2 : DRAW1;
					
				BOXPOS2:
					next_state = donebox ? DRAW2 : BOXPOS2;
				
				DRAW2: 
					next_state = (count > 10'b1111011110) ? BOXPOS3 : DRAW2;
				
				BOXPOS3:
					next_state = donebox ? DRAW3 : BOXPOS3;
				
				DRAW3: 
					next_state = (count > 10'b1111011110) ? BOXPOS4 : DRAW3;
				
				BOXPOS4:
					next_state = donebox ? DRAW4 : BOXPOS4;
				
				DRAW4: 
					next_state = (count > 10'b1111011110) ? WAIT : DRAW4;
					
				WAIT: 
					next_state = (ps2_key_pressed==1) ? UNWAIT : WAIT;
					
				UNWAIT:
						next_state = (ps2_key_pressed==0) ? CHECK : UNWAIT;
				CHECK: 
					next_state =  donecheck ? DONECHECK : CHECK;
					
				DONECHECK:
					if (gamemode==0)
						next_state = correct ? GAMEOVER : INCORRECTPOS;
					else 
						next_state = correct ? TIMERCHECK1 : INCORRECTPOS;
					
				GAMEOVER:
					next_state = donegame ? GREENSCREEN : KEYWAIT;
					
				TIMERCHECK1:
					next_state = (counterout <= 12'b0) ? GREENSCREEN : KEYWAIT;
					
				GREENSCREEN:
					next_state = (clear_count > 14'b11110001111111) ? ANIMATE1 : GREENSCREEN;
					
				ANIMATE1:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS1_1 : ANIMATE1;
				
				SEGPOS1_1:
					if (~doneseg)
						next_state = SEGPOS1_1;
					else if (gamemode==0&&(counterout[11:8]==4'd0 || counterout[11:8]==4'd2 || counterout[11:8]==4'd3 || counterout[11:8]==4'd5 || counterout[11:8]==4'd6 || counterout[11:8]==4'd7 || counterout[11:8]==4'd8 || counterout[11:8]==4'd9))
						next_state = SEGDRAW1_1;
                    else if (gamemode==1&&(score[11:8]==4'd0 || score[11:8]==4'd2 || score[11:8]==4'd3 || score[11:8]==4'd5 || score[11:8]==4'd6 || score[11:8]==4'd7 || score[11:8]==4'd8 || score[11:8]==4'd9))
						next_state = SEGDRAW1_1;
					else
						next_state = SEGPOS2_1;
				
				SEGDRAW1_1:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE2 : SEGDRAW1_1;
					
				ANIMATE2:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS2_1 : ANIMATE2;
					
				SEGPOS2_1:
					if (~doneseg)
						next_state = SEGPOS2_1;
					else if (gamemode==0&&(counterout[11:8]==4'd0 || counterout[11:8]==4'd1 || counterout[11:8]==4'd2 || counterout[11:8]==4'd3 || counterout[11:8]==4'd4 || counterout[11:8]==4'd7 || counterout[11:8]==4'd8 || counterout[11:8]==4'd9))
						next_state = SEGDRAW2_1;
                    else if (gamemode==1&&(score[11:8]==4'd0 || score[11:8]==4'd1 || score[11:8]==4'd2 || score[11:8]==4'd3 || score[11:8]==4'd4 || score[11:8]==4'd7 || score[11:8]==4'd8 || score[11:8]==4'd9))
						next_state = SEGDRAW2_1;
					else
						next_state = SEGPOS3_1;				
				
				SEGDRAW2_1:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE3 : SEGDRAW2_1;
					
				ANIMATE3:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS3_1 : ANIMATE3;
					
				SEGPOS3_1:
					if (~doneseg)
						next_state = SEGPOS3_1;
					else if (gamemode==0&&(counterout[11:8]==4'd0 || counterout[11:8]==4'd1 || counterout[11:8]==4'd3 || counterout[11:8]==4'd4 || counterout[11:8]==4'd5 || counterout[11:8]==4'd6 || counterout[11:8]==4'd7 || counterout[11:8]==4'd8 || counterout[11:8]==4'd9))
						next_state = SEGDRAW3_1;
                    else if (gamemode==1&&(score[11:8]==4'd0 || score[11:8]==4'd1 || score[11:8]==4'd3 || score[11:8]==4'd4 || score[11:8]==4'd5 || score[11:8]==4'd6 || score[11:8]==4'd7 || score[11:8]==4'd8 || score[11:8]==4'd9))
						next_state = SEGDRAW3_1;
					else
						next_state = SEGPOS4_1;				
				
				SEGDRAW3_1:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE4 : SEGDRAW3_1;
					
				ANIMATE4:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS4_1 : ANIMATE4;
					
				SEGPOS4_1:
					if (~doneseg)
						next_state = SEGPOS4_1;
					else if (gamemode==0&&(counterout[11:8]==4'd0 || counterout[11:8]==4'd2 || counterout[11:8]==4'd3 || counterout[11:8]==4'd5 || counterout[11:8]==4'd6 || counterout[11:8]==4'd8))
						next_state = SEGDRAW4_1;
                    else if (gamemode==1&&(score[11:8]==4'd0 || score[11:8]==4'd2 || score[11:8]==4'd3 || score[11:8]==4'd5 || score[11:8]==4'd6 || score[11:8]==4'd8))
						next_state = SEGDRAW4_1;
					else
						next_state = SEGPOS5_1;
				
				SEGDRAW4_1:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE5 : SEGDRAW4_1;
					
				ANIMATE5:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS5_1 : ANIMATE5;
					
				SEGPOS5_1:
					if (~doneseg)
						next_state = SEGPOS5_1;
					else if (gamemode==0&&(counterout[11:8]==4'd0 || counterout[11:8]==4'd2 || counterout[11:8]==4'd6 || counterout[11:8]==4'd8))
						next_state = SEGDRAW5_1;
                    else if (gamemode==1&&(score[11:8]==4'd0 || score[11:8]==4'd2 || score[11:8]==4'd6 || score[11:8]==4'd8))
						next_state = SEGDRAW5_1;
					else
						next_state = SEGPOS6_1;
				
				SEGDRAW5_1:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE6 : SEGDRAW5_1;
				
				ANIMATE6:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS6_1 : ANIMATE6;
					
				SEGPOS6_1:
					if (~doneseg)
						next_state = SEGPOS6_1;
					else if (gamemode==0&&(counterout[11:8]==4'd0 || counterout[11:8]==4'd4 || counterout[11:8]==4'd5 || counterout[11:8]==4'd6 || counterout[11:8]==4'd8 || counterout[11:8]==4'd9))
						next_state = SEGDRAW6_1;
                    else if (gamemode==1&&(score[11:8]==4'd0 || score[11:8]==4'd4 || score[11:8]==4'd5 || score[11:8]==4'd6 || score[11:8]==4'd8 || score[11:8]==4'd9))
						next_state = SEGDRAW6_1;
					else
						next_state = SEGPOS7_1;	
				
				SEGDRAW6_1:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE7 : SEGDRAW6_1;
				
				ANIMATE7:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS7_1 : ANIMATE7;
					
				SEGPOS7_1:
					if (~doneseg)
						next_state = SEGPOS7_1;
					else if (gamemode==0&&(counterout[11:8]==4'd2 || counterout[11:8]==4'd3 || counterout[11:8]==4'd4 || counterout[11:8]==4'd5 || counterout[11:8]==4'd6 || counterout[11:8]==4'd8 || counterout[11:8]==4'd9))
						next_state = SEGDRAW7_1;
                    else if (gamemode==1&&(score[11:8]==4'd2 || score[11:8]==4'd3 || score[11:8]==4'd4 || score[11:8]==4'd5 || score[11:8]==4'd6 || score[11:8]==4'd8 || score[11:8]==4'd9))
						next_state = SEGDRAW7_1;
					else
						next_state = ANIMATE8;	
				
				SEGDRAW7_1:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE8 : SEGDRAW7_1;
					
				ANIMATE8:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS1_2 : ANIMATE8;
						
				SEGPOS1_2:
					if (~doneseg)
						next_state = SEGPOS1_2;
					else if (gamemode==0&&(counterout[7:4]==4'd0 || counterout[7:4]==4'd2 || counterout[7:4]==4'd3 || counterout[7:4]==4'd5 || counterout[7:4]==4'd6 || counterout[7:4]==4'd7 || counterout[7:4]==4'd8 || counterout[7:4]==4'd9))
						next_state = SEGDRAW1_2;
                    else if (gamemode==1&&(score[7:4]==4'd0 || score[7:4]==4'd2 || score[7:4]==4'd3 || score[7:4]==4'd5 || score[7:4]==4'd6 || score[7:4]==4'd7 || score[7:4]==4'd8 || score[7:4]==4'd9))
						next_state = SEGDRAW1_2;
					else
						next_state = SEGPOS2_2;				
				SEGDRAW1_2:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE9 : SEGDRAW1_2;
					
				ANIMATE9:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS2_2 : ANIMATE9;
					
				SEGPOS2_2:
					if (~doneseg)
						next_state = SEGPOS2_2;
					else if (gamemode==0&&(counterout[7:4]==4'd0 || counterout[7:4]==4'd1 || counterout[7:4]==4'd2 || counterout[7:4]==4'd3 || counterout[7:4]==4'd4 || counterout[7:4]==4'd7 || counterout[7:4]==4'd8 || counterout[7:4]==4'd9))
						next_state = SEGDRAW2_2;
                    else if (gamemode==1&&(score[7:4]==4'd0 || score[7:4]==4'd1 || score[7:4]==4'd2 || score[7:4]==4'd3 || score[7:4]==4'd4 || score[7:4]==4'd7 || score[7:4]==4'd8 || score[7:4]==4'd9))
						next_state = SEGDRAW2_2;
					else
						next_state = SEGPOS3_2;				
				
				SEGDRAW2_2:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE10 : SEGDRAW2_2;
					
				ANIMATE10:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS3_2 : ANIMATE10;
					
				SEGPOS3_2:
					if (~doneseg)
						next_state = SEGPOS3_2;
					else if (gamemode==0&&(counterout[7:4]==4'd0 || counterout[7:4]==4'd1 || counterout[7:4]==4'd3 || counterout[7:4]==4'd4 || counterout[7:4]==4'd5 || counterout[7:4]==4'd6 || counterout[7:4]==4'd7 || counterout[7:4]==4'd8 || counterout[7:4]==4'd9))
						next_state = SEGDRAW3_2;
                    else if (gamemode==1&&(score[7:4]==4'd0 || score[7:4]==4'd1 || score[7:4]==4'd3 || score[7:4]==4'd4 || score[7:4]==4'd5 || score[7:4]==4'd6 || score[7:4]==4'd7 || score[7:4]==4'd8 || score[7:4]==4'd9))
						next_state = SEGDRAW3_2;
					else
						next_state = SEGPOS4_2;				
				
				SEGDRAW3_2:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE11 : SEGDRAW3_2;
					
				ANIMATE11:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS4_2 : ANIMATE11;
					
				SEGPOS4_2:
					if (~doneseg)
						next_state = SEGPOS4_2;
					else if (gamemode==0&&(counterout[7:4]==4'd0 || counterout[7:4]==4'd2 || counterout[7:4]==4'd3 || counterout[7:4]==4'd5 || counterout[7:4]==4'd6 || counterout[7:4]==4'd8))
						next_state = SEGDRAW4_2;
                    else if (gamemode==1&&(score[7:4]==4'd0 || score[7:4]==4'd2 || score[7:4]==4'd3 || score[7:4]==4'd5 || score[7:4]==4'd6 || score[7:4]==4'd8))
						next_state = SEGDRAW4_2;
					else
						next_state = SEGPOS5_2;
				
				SEGDRAW4_2:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE12 : SEGDRAW4_2;
					
				ANIMATE12:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS5_2 : ANIMATE12;
					
				SEGPOS5_2:
					if (~doneseg)
						next_state = SEGPOS5_2;
					else if (gamemode==0&&(counterout[7:4]==4'd0 || counterout[7:4]==4'd2 || counterout[7:4]==4'd6 || counterout[7:4]==4'd8))
						next_state = SEGDRAW5_2;
                    else if (gamemode==1&&(score[7:4]==4'd0 || score[7:4]==4'd2 || score[7:4]==4'd6 || score[7:4]==4'd8))
						next_state = SEGDRAW5_2;
					else
						next_state = SEGPOS6_2;
				
				SEGDRAW5_2:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE13 : SEGDRAW5_2;
					
				ANIMATE13:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS6_2 : ANIMATE13;
					
				SEGPOS6_2:
					if (~doneseg)
						next_state = SEGPOS6_2;
					else if (gamemode==0&&(counterout[7:4]==4'd0 || counterout[7:4]==4'd4 || counterout[7:4]==4'd5 || counterout[7:4]==4'd6 || counterout[7:4]==4'd8 || counterout[7:4]==4'd9))
						next_state = SEGDRAW6_2;
                    else if (gamemode==1&&(score[7:4]==4'd0 || score[7:4]==4'd4 || score[7:4]==4'd5 || score[7:4]==4'd6 || score[7:4]==4'd8 || score[7:4]==4'd9))
						next_state = SEGDRAW6_2;
					else
						next_state = SEGPOS7_2;	
				
				SEGDRAW6_2:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE14 : SEGDRAW6_2;
					
				ANIMATE14:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS7_2 : ANIMATE14;
				
				SEGPOS7_2:
					if (~doneseg)
						next_state = SEGPOS7_2;
					else if (gamemode==0&&(counterout[7:4]==4'd2 || counterout[7:4]==4'd3 || counterout[7:4]==4'd4 || counterout[7:4]==4'd5 || counterout[7:4]==4'd6 || counterout[7:4]==4'd8 || counterout[7:4]==4'd9))
						next_state = SEGDRAW7_2;
                    else if (gamemode==1&&(score[7:4]==4'd2 || score[7:4]==4'd3 || score[7:4]==4'd4 || score[7:4]==4'd5 || score[7:4]==4'd6 || score[7:4]==4'd8 || score[7:4]==4'd9))
						next_state = SEGDRAW7_2;
					else
						next_state = ANIMATE15;	
						
				SEGDRAW7_2:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE15 : SEGDRAW7_2;
					
				ANIMATE15:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS1_3 : ANIMATE15;
				
				SEGPOS1_3:
					if (~doneseg)
						next_state = SEGPOS1_3;
					else if (gamemode==0&&(counterout[3:0]==4'd0 || counterout[3:0]==4'd2 || counterout[3:0]==4'd3 || counterout[3:0]==4'd5 || counterout[3:0]==4'd6 || counterout[3:0]==4'd7 || counterout[3:0]==4'd8 || counterout[3:0]==4'd9))
						next_state = SEGDRAW1_3;
                    else if (gamemode==1&&(score[3:0]==4'd0 || score[3:0]==4'd2 || score[3:0]==4'd3 || score[3:0]==4'd5 || score[3:0]==4'd6 || score[3:0]==4'd7 || score[3:0]==4'd8 || score[3:0]==4'd9))
						next_state = SEGDRAW1_3;
					else
						next_state = SEGPOS2_3;	
						
				SEGDRAW1_3:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE16 : SEGDRAW1_3;
					
				ANIMATE16:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS2_3 : ANIMATE16;
					
				SEGPOS2_3:
					if (~doneseg)
						next_state = SEGPOS2_3;
					else if (gamemode==0&&(counterout[3:0]==4'd0 || counterout[3:0]==4'd1 || counterout[3:0]==4'd2 || counterout[3:0]==4'd3 || counterout[3:0]==4'd4 || counterout[3:0]==4'd7 || counterout[3:0]==4'd8 || counterout[3:0]==4'd9))
						next_state = SEGDRAW2_3;
                    else if (gamemode==1&&(score[3:0]==4'd0 || score[3:0]==4'd1 || score[3:0]==4'd2 || score[3:0]==4'd3 || score[3:0]==4'd4 || score[3:0]==4'd7 || score[3:0]==4'd8 || score[3:0]==4'd9))
						next_state = SEGDRAW2_3;
					else
						next_state = SEGPOS3_3;				
				
				SEGDRAW2_3:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE17 : SEGDRAW2_3;
					
				ANIMATE17:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS3_3 : ANIMATE17;
					
				SEGPOS3_3:
					if (~doneseg)
						next_state = SEGPOS3_3;
					else if (gamemode==0&&(counterout[3:0]==4'd0 || counterout[3:0]==4'd1 || counterout[3:0]==4'd3 || counterout[3:0]==4'd4 || counterout[3:0]==4'd5 || counterout[3:0]==4'd6 || counterout[3:0]==4'd7 || counterout[3:0]==4'd8 || counterout[3:0]==4'd9))
						next_state = SEGDRAW3_3;
                    else if (gamemode==1&&(score[3:0]==4'd0 || score[3:0]==4'd1 || score[3:0]==4'd3 || score[3:0]==4'd4 || score[3:0]==4'd5 || score[3:0]==4'd6 || score[3:0]==4'd7 || score[3:0]==4'd8 || score[3:0]==4'd9))
						next_state = SEGDRAW3_3;
					else
						next_state = SEGPOS4_3;				
				
				SEGDRAW3_3:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE18 : SEGDRAW3_3;
					
				ANIMATE18:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS4_3 : ANIMATE18;
					
				SEGPOS4_3:
					if (~doneseg)
						next_state = SEGPOS4_3;
					else if (gamemode==0&&(counterout[3:0]==4'd0 || counterout[3:0]==4'd2 || counterout[3:0]==4'd3 || counterout[3:0]==4'd5 || counterout[3:0]==4'd6 || counterout[3:0]==4'd8))
						next_state = SEGDRAW4_3;
                    else if (gamemode==1&&(score[3:0]==4'd0 || score[3:0]==4'd2 || score[3:0]==4'd3 || score[3:0]==4'd5 || score[3:0]==4'd6 || score[3:0]==4'd8))
						next_state = SEGDRAW4_3;
					else
						next_state = SEGPOS5_3;
				
				SEGDRAW4_3:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE19 : SEGDRAW4_3;
					
				ANIMATE19:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS5_3 : ANIMATE19;
					
				SEGPOS5_3:
					if (~doneseg)
						next_state = SEGPOS5_3;
					else if (gamemode==0&&(counterout[3:0]==4'd0 || counterout[3:0]==4'd2 || counterout[3:0]==4'd6 || counterout[3:0]==4'd8))
						next_state = SEGDRAW5_3;
                    else if (gamemode==1&&(score[3:0]==4'd0 || score[3:0]==4'd2 || score[3:0]==4'd6 || score[3:0]==4'd8))
						next_state = SEGDRAW5_3;
					else
						next_state = SEGPOS6_3;
				
				SEGDRAW5_3:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE20 : SEGDRAW5_3;
					
				ANIMATE20:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS6_3 : ANIMATE20;
					
				SEGPOS6_3:
					if (~doneseg)
						next_state = SEGPOS6_3;
					else if (gamemode==0&&(counterout[3:0]==4'd0 || counterout[3:0]==4'd4 || counterout[3:0]==4'd5 || counterout[3:0]==4'd6 || counterout[3:0]==4'd8 || counterout[3:0]==4'd9))
						next_state = SEGDRAW6_3;
                    else if (gamemode==1&&(score[3:0]==4'd0 || score[3:0]==4'd4 || score[3:0]==4'd5 || score[3:0]==4'd6 || score[3:0]==4'd8 || score[3:0]==4'd9))
					    next_state = SEGDRAW6_3;
					else
						next_state = SEGPOS7_3;	
				
				SEGDRAW6_3:
					next_state = (seg_count > 10'b0101011110) ? ANIMATE21 : SEGDRAW6_3;
				
				ANIMATE21:
					next_state = (animate_count > 30'b000000011111111111111111111111) ? SEGPOS7_3 : ANIMATE21;
				
				SEGPOS7_3:
					if (~doneseg)
						next_state = SEGPOS7_3;
					else if (gamemode==0&&(counterout[3:0]==4'd2 || counterout[3:0]==4'd3 || counterout[3:0]==4'd4 || counterout[3:0]==4'd5 || counterout[3:0]==4'd6 || counterout[3:0]==4'd8 || counterout[3:0]==4'd9))
						next_state = SEGDRAW7_3;
                    else if (gamemode==1&&(score[3:0]==4'd2 || score[3:0]==4'd3 || score[3:0]==4'd4 || score[3:0]==4'd5 || score[3:0]==4'd6 || score[3:0]==4'd8 || score[3:0]==4'd9))
						next_state = SEGDRAW7_3;
					else
						if (gamemode==0)
							next_state = STOP;
						else
							next_state = STOP1;
											
				SEGDRAW7_3:
					if (gamemode == 0)
						next_state = (seg_count > 10'b0101011110) ? STOP : SEGDRAW7_3;
					else 
						next_state = (seg_count > 10'b0101011110) ? STOP1 : SEGDRAW7_3;

				STOP1:
					next_state = (ps2_key_data==8'h12 || ps2_key_data==8'h05 || ps2_key_data==8'h06) ? START : STOP1;
					
				KEYWAIT:
					next_state =  (ps2_key_pressed==1) ? SHIFT1 : KEYWAIT;
				
				INCORRECTPOS:
				if (gamemode==0)
					next_state = donebox ? DRAWRED : INCORRECTPOS;
				else
					next_state = donebox ? TIMERCHECK2 : INCORRECTPOS;
				
				TIMERCHECK2:
					next_state = (counterout <= 12'b0) ? GREENSCREEN : DRAWRED;
				
				DRAWRED:
					next_state = (count > 10'b1111011110) ? STOP : DRAWRED;
				STOP: 
					next_state =  RANDOM;
					
				RANDOM:
					next_state = (ps2_key_data==8'h12) ? UNSTOP : RANDOM;
					
				UNSTOP: 
					next_state = (ps2_key_pressed==0) ? CLEARRED : UNSTOP;
					
				CLEARRED:
					next_state = (redcount > 15'b111100010100000) ? CLEAR : CLEARRED;
					
				SHIFT1:
					next_state = doneshift ? SHIFT2: SHIFT1;
					
				SHIFT2:
					next_state = doneshift ? START: SHIFT2;
					
            default:     next_state = START;
        endcase
    end 
   

    always @(*)
    begin: enable_signals
        count_en = 1'b0;
		  clear_en = 1'b0;
        boxpos1 = 1'b0;
		  boxpos2 = 1'b0;
		  boxpos3 = 1'b0;
		  boxpos4 = 1'b0;
		  plot = 1'b0;
		  shift_en = 1'b0;
		  check_en = 1'b0;
		  colourred = 1'b0;
		  colourgreen=1'b0;
		  checkgame=1'b0;
		  timer_en=1'b1;
		  segpos1 = 1'b0;
		  segpos2 = 1'b0;
		  segpos3 = 1'b0;
		  segpos4 = 1'b0;
		  segpos5 = 1'b0;
		  segpos6 = 1'b0;
		  segpos7 = 1'b0;
		  seg_en = 1'b0;
		  deltax = 7'b0;
		  restart0= 1'b0;
		  restart1=1'b0;
		  randorestart = 1'b0;
		  progress_en = 1'b0;
		  progresspos = 1'b0;
		  clearred_en = 1'b0;
		  animate_en = 1'b0;
		  increment_en = 1'b0;

        case (current_state)
				START: begin
					if(gamemode==0)begin
						timer_en=1'b0;
					end
				end
				UNSTART: begin
					if(gamemode==0)begin
						timer_en=1'b0;
					end
				end
				PROGRESSPOS: begin
					progresspos = 1'b1;
				end
				PROGRESSDRAW: begin
					progress_en = 1'b1;
					plot=1'b1;
					if(gamemode == 0)
						colourgreen = 1'b1;
					else
						colourred = 1'b1;
				end
            CLEAR: begin
					 clear_en = 1'b1;
					 plot = 1'b1;
            end
				BOXPOS1: begin
					 boxpos1=1'b1;
				end
				DRAW1: begin
					 count_en = 1'b1;
					 plot = 1'b1;
				end
				BOXPOS2: begin
					 boxpos2=1'b1;
				end
				DRAW2: begin
					 count_en = 1'b1;
					 plot = 1'b1;
				end
				BOXPOS3: begin
					 boxpos3=1'b1;
				end
				DRAW3: begin
					 count_en = 1'b1;
					 plot = 1'b1;
				end
				BOXPOS4: begin
					 boxpos4=1'b1;
				end
				DRAW4: begin
					 count_en = 1'b1;
					 plot = 1'b1;
				end
				WAIT: begin
				end
				CHECK: begin
					check_en = 1'b1;
				end
				DONECHECK: begin
				end
				GAMEOVER: begin
					checkgame = 1'b1;
				end
				
				GREENSCREEN: begin
					clear_en=1'b1;
					plot = 1'b1;
					colourgreen = 1'b1;
					timer_en=1'b0;
				end
				
				SEGPOS1_1: begin
					segpos1 = 1'b1;
					timer_en=1'b0;
				end
				SEGDRAW1_1: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos1 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS2_1: begin
					segpos2 = 1'b1;
					timer_en=1'b0;
				end
				SEGDRAW2_1: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos2 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS3_1: begin
					segpos3 = 1'b1;
					timer_en=1'b0;
				end
				SEGDRAW3_1: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos3 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS4_1: begin
					segpos4 = 1'b1;
					timer_en=1'b0;
				end
				SEGDRAW4_1: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos4 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS5_1: begin
					segpos5 = 1'b1;
					timer_en=1'b0;
				end
				SEGDRAW5_1: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos5 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS6_1: begin
					segpos6 = 1'b1;
					timer_en=1'b0;
				end
				SEGDRAW6_1: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos6 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS7_1: begin
					segpos7 = 1'b1;
					timer_en=1'b0;
				end
				SEGDRAW7_1: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos7 = 1'b1;
					timer_en=1'b0;
				end
				
				SEGPOS1_2: begin
					segpos1 = 1'b1;
					deltax = 7'd40;
					timer_en=1'b0;
				end
				SEGDRAW1_2: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos1 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS2_2: begin
					segpos2 = 1'b1;
					deltax = 7'd40;
					timer_en=1'b0;
				end
				SEGDRAW2_2: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos2 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS3_2: begin
					segpos3 = 1'b1;
					deltax = 7'd40;
					timer_en=1'b0;
				end
				SEGDRAW3_2: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos3 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS4_2: begin
					segpos4 = 1'b1;
					deltax = 7'd40;
					timer_en=1'b0;
				end
				SEGDRAW4_2: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos4 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS5_2: begin
					segpos5 = 1'b1;
					deltax = 7'd40;
					timer_en=1'b0;
				end
				SEGDRAW5_2: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos5 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS6_2: begin
					segpos6 = 1'b1;
					deltax = 7'd40;
					timer_en=1'b0;
				end
				SEGDRAW6_2: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos6 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS7_2: begin
					segpos7 = 1'b1;
					deltax = 7'd40;
					timer_en=1'b0;
				end
				SEGDRAW7_2: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos7 = 1'b1;
					timer_en=1'b0;
				end
				
				SEGPOS1_3: begin
					segpos1 = 1'b1;
					deltax = 7'd80;
					timer_en=1'b0;
				end
				SEGDRAW1_3: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos1 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS2_3: begin
					segpos2 = 1'b1;
					deltax = 7'd80;
					timer_en=1'b0;
				end
				SEGDRAW2_3: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos2 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS3_3: begin
					segpos3 = 1'b1;
					deltax = 7'd80;
					timer_en=1'b0;
				end
				SEGDRAW3_3: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos3 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS4_3: begin
					segpos4 = 1'b1;
					deltax = 7'd80;
					timer_en=1'b0;
				end
				SEGDRAW4_3: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos4 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS5_3: begin
					segpos5 = 1'b1;
					deltax = 7'd80;
					timer_en=1'b0;
				end
				SEGDRAW5_3: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos5 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS6_3: begin
					segpos6 = 1'b1;
					deltax = 7'd80;
					timer_en=1'b0;
				end
				SEGDRAW6_3: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos6 = 1'b1;
					timer_en=1'b0;
				end
				SEGPOS7_3: begin
					segpos7 = 1'b1;
					deltax = 7'd80;
					timer_en=1'b0;
				end
				SEGDRAW7_3: begin
					seg_en = 1'b1;
					plot = 1'b1;
					segpos7 = 1'b1;
					timer_en=1'b0;
				end
				
				ANIMATE1: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE2: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE3: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE4: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE5: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE6: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE7: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE8: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE9: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE10: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE11: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE12: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE13: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE14: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE15: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE16: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE17: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE18: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE19: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE20: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				ANIMATE21: begin
					animate_en = 1'b1;
					timer_en = 1'b0;
				end
				
				UNWAIT: begin
				end
				INCORRECTPOS: begin
					boxpos1=1'b1;
				end
				DRAWRED: begin
					count_en=1'b1;
					plot = 1'b1;
					colourred = 1'b1;
				end
				
				STOP: begin
					if(gamemode==0)begin
						restart0=1'b1;
					end
				end
				
				STOP1: begin
					timer_en=1'b0;
					restart1=1'b1;
				end
				
				CLEARRED: begin
					plot = 1'b1;
					colourred = 1'b1;
					clearred_en =1'b1;
				end
				RANDOM: begin
					if(gamemode==0)begin
						timer_en = 1'b0;
					end
					randorestart = 1'b1;
				end
				UNSTOP: begin
					timer_en = 1'b0;
					randorestart = 1'b1;

				end
				SHIFT1: begin
					shift_en = 1'b1;
				end
				
				SHIFT2: begin
					shift_en = 1'b1;
					increment_en = 1'b1;
				end

        endcase
    end
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= START;
        else
            current_state <= next_state;
    end
endmodule


module seg7(input [3:0]C, output [6:0]HEX);
	assign HEX[0] = ((~C[3] & ~C[2] & ~C[1] & C[0]) | (~C[3] & C[2] & ~C[1]  & ~C[0]) | (C[3] & ~C[2] & C[1] & C[0]) | (C[3] & C[2] & ~C[1] & C[0]));
	assign HEX[1] = ((~C[3] & C[2] & ~C[1] & C[0]) | (~C[3] & C[2] & C[1] & ~C[0]) | (C[3] & ~C[2] & C[1] & C[0]) | (C[3] & C[2] & ~C[1] & ~C[0]) | (C[3] & C[2] & C[1] & ~C[0]) | (C[3] & C[2] & C[1] & C[0]));
	assign HEX[2] = ((~C[3] & ~C[2] & C[1] & ~C[0]) | (C[3] & C[2] & ~C[1] & ~C[0]) | (C[3] & C[2] & C[1] & ~C[0]) | (C[3] & C[2] & C[1] & C[0]));
	assign HEX[3] = ((~C[3] & ~C[2] & ~C[1] & C[0]) | (~C[3] & C[2] & ~C[1] & ~C[0]) | (~C[3] & C[2] & C[1] & C[0]) | (C[3] & ~C[2] & ~C[1] & C[0]) | (C[3] & ~C[2] & C[1] & ~C[0]) | (C[3] & C[2] & C[1] & C[0]));
	assign HEX[4] = ((~C[3] & ~C[2] & ~C[1] & C[0]) | (~C[3] & ~C[2] & C[1] & C[0]) | (~C[3] & C[2] & ~C[1] & ~C[0]) | (~C[3] & C[2] & ~C[1] & C[0]) | (~C[3] & C[2] & C[1] & C[0]) | (C[3] & ~C[2] & ~C[1] & C[0]));
	assign HEX[5] = ((~C[3] & ~C[2] & ~C[1] & C[0]) | (~C[3] & ~C[2] & C[1] & ~C[0]) | (~C[3] & ~C[2] & C[1] & C[0]) | (~C[3] & C[2] & C[1] & C[0]) | (C[3] & C[2] & ~C[1] & C[0]));
	assign HEX[6] = ((~C[3] & ~C[2] & ~C[1] & ~C[0]) | (~C[3] & ~C[2] & ~C[1] & C[0]) | (~C[3] & C[2] & C[1] & C[0]) | (C[3] & C[2] & ~C[1] & ~C[0]));
endmodule

