
// testbench for simulation
module xgriscv_tb();
    
   reg  clk, rstn;
   wire [31:0] pc;
    
// instantiation of sccomp    
   xgriscv_sc U_XGRISCV(
      .clk(clk), .rstn(rstn), .pcW(pc) 
   );

  	integer foutput;
  	integer counter = 0;
   
   initial begin
      $readmemh( "riscv32_sim1.dat" , U_XGRISCV.U_imem.ROM); // load instructions into instruction memory
      clk = 1;
      rstn = 1;
      #5 ;
      rstn = 0;
      #20 ;
      rstn = 1;
   end
   
    always begin
    #(50) clk = ~clk;
	   
    if (clk == 1'b1) begin
      counter = counter + 1;
      if (pc == 32'h0000000c) begin
        $stop;
      end
    end
  end //end always
   
endmodule
