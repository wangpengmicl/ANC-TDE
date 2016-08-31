module Smooth(
clk,
clk100m,
rst_n,
Orig_TD,
Smpr_TD
);
input clk;									//input clk
input clk100m;
input rst_n;								//rest signal
input signed [31:0]Orig_TD;			//TDE value
output reg [31:0]Smpr_TD;				//TDC value


parameter LEN=64;							//sample length
parameter L=6;								//log LEN
parameter ACCURACY=8387;				//Accuracy


reg signed [31:0]ShiftRegs[0:LEN-1];	
reg signed [39:0] Sum;						
integer i9;
integer i0;
always@(posedge clk)							
	if(!rst_n)
		begin
			Sum<=0;
			for(i9=0;i9<LEN;i9=i9+1)
				begin
						ShiftRegs[i9]<=0;
				end
		end
	else 
		begin
			Sum<=Sum+Orig_TD-ShiftRegs[0];
			ShiftRegs[LEN-1]<=Orig_TD;
			for (i0=0;i0<LEN-1;i0=i0+1)
				begin
					ShiftRegs[i0]<=ShiftRegs[i0+1];
				end
		end

reg [31:0] count_100m;						//100Mclk counter
always@(posedge clk100m)
begin
	if(!rst_n)
		count_100m<=0;
	else if(count_100m>=99)
			count_100m<=0;
	else 
		count_100m<=count_100m+1;
		
end

reg [3:0] state;
reg signed [31:0] Dlast;
reg signed [31:0] sum_ek;
reg signed [31:0] ave;						
reg signed [31:0] temp;
reg signed [31:0] abs;
integer i;
always@(posedge clk100m)
	if(!rst_n)
		begin
			state<=0;
			Smpr_TD<=0;
			Dlast<=0;
		end
	else 
		begin
		case(state)
				//=========Waiting for the next data sampling period=======///
				0:														
					begin
						if(count_100m>=99)
							begin
								state<=1;
								ave<=Sum[L+31:L];
								sum_ek<=0;
								i<=0;
							end
					end
				1:
		
					begin
						if(i<LEN)
							begin
								temp=ShiftRegs[i]-ave;
								abs=temp[31]?~temp+1:temp;
								sum_ek<=sum_ek+abs;
								i<=i+1;
							end
						else
							begin
								state<=2;
							end
						
					end
				2:

					begin
							if(sum_ek<ACCURACY)
								begin
									Dlast<=ave;
									Smpr_TD<=ave;
								end
							else
								begin
									Smpr_TD<=Dlast;
								end
							state<=0;
					end

			endcase
		end
endmodule
