module AFIR(
clk_s,
clk_100m,
rst_n,
d_int14,
x_int14,
d_canel_out
);
input clk_s;						//sampling clock
input clk_100m;					//sys clock
input rst_n;						//reset signal
input  signed [13:0] d_int14;	//primary input 
input  [13:0] x_int14;			//reference noise input
output [13:0] d_canel_out;		//output


parameter L=4;								//filter length L;
parameter XK_DEC_LEN=13;				//x(k) fractional part length
parameter WK_DEC_LEN=11;				//w(k) fractional part length
parameter R4_DEC_LEN=13;				
parameter MUL_LEN=6;
parameter EXP_LEN=17;
parameter TOFLOAT_LEN=6;
parameter TOINT_LEN=6;
parameter ONEORZERO=0;
parameter R1=891289600;					//e(k) factor
parameter R2=3143863865;				//-/(2*delta^2)
parameter R3=1151696055;				//(2^R4_DEC_LEN*u)/(delta^3*sqrt(2*pi))

reg signed [15:0] Wn[L-1:0];			//Filter coefficient vector 
reg signed [13:0] rd;					//primary input，
reg signed [13:0] rx[L-1:0];			//reference noise input
reg signed [31:0] rek;					//e(k)


reg signed [13:0] cache_d;				//buffer
reg signed [13:0] cache_x[L-1:0];   //buffer
reg [31:0]			d_out;				//output
reg signed [31:0] r4;
reg [3:0] state;		
//==============Floating-point IP core ===================//


reg[31:0] tofloat;
wire [31:0]  tofloat_result;
IP_floatconvert	IP_floatconvert_inst1 (
	.clock ( clk_100m ),
	.dataa ( tofloat),
	.result ( tofloat_result )
	);

reg [31:0] exp_a;
wire [31:0] exp_result;
IP_exp	IP_exp_inst (
	.clock ( clk_100m ),
	.data ( exp_a),
	.result ( exp_result )
	);

reg [31:0] mul_a;
reg [31:0] mul_b;
wire [31:0] mul_result;
IP_floatmult	IP_floatmult_inst (
	.clock ( clk_100m ),
	.dataa ( mul_a ),
	.datab ( mul_b ),
	.result ( mul_result )
	);
reg[31:0] toint32;
wire [31:0]  toint32_result;
IP_fltoint32 IP_fltoint32_inst(
	.clock(clk_100m),
	.dataa(toint32),
	.result(toint32_result)
	);


//=====================Temporal Logic==================//
reg [31:0]count_100m;
always@(posedge clk_100m)			//Counter
begin
	if(!rst_n)
		count_100m<=0;
	else if(count_100m>=99)
			count_100m<=0;
	else 
		count_100m<=count_100m+1;
		
end
integer i;
reg signed [45:0] temp1;
reg signed [15:0] temp2;
reg signed [45:0] temp3;
reg signed [45:0] temp4;
always@(posedge clk_s)				//sampling
	if(!rst_n)
		begin
		rd<=0;
		for(i=0;i<L;i=i+1)
			begin
				rx[i]<=0;
			end
		end
	else 
		begin
			rd<=d_int14;
			rx[0]<=x_int14;
			for(i=1;i<L;i=i+1)
				begin
					rx[i]<=rx[i-1];
				end
		end
integer i2;
integer it;
integer p;
always@(posedge clk_100m)
	if(!rst_n)
		begin
		state<=0;
			for(i2=0;i2<L;i2=i2+1)
			begin
				Wn[i2]<=0;
			end
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
								rek<=0;
								it<=0;
								cache_d<=rd;
								for (i2=0;i2<L;i2=i2+1)
									begin
										cache_x[i2]<=rx[i2];
									end
							end
					end
				1:
				//=========x[0]w[0]+x[1]*[1]+...+x[L-1]*w[L-1]=======///
					begin
						if(it<L)
							begin
								rek<=rek+Wn[it]*cache_x[it];
								it<=it+1;
							end
						else
							begin
								//=========ek===//
								state<=state+1;
								p<=0;
								tofloat<={{19-WK_DEC_LEN{rd[13]}},rd[12:0],{WK_DEC_LEN{1'b0}}}-rek;
								d_out<={{(19-WK_DEC_LEN){rd[13]}},rd[12:0],{WK_DEC_LEN{1'b0}}}-rek;
							end
						
					end
				2:
				//======convert ek to  floating-point======//
					begin
						if(p<TOFLOAT_LEN+ONEORZERO)
							begin
								p<=p+1;
							end
						else
							begin
								state=state+1;
								mul_a<=tofloat_result;
								mul_b<=R1;
								p<=0;
							end
					end
				3:
				//======ek*R1=====//
					begin
						if(p<MUL_LEN+ONEORZERO)
							begin
								p<=p+1;
							end
						else
							begin
								state=state+1;
								rek<=mul_result;
								mul_a<=mul_result;
								mul_b<=mul_result;
								p<=0;
							end
					end
				4:
				//======ek^2======//
					begin
						if(p<MUL_LEN+ONEORZERO)
							begin
								p<=p+1;
							end
						else
							begin
								state=state+1;
								mul_a<=mul_result;
								mul_b<=R2;
								p<=0;
							end
					
					end
				5:
				//======-ek^2/2delta^2======//
					begin
						if(p<MUL_LEN+ONEORZERO)
							begin
								p<=p+1;
							end
						else
							begin
								state=state+1;
								exp_a<=mul_result;
								mul_a<=rek;
								mul_b<=R3;
								p<=0;
							end
					
					end
				6:
				//======exp(-ek^2/2delta^2) and ek*R3======//
					begin
						if(p<EXP_LEN+ONEORZERO)
							begin
								p<=p+1;
							end
						else
							begin
								state=state+1;
								mul_a<=exp_result;
								mul_b<=mul_result;
								p<=0;
							end
					end
				7:
				//======exp(-ek^2/2delta^2)*ek*R3======//
					begin
						if(p<MUL_LEN+ONEORZERO)
							begin
								p<=p+1;
							end
						else
							begin
								state=state+1;
								toint32<=mul_result;
								p<=0;
							end
					end
				8:   
				//======exp(-ek^2/2delta^2)*ek*R3 to int32 r4======//
					begin
						if(p<TOINT_LEN+ONEORZERO)
							begin
								p<=p+1;
							end
						else
							begin
								state=state+1;
								r4<=toint32_result;
								it<=0;
							end
					
					end
				9:
				//======w[k+1]=w[k]+r4*x[k]======//
					begin
						if(it<L)
							begin
								temp1=r4*cache_x[it];
								temp2=Wn[it];
								temp3={{(29-R4_DEC_LEN){temp2[15]}},temp2[14:0],{R4_DEC_LEN{1'b0}}};
								temp4=temp1+temp3;
								Wn[it]<=temp4[XK_DEC_LEN+15:XK_DEC_LEN];
								it=it+1;
							end
						else
							begin
								state<=0;
							end
					end
				10:
					begin
					
					end
				11:
					begin
					
					end
			endcase
		end
assign d_canel_out=d_out[WK_DEC_LEN+13:WK_DEC_LEN];
endmodule
