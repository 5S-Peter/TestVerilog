module special_alu_tb_clk_rstn (
  output reg clk,
  output reg rstn
);

  initial begin
    rstn <= 1'b0;
    #7;
    rstn <= 1'b1;
  end

  initial begin
    clk <= 1'b0;
    forever begin
      #5;
      clk <= ~clk;
    end
  end

endmodule
