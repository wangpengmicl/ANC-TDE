// megafunction wizard: %LPM_ADD_SUB%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: LPM_ADD_SUB 

// ============================================================
// File Name: IP_int32sub.v
// Megafunction Name(s):
// 			LPM_ADD_SUB
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 13.0.0 Build 156 04/24/2013 SJ Full Version
// ************************************************************


//Copyright (C) 1991-2013 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.


//lpm_add_sub DEVICE_FAMILY="Stratix III" LPM_DIRECTION="SUB" LPM_REPRESENTATION="SIGNED" LPM_WIDTH=32 ONE_INPUT_IS_CONSTANT="NO" dataa datab result
//VERSION_BEGIN 13.0 cbx_cycloneii 2013:04:24:18:08:47:SJ cbx_lpm_add_sub 2013:04:24:18:08:47:SJ cbx_mgl 2013:04:24:18:11:10:SJ cbx_stratix 2013:04:24:18:08:47:SJ cbx_stratixii 2013:04:24:18:08:47:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463


//synthesis_resources = lut 33 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
module  IP_int32sub_add_sub
	( 
	dataa,
	datab,
	result) /* synthesis synthesis_clearbox=1 */;
	input   [31:0]  dataa;
	input   [31:0]  datab;
	output   [31:0]  result;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   [31:0]  dataa;
	tri0   [31:0]  datab;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif


	assign
		result = dataa - datab;
endmodule //IP_int32sub_add_sub
//VALID FILE


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module IP_int32sub (
	dataa,
	datab,
	result)/* synthesis synthesis_clearbox = 1 */;

	input	[31:0]  dataa;
	input	[31:0]  datab;
	output	[31:0]  result;

	wire [31:0] sub_wire0;
	wire [31:0] result = sub_wire0[31:0];

	IP_int32sub_add_sub	IP_int32sub_add_sub_component (
				.dataa (dataa),
				.datab (datab),
				.result (sub_wire0));

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: CarryIn NUMERIC "0"
// Retrieval info: PRIVATE: CarryOut NUMERIC "0"
// Retrieval info: PRIVATE: ConstantA NUMERIC "0"
// Retrieval info: PRIVATE: ConstantB NUMERIC "0"
// Retrieval info: PRIVATE: Function NUMERIC "1"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix III"
// Retrieval info: PRIVATE: LPM_PIPELINE NUMERIC "0"
// Retrieval info: PRIVATE: Latency NUMERIC "0"
// Retrieval info: PRIVATE: Overflow NUMERIC "0"
// Retrieval info: PRIVATE: RadixA NUMERIC "10"
// Retrieval info: PRIVATE: RadixB NUMERIC "10"
// Retrieval info: PRIVATE: Representation NUMERIC "0"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "1"
// Retrieval info: PRIVATE: ValidCtA NUMERIC "0"
// Retrieval info: PRIVATE: ValidCtB NUMERIC "0"
// Retrieval info: PRIVATE: WhichConstant NUMERIC "0"
// Retrieval info: PRIVATE: aclr NUMERIC "0"
// Retrieval info: PRIVATE: clken NUMERIC "0"
// Retrieval info: PRIVATE: nBit NUMERIC "32"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_DIRECTION STRING "SUB"
// Retrieval info: CONSTANT: LPM_HINT STRING "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO"
// Retrieval info: CONSTANT: LPM_REPRESENTATION STRING "SIGNED"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_ADD_SUB"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "32"
// Retrieval info: USED_PORT: dataa 0 0 32 0 INPUT NODEFVAL "dataa[31..0]"
// Retrieval info: USED_PORT: datab 0 0 32 0 INPUT NODEFVAL "datab[31..0]"
// Retrieval info: USED_PORT: result 0 0 32 0 OUTPUT NODEFVAL "result[31..0]"
// Retrieval info: CONNECT: @dataa 0 0 32 0 dataa 0 0 32 0
// Retrieval info: CONNECT: @datab 0 0 32 0 datab 0 0 32 0
// Retrieval info: CONNECT: result 0 0 32 0 @result 0 0 32 0
// Retrieval info: GEN_FILE: TYPE_NORMAL IP_int32sub.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL IP_int32sub.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL IP_int32sub.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL IP_int32sub.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL IP_int32sub_inst.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL IP_int32sub_bb.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL IP_int32sub_syn.v TRUE
// Retrieval info: LIB_FILE: lpm
