module xgriscv_sc(clk, rstn, pcW);
   input          clk;
   input          rstn;
   output [31:0]  pcW;
   
   wire [31:0]    instr;
   wire [31:0]    PC;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   
   wire rst = ~rstn;
       
  // instantiation of single-cycle CPU   
   SCPU U_SCPU(
         .clk(clk),                 // input:  cpu clock
         .reset(rst),                 // input:  reset
         .inst_in(instr),             // input:  instruction
         .Data_in(dm_dout),        // input:  data to cpu  
         .mem_w(MemWrite),       // output: memory write signal
         .PC_out(PC),                   // output: PC
         .Addr_out(dm_addr),          // output: address from cpu to memory
         .Data_out(dm_din),        // output: data from cpu to memory
         .reg_sel(reg_sel),         // input:  register selection
         .reg_data(reg_data),
         .pcW(pcW)        // output: register data
         );
         
  // instantiation of data memory  
   dm    U_DM(
         .clk(clk),           // input:  cpu clock
         .DMWr(MemWrite),     // input:  ram write
         .addr(dm_addr[8:2]), // input:  ram address
         .din(dm_din),        // input:  data to ram
         .dout(dm_dout)       // output: data from ram
         );
         
  // instantiation of intruction memory (used for simulation)
   im    U_IM ( 
      .addr(PC[8:2]),     // input:  rom address
      .dout(instr)        // output: instruction
   );
        
endmodule

