使用说明：
	¤This design is implemented on quartus ii 13.0.
	¤Support email for questions: liuzhiyang123@outlook.com
//===========================================================================================//
Contents：
ANC_TimeDelay
│  ReadMe.txt 		          ---- This file.	
│  
├─  
│      generaldatawithnoise_delay.m  ---- matlab file to generate simulation data (d_noise.txt,x_noise.txt)
│      
├─quartus_project               ---- quartus_project directory
│  │  AFIR.v                    ---- ANC module
│  │  AFIR.v.bak
│  │  fv_table0.mif             ---- f function lookup table initialization file
│  │  IP_exp.qip
│  │  IP_exp.v                  ---- Exponential function IP core (floating point)
│  │  IP_exp_bb.v
│  │  IP_exp_inst.v
│  │  IP_floatconvert.qip
│  │  IP_floatconvert.v          ---- 32-bit Integer to floating point IP core
│  │  IP_floatconvert_bb.v
│  │  IP_floatconvert_inst.v
│  │  IP_floatconvert_syn.v
│  │  IP_floatmult.qip
│  │  IP_floatmult.v             ---- Floating-point multiply IP core
│  │  IP_floatmult_bb.v
│  │  IP_floatmult_inst.v
│  │  IP_floatmult_syn.v
│  │  IP_floatsub.qip
│  │  IP_fltoint32.qip
│  │  IP_fltoint32.v             ---- Float to Integer IP core
│  │  IP_fltoint32_bb.v
│  │  IP_fltoint32_inst.v
│  │  IP_fltoint32_syn.v
│  │  IP_int14mult.qip
│  │  IP_int14mult.v             ---- 14-bit Integer multiplier IP core
│  │  IP_int14multint16.qip
│  │  IP_int14multint16.v        ---- 14*16-bit Integer multiplier IP core
│  │  IP_int14multint16_bb.v
│  │  IP_int14multint16_inst.v
│  │  IP_int14multint16_syn.v
│  │  IP_int14mult_bb.v
│  │  IP_int14mult_inst.v
│  │  IP_int14mult_syn.v
│  │  IP_int32ADD.qip
│  │  IP_int32ADD.v	            ---- 32-bit Integer multiplier IP core
│  │  IP_int32ADD_bb.v
│  │  IP_int32ADD_inst.v
│  │  IP_int32ADD_syn.v
│  │  IP_int32mult32.qip
│  │  IP_int32mult32.v	    ---- 32*32-bit Integer multiplier IP core
│  │  IP_int32mult32_bb.v
│  │  IP_int32mult32_inst.v
│  │  IP_int32mult32_syn.v
│  │  IP_int32sub.qip
│  │  IP_int32sub.v	            ---- 32*32-bit Subtract Integer IP Core
│  │  IP_int32sub_bb.v
│  │  IP_int32sub_inst.v
│  │  IP_int32sub_syn.v
│  │  IP_int64tofl.qip
│  │  IP_int64tofl.v	            ---- 64-bit Subtract Integer IP Core
│  │  IP_int64tofl_bb.v
│  │  IP_int64tofl_inst.v
│  │  IP_int64tofl_syn.v
│  │  IP_PARADD65.qip
│  │  IP_PARADD65.v	            ---- 65 Parallel adder IP core
│  │  IP_PARADD65_bb.v
│  │  IP_PARADD65_inst.v
│  │  IP_PARADD65_syn.v
│  │  IP_ROMfv.qip
│  │  IP_ROMfv.v	            ---- ROM block IP core（f function lookup table）
│  │  IP_ROMfv_bb.v
│  │  IP_ROMfv_inst.v
│  │  IP_ROMfv_syn.v
│  │  IP_ROMsinc.qip
│  │  IP_ROMsinc.v	            ---- ROM block IP core（sinc function lookup table）
│  │  IP_ROMsinc_bb.v
│  │  IP_ROMsinc_inst.v
│  │  IP_ROMsinc_syn.v
│  │  IP_uint36_add_sub.qip
│  │  IP_uint36_add_sub.v	    
│  │  IP_uint36_add_sub_bb.v
│  │  IP_uint36_add_sub_inst.v
│  │  IP_uint36_add_sub_syn.v
│  │  nefs.out.sdc
│  │  nefs.qpf                    ---- <Project startup file>
│  │  nefs.qsf
│  │  nefs.qws
│  │  nefs.tis_db_list.ddb
│  │  nefs.v.bak
│  │  nefs_nativelink_simulation.rpt
│  │  NERS.sdc                    ---- Timing constraint file
│  │  NERS.sdc.bak
│  │  sinc_table0.mif             ---- sinc function lookup table initialization file
│  │  Smooth.v                    ---- time delay control module
│  │  TDEA.v                      ---- TDE MODULE
│  │  TDE_ANC.v                   ---- Top-level document
│  │  
│  │      
│  └─simulation                  ---- Simulation directory
│      │  stimulationforANC.do    ---- Simulation scripts to view internal signals and control module simulation time
│      │  
│      └─modelsim
│              Dout.txt            ---- Output e(k)
│              d_noise.txt         ---- Inout d(k)
│              SmoothTimeDelay.txt ---- TDC vakues output
│              TDE_ANC.vt          ---- Testbench
│              TimeDelay.txt       ---- Outpue D(k)
│              x_noise.txt         ---- Input x(k)
│              
└─System Block Diagram                           
        sys.png                                 
        
        
