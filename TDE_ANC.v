module TDE_ANC(
clk_s,
clk_100m,
rst_n,
d_int14,
x_int14,
TD,
Smpr_TD,
d_canel_out
);
input clk_s;						//sampling clk
input clk_100m;					//sys clk 
input rst_n;						//reset signal
input  [13:0] d_int14;			//primary input 
input  [13:0] x_int14;			//reference noise input 
output [13:0] d_canel_out;		//output
output [31:0] TD;					//TDE values
output [31:0] Smpr_TD;			//TDC values


parameter DELAY=2;				//Half the length of the filter delay 
parameter LEN=30;					//The length of the shift register
reg [13:0] d_arr[LEN-1:0];		//shift register
reg [13:0] x;						//x register
integer i;
always@(posedge clk_s)
	if(!rst_n)
		begin
					x<=0;
			for(i=0;i<LEN;i=i+1)
				begin
					d_arr[i]<=0;
				end
		end
	else 
		begin
			d_arr[0]<=d_int14;
			x<=x_int14;
			for(i=1;i<LEN;i=i+1)
				begin
					d_arr[i]<=d_arr[i-1];
				end
		end


wire [13:0] xk_d;
wire [31:0] td;				
TDEA i1(
.clk(clk_s),
.clk100m(clk_100m),
.rst_n(rst_n),
.Se_int14(d_int14),
.Sh_int14(x_int14),
.Start(1'b1),
.TD(td),
.x_int14(xk_d),
.Valid(),
.Update()
);
wire [8:0] delay=(Smpr_TD[22]?Smpr_TD[31:23]+1:Smpr_TD[31:23]);
AFIR i2(
.clk_s(clk_s),
.clk_100m(clk_100m),
.rst_n(rst_n),
.d_int14(d_arr[DELAY+delay-1]),
.x_int14(x),
.d_canel_out(d_canel_out)
);
Smooth i3(
.clk(clk_s),
.clk100m(clk_100m),
.rst_n(rst_n),
.Orig_TD(td),
.Smpr_TD(Smpr_TD)
);
assign TD=td;
endmodule
