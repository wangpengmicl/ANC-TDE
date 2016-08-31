module TDEA(
clk,
clk100m,
rst_n,
Se_int14,
Sh_int14,
Start,
TD,
x_int14,
Valid,
Update
);
input clk;						//input clock
input clk100m;
input rst_n;					//reset signal
input [13:0] Se_int14;		//primary input 
input [13:0] Sh_int14;		//reference input 
input Start;					

output [13:0] x_int14;		//delayed reference input 
output reg [31:0] TD;		//TDE values 
output reg Valid;				//Calculation is complete
output reg Update;			//delay update flag
//======================Data constants============================//
parameter SAM_SIZE = 64+1;				//sample size 
parameter TABLE_SIZE = 80;				//table size
parameter P=(SAM_SIZE-1)/2;			//P
parameter FACTOR1=857735168;			// convert the signed numbers ek into float
parameter FACTOR2=2789736448;			//convert the signed numbers ek^2 into float
parameter FACTOR3=862978048;			//convert the signed numbers sumfv into float
parameter FACTOR4=3392656677;			// -0.1125395404862*2^23
parameter TD0=0;							


//======================Variable definitions============================//
reg [31:0] count_100m;			//100Mclk counter

integer  j;							//Loop variable
reg [46:0] TD_int_dec;					//TD integer and fractional parts
wire [23:0] TD_integer;					//TD integer part,1.5->1,-1.5->1
wire [22:0] TD_decimal;					//TD fractional part，1.5->0.5,-1.5->0.5
wire [22:0] decimal_temp;	
wire [22:0]	subdecimal=(~decimal_temp[22:0]+1);	
assign {TD_integer[23:0],decimal_temp[22:0]}={TD_int_dec[46:0]};						//TD integer and fractional parts
assign TD_decimal=(TD[31]?subdecimal:decimal_temp);										//lookup table addresses 3-11 bit
wire [31:0] TD_integer_32={8'h00,TD_integer[23:0]};										//Extended to 32-bit unsigned
wire [31:0] wire_j=j;																				//j的值
wire [31:0] j_TDint=(TD[31]?wire_j+TD_integer_32:wire_j-TD_integer_32);				//the value of j-D		
reg [11:0] rom_address;					//lookup table addresses
reg [3:0]  rj_TDint;
reg [13:0] rSe_int14[0:SAM_SIZE-1];	//
reg [13:0] rSh_int14[0:SAM_SIZE-1];	//
reg [15:0] sincs[0:TABLE_SIZE-1];	//sinc(-32-D),sinc(-31-D)...sinc(-D)...sinc(32-D)
reg [15:0] fvs[0:TABLE_SIZE-1];		//fv(j-D)


reg [31:0] rsincse[0:SAM_SIZE-1];	//65 sinc*Se 
reg [31:0] rfvse[0:SAM_SIZE-1];		//65 fv*Se 

reg [31:0] rsumsinc;						//sum of x(k-j)*sinc(j-D) 
reg [31:0] rek;						//e(k)
reg [63:0] rek2;							//ek^2
reg [31:0] rsumfv;					//x(k-j)*f(j-D)
																								
wire [255:0] sinc;					//sinc
wire [255:0] fv;						//fv
wire [31:0]	sincse[0:SAM_SIZE-1];//sinc(j-D)*x(k-j),j from-32 to 32
wire [31:0] fvse[0:SAM_SIZE-1];	//f(j-D)*x(k-j)，j from-32 to 32
wire [31:0] sumsinc;					//sum of x(k-j)*sinc(j-D)
wire [31:0] ek;						//ek
wire [31:0] sumfv;					//sum of x(k-j)*f(j-D)

wire [31:0] result_flmult1;
wire [31:0] result_flmult2;
wire [31:0] result_flmult3;
wire [31:0] result_flmult4;
wire [31:0] result_flmult5;
wire [31:0] result_flmult6;
wire [31:0] result_exp;	
wire [31:0] result_int_DD;
reg  [31:0] cache_DD;
wire [31:0] TD1;

reg [31:0] shift_resultmult [5:0];
reg [31:0] shift_exp;
wire [63:0] ek2_int64;			//ek^2
wire [31:0] result_r1;
wire [31:0] result_r2;
wire [31:0] result_r3;

//===============================================//

always@(posedge clk100m)
begin
	if(!rst_n)
		count_100m<=0;
	else if(count_100m>=99)
			count_100m<=0;
	else 
		count_100m<=count_100m+1;
		
end
integer i9;
integer i0;
always@(posedge clk)			
	if(!rst_n)
		begin
			for(i9=0;i9<SAM_SIZE;i9=i9+1)
				begin
					rSe_int14[i9]<=0;
					rSh_int14[i9]<=0;
				end
		end
	else 
		begin
			//=====================//
			rSe_int14[SAM_SIZE-1]<=Se_int14;
			rSh_int14[SAM_SIZE-1]<=Sh_int14;
			for(i0=0;i0<SAM_SIZE-1;i0=i0+1)
				begin
					rSe_int14[i0]<=rSe_int14[i0+1];
					rSh_int14[i0]<=rSh_int14[i0+1];
				end
		end
		
reg [15:0]state;
reg [255:0] sinc0;
reg [255:0] sinc1;
reg [255:0] sinc2;
reg [255:0] sinc3;
reg [255:0] sinc4;
reg [255:0] fv0;
reg [255:0] fv1;
reg [255:0] fv2;
reg [255:0] fv3;
reg [255:0] fv4;
integer i1;


always@(posedge clk100m)
	if(!rst_n)
		begin		//initialization
		TD_int_dec<=0;
		TD<=TD0;
		Valid<=0;
		Update<=0;
		i1<=0;
		state<=0;
		rom_address<=0;
		end
	else 
		begin	
			case(state)
			0:
				begin
					if(count_100m>=99)
						begin
							state<=1;
							Update<=0;
						end
				end
			1:
				begin
					j<=(TD[31]?33:32);						//The initial value of j
					TD_int_dec<=Getflintdec(TD[31:0]);	//
					state<=state+1;
				end
			2:
				begin
					rom_address<={TD_decimal[22:14],j_TDint[6:4]};
					rj_TDint<=j_TDint[3:0];
					state<=state+1;
				end

			3:
				begin
					rom_address<=rom_address+1;
					state<=state+1;
				end
			4:
				begin
					rom_address<=rom_address+1;
					state<=state+1;
						sinc0=sinc;
						fv0=fv;
						sincs[0]<=sinc0[15:0];	
						sincs[1]<=sinc0[31:16];
						sincs[2]<=sinc0[47:32];
						sincs[3]<=sinc0[63:48];
						sincs[4]<=sinc0[79:64];
						sincs[5]<=sinc0[95:80];
						sincs[6]<=sinc0[111:96];
						sincs[7]<=sinc0[127:112];
						sincs[8]<=sinc0[143:128];
						sincs[9]<=sinc0[159:144];
						sincs[10]<=sinc0[175:160];
						sincs[11]<=sinc0[191:176];
						sincs[12]<=sinc0[207:192];
						sincs[13]<=sinc0[223:208];
						sincs[14]<=sinc0[239:224];
						sincs[15]<=sinc0[255:240];
						fvs[0]<=fv0[15:0];
						fvs[1]<=fv0[31:16];
						fvs[2]<=fv0[47:32];
						fvs[3]<=fv0[63:48];
						fvs[4]<=fv0[79:64];
						fvs[5]<=fv0[95:80];
						fvs[6]<=fv0[111:96];
						fvs[7]<=fv0[127:112];
						fvs[8]<=fv0[143:128];
						fvs[9]<=fv0[159:144];
						fvs[10]<=fv0[175:160];
						fvs[11]<=fv0[191:176];
						fvs[12]<=fv0[207:192];
						fvs[13]<=fv0[223:208];
						fvs[14]<=fv0[239:224];
						fvs[15]<=fv0[255:240];
						
				end
			5:
				begin
					rom_address<=rom_address+1;
						state<=state+1;
						sinc1=sinc;
						fv1=fv;
						sincs[16]<=sinc1[15:0];
						sincs[17]<=sinc1[31:16];
						sincs[18]<=sinc1[47:32];
						sincs[19]<=sinc1[63:48];
						sincs[20]<=sinc1[79:64];
						sincs[21]<=sinc1[95:80];
						sincs[22]<=sinc1[111:96];
						sincs[23]<=sinc1[127:112];
						sincs[24]<=sinc1[143:128];
						sincs[25]<=sinc1[159:144];
						sincs[26]<=sinc1[175:160];
						sincs[27]<=sinc1[191:176];
						sincs[28]<=sinc1[207:192];
						sincs[29]<=sinc1[223:208];
						sincs[30]<=sinc1[239:224];
						sincs[31]<=sinc1[255:240];
						fvs[16]<=fv1[15:0];
						fvs[17]<=fv1[31:16];
						fvs[18]<=fv1[47:32];
						fvs[19]<=fv1[63:48];
						fvs[20]<=fv1[79:64];
						fvs[21]<=fv1[95:80];
						fvs[22]<=fv1[111:96];
						fvs[23]<=fv1[127:112];
						fvs[24]<=fv1[143:128];
						fvs[25]<=fv1[159:144];
						fvs[26]<=fv1[175:160];
						fvs[27]<=fv1[191:176];
						fvs[28]<=fv1[207:192];
						fvs[29]<=fv1[223:208];
						fvs[30]<=fv1[239:224];
						fvs[31]<=fv1[255:240];
				end
			6:
				begin
					rom_address<=rom_address+1;
					state<=state+1;
						sinc2=sinc;
						fv2=fv;
						sincs[32]<=sinc2[15:0];
						sincs[33]<=sinc2[31:16];
						sincs[34]<=sinc2[47:32];
						sincs[35]<=sinc2[63:48];
						sincs[36]<=sinc2[79:64];
						sincs[37]<=sinc2[95:80];
						sincs[38]<=sinc2[111:96];
						sincs[39]<=sinc2[127:112];
						sincs[40]<=sinc2[143:128];
						sincs[41]<=sinc2[159:144];
						sincs[42]<=sinc2[175:160];
						sincs[43]<=sinc2[191:176];
						sincs[44]<=sinc2[207:192];
						sincs[45]<=sinc2[223:208];
						sincs[46]<=sinc2[239:224];
						sincs[47]<=sinc2[255:240];
						fvs[32]<=fv2[15:0];
						fvs[33]<=fv2[31:16];
						fvs[34]<=fv2[47:32];
						fvs[35]<=fv2[63:48];
						fvs[36]<=fv2[79:64];
						fvs[37]<=fv2[95:80];
						fvs[38]<=fv2[111:96];
						fvs[39]<=fv2[127:112];
						fvs[40]<=fv2[143:128];
						fvs[41]<=fv2[159:144];
						fvs[42]<=fv2[175:160];
						fvs[43]<=fv2[191:176];
						fvs[44]<=fv2[207:192];
						fvs[45]<=fv2[223:208];
						fvs[46]<=fv2[239:224];
						fvs[47]<=fv2[255:240];
				end
			7:
				begin
						state<=state+1;
						sinc3=sinc;
						fv3=fv;
						sincs[48]<=sinc3[15:0];
						sincs[49]<=sinc3[31:16];
						sincs[50]<=sinc3[47:32];
						sincs[51]<=sinc3[63:48];
						sincs[52]<=sinc3[79:64];
						sincs[53]<=sinc3[95:80];
						sincs[54]<=sinc3[111:96];
						sincs[55]<=sinc3[127:112];
						sincs[56]<=sinc3[143:128];
						sincs[57]<=sinc3[159:144];
						sincs[58]<=sinc3[175:160];
						sincs[59]<=sinc3[191:176];
						sincs[60]<=sinc3[207:192];
						sincs[61]<=sinc3[223:208];
						sincs[62]<=sinc3[239:224];
						sincs[63]<=sinc3[255:240];
						fvs[48]<=fv3[15:0];
						fvs[49]<=fv3[31:16];
						fvs[50]<=fv3[47:32];
						fvs[51]<=fv3[63:48];
						fvs[52]<=fv3[79:64];
						fvs[53]<=fv3[95:80];
						fvs[54]<=fv3[111:96];
						fvs[55]<=fv3[127:112];
						fvs[56]<=fv3[143:128];
						fvs[57]<=fv3[159:144];
						fvs[58]<=fv3[175:160];
						fvs[59]<=fv3[191:176];
						fvs[60]<=fv3[207:192];
						fvs[61]<=fv3[223:208];
						fvs[62]<=fv3[239:224];
						fvs[63]<=fv3[255:240];
				end
			8:
				begin
					state<=state+1;
						sinc4=sinc;
						fv4=fv;
						sincs[64]<=sinc4[15:0];
						sincs[65]<=sinc4[31:16];
						sincs[66]<=sinc4[47:32];
						sincs[67]<=sinc4[63:48];
						sincs[68]<=sinc4[79:64];
						sincs[69]<=sinc4[95:80];
						sincs[70]<=sinc4[111:96];
						sincs[71]<=sinc4[127:112];
						sincs[72]<=sinc4[143:128];
						sincs[73]<=sinc4[159:144];
						sincs[74]<=sinc4[175:160];
						sincs[75]<=sinc4[191:176];
						sincs[76]<=sinc4[207:192];
						sincs[77]<=sinc4[223:208];
						sincs[78]<=sinc4[239:224];
						sincs[79]<=sinc4[255:240];
						fvs[64]<=fv4[15:0];
						fvs[65]<=fv4[31:16];
						fvs[66]<=fv4[47:32];
						fvs[67]<=fv4[63:48];
						fvs[68]<=fv4[79:64];
						fvs[69]<=fv4[95:80];
						fvs[70]<=fv4[111:96];
						fvs[71]<=fv4[127:112];
						fvs[72]<=fv4[143:128];
						fvs[73]<=fv4[159:144];
						fvs[74]<=fv4[175:160];
						fvs[75]<=fv4[191:176];
						fvs[76]<=fv4[207:192];
						fvs[77]<=fv4[223:208];
						fvs[78]<=fv4[239:224];
						fvs[79]<=fv4[255:240];
				end
			9:	
				begin
					for(i1=0;i1<65;i1=i1+1)
					begin
						rsincse[i1]<=sincse[i1];
						rfvse[i1]<=fvse[i1];
					end
					state<=state+1;
				end
			10:
				begin
					rsumsinc<=sumsinc;
					rsumfv<=sumfv;
					state<=state+1;
				end
			11:
				begin
					rek<=ek;
					state<=state+1;
				end
			12:
				begin
					rek2<=ek2_int64;
					state<=state+1;
					i1<=0;
				end
			13:
				begin
					if(i1<=45)
					begin
						i1<=i1+1;
						shift_resultmult[0]<=result_flmult5;
						shift_resultmult[1]<=shift_resultmult[0];
						shift_resultmult[2]<=shift_resultmult[1];
						shift_resultmult[3]<=shift_resultmult[2];
						shift_resultmult[4]<=shift_resultmult[3];
						shift_resultmult[5]<=shift_resultmult[4];
						shift_exp<=result_exp;
					end
					else 
						state<=state+1;
						
				end
			14:
				begin
					cache_DD<=result_int_DD;
					state<=state+1;
					Update<=1;
				end
			15:
				begin
					if(TD[31])
						TD<=0;
					else 
						TD<=TD1;
					Valid<=1;
					Update<=0;
					state<=0;
				end
			endcase
		end

//======================Interconnector============================//

//sinc,fv lookup table

	IP_ROMsinc	IP_ROMsinc_inst (
	.address ( rom_address),
	.clock ( clk100m),
	.q ( sinc )
	);
	IP_ROMfv	IP_ROMfv_inst (
	.address ( rom_address ),
	.clock ( clk100m ),
	.q ( fv )
	);
	
	generate						//2*65 Multiplier
	genvar q;
	for(q=0;q<SAM_SIZE;q=q+1)
	begin :MANYMULTS
		IP_int14multint16 inst1
		(
		.dataa ( rSe_int14[SAM_SIZE-1-q] ),
		.datab ( sincs[q+rj_TDint] ),
		.result ( sincse[q])
		);
		IP_int14multint16 inst2
		(
		.dataa ( rSe_int14[SAM_SIZE-1-q] ),
		.datab ( fvs[q+rj_TDint] ),
		.result ( fvse[q])
		);
	end
	
	endgenerate

IP_PARADD65	IP_PARADD65_instek (
	.data0x ( rsincse[0] ),
	.data10x ( rsincse[1] ),
	.data11x ( rsincse[2] ),
	.data12x ( rsincse[3]),
	.data13x ( rsincse[4]),
	.data14x ( rsincse[5]),
	.data15x ( rsincse[6]),
	.data16x ( rsincse[7]),
	.data17x ( rsincse[8]),
	.data18x ( rsincse[9]),
	.data19x ( rsincse[10]),
	.data1x ( rsincse[11]),
	.data20x ( rsincse[12]),
	.data21x ( rsincse[13]),
	.data22x ( rsincse[14]),
	.data23x ( rsincse[15]),
	.data24x ( rsincse[16]),
	.data25x ( rsincse[17]),
	.data26x ( rsincse[18]),
	.data27x ( rsincse[19]),
	.data28x ( rsincse[20]),
	.data29x ( rsincse[21]),
	.data2x ( rsincse[22]),
	.data30x ( rsincse[23]),
	.data31x ( rsincse[24]),
	.data32x ( rsincse[25]),
	.data33x ( rsincse[26]),
	.data34x ( rsincse[27]),
	.data35x ( rsincse[28]),
	.data36x ( rsincse[29]),
	.data37x ( rsincse[30]),
	.data38x ( rsincse[31]),
	.data39x ( rsincse[32]),
	.data3x ( rsincse[33]),
	.data40x ( rsincse[34]),
	.data41x ( rsincse[35]),
	.data42x ( rsincse[36]),
	.data43x ( rsincse[37]),
	.data44x ( rsincse[38]),
	.data45x ( rsincse[39]),
	.data46x ( rsincse[40]),
	.data47x ( rsincse[41]),
	.data48x ( rsincse[42]),
	.data49x ( rsincse[43]),
	.data4x ( rsincse[44]),
	.data50x ( rsincse[45]),
	.data51x ( rsincse[46]),
	.data52x ( rsincse[47]),
	.data53x ( rsincse[48]),
	.data54x ( rsincse[49]),
	.data55x ( rsincse[50]),
	.data56x ( rsincse[51]),
	.data57x ( rsincse[52]),
	.data58x ( rsincse[53]),
	.data59x ( rsincse[54]),
	.data5x ( rsincse[55]),
	.data60x ( rsincse[56]),
	.data61x ( rsincse[57]),
	.data62x ( rsincse[58]),
	.data63x ( rsincse[59]),
	.data64x ( rsincse[60]),
	.data6x ( rsincse[61]),
	.data7x ( rsincse[62]),
	.data8x ( rsincse[63]),
	.data9x ( rsincse[64]),
	.result ( sumsinc )
	);
IP_PARADD65	IP_PARADD65_instfv (
	.data0x ( rfvse[0] ),
	.data10x ( rfvse[1] ),
	.data11x ( rfvse[2] ),
	.data12x ( rfvse[3]),
	.data13x ( rfvse[4]),
	.data14x ( rfvse[5]),
	.data15x ( rfvse[6]),
	.data16x ( rfvse[7]),
	.data17x ( rfvse[8]),
	.data18x ( rfvse[9]),
	.data19x ( rfvse[10]),
	.data1x ( rfvse[11]),
	.data20x ( rfvse[12]),
	.data21x ( rfvse[13]),
	.data22x ( rfvse[14]),
	.data23x ( rfvse[15]),
	.data24x ( rfvse[16]),
	.data25x ( rfvse[17]),
	.data26x ( rfvse[18]),
	.data27x ( rfvse[19]),
	.data28x ( rfvse[20]),
	.data29x ( rfvse[21]),
	.data2x ( rfvse[22]),
	.data30x ( rfvse[23]),
	.data31x ( rfvse[24]),
	.data32x ( rfvse[25]),
	.data33x ( rfvse[26]),
	.data34x ( rfvse[27]),
	.data35x ( rfvse[28]),
	.data36x ( rfvse[29]),
	.data37x ( rfvse[30]),
	.data38x ( rfvse[31]),
	.data39x ( rfvse[32]),
	.data3x ( rfvse[33]),
	.data40x ( rfvse[34]),
	.data41x ( rfvse[35]),
	.data42x ( rfvse[36]),
	.data43x ( rfvse[37]),
	.data44x ( rfvse[38]),
	.data45x ( rfvse[39]),
	.data46x ( rfvse[40]),
	.data47x ( rfvse[41]),
	.data48x ( rfvse[42]),
	.data49x ( rfvse[43]),
	.data4x ( rfvse[44]),
	.data50x ( rfvse[45]),
	.data51x ( rfvse[46]),
	.data52x ( rfvse[47]),
	.data53x ( rfvse[48]),
	.data54x ( rfvse[49]),
	.data55x ( rfvse[50]),
	.data56x ( rfvse[51]),
	.data57x ( rfvse[52]),
	.data58x ( rfvse[53]),
	.data59x ( rfvse[54]),
	.data5x ( rfvse[55]),
	.data60x ( rfvse[56]),
	.data61x ( rfvse[57]),
	.data62x ( rfvse[58]),
	.data63x ( rfvse[59]),
	.data64x ( rfvse[60]),
	.data6x ( rfvse[61]),
	.data7x ( rfvse[62]),
	.data8x ( rfvse[63]),
	.data9x ( rfvse[64]),
	.result ( sumfv )
	);
wire [13:0] wirey32=rSh_int14[32];
	IP_int32sub	IP_int32sub_inst (
	.dataa ( {{4{ wirey32[13]}}, wirey32[12:0],15'b0} ),
	.datab ( rsumsinc ),
	.result ( ek )
	);


IP_int32mult32	IP_int32mult32_inst (
	.dataa ( rek),
	.datab ( rek ),
	.result ( ek2_int64 )
	);

	IP_int64tofl	IP_int64tofl_inst (
	.clock ( clk100m),
	.dataa ( rek2 ),
	.result ( result_r2 )
	);
IP_floatconvert	IP_floatconvert_inst1 (
	.clock ( clk100m ),
	.dataa ( rek),
	.result ( result_r1 )
	);
IP_floatconvert	IP_floatconvert_inst2 (
	.clock ( clk100m ),
	.dataa ( rsumfv),
	.result ( result_r3 )
	);

	IP_floatmult	IP_floatmult_inst1 (
	.clock (clk100m ),
	.dataa ( result_r1 ),
	.datab ( FACTOR1 ),
	.result ( result_flmult1 )
	);
	IP_floatmult	IP_floatmult_inst2 (
	.clock (clk100m ),
	.dataa ( result_r2 ),
	.datab ( FACTOR2 ),
	.result ( result_flmult2 )
	);
	IP_floatmult	IP_floatmult_inst3 (
	.clock (clk100m ),
	.dataa ( result_r3 ),
	.datab ( FACTOR3 ),
	.result ( result_flmult3 )
	);
	
IP_floatmult	IP_floatmult_inst4 (
	.clock (clk100m ),
	.dataa ( result_flmult1 ),
	.datab ( result_flmult3),
	.result ( result_flmult4 )
	);
	IP_exp	IP_exp_inst (
	.clock ( clk100m ),
	.data ( result_flmult2),
	.result ( result_exp )
	);

	IP_floatmult	IP_floatmult_inst5 (
	.clock (clk100m ),
	.dataa ( result_flmult4 ),
	.datab ( FACTOR4 ),
	.result ( result_flmult5 )
	);



	IP_floatmult	IP_floatmult_inst6 (
	.clock (clk100m ),
	.dataa ( shift_resultmult[5]),
	.datab ( shift_exp ),
	.result ( result_flmult6 )
	);

	IP_fltoint32 IP_fltoint32_inst(
	.clock(clk100m),
	.dataa(result_flmult6),
	.result(result_int_DD)
	);
	IP_int32ADD ip_int32add_inst(
	.dataa(TD),
	.datab(cache_DD),
	.result(TD1)
	);
	
// Custom Functions
function [46:0] Getflintdec;
input [31:0]fl;
reg [31:0]temp;
reg [23:-23] M;
begin
	temp=(fl[31]?~fl[30:0]+1:fl[30:0]);
	M={{16{1'b0}},temp[30:0]};
	Getflintdec[46:0]=M;
end
endfunction
	endmodule
	