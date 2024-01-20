module top();
  reg rstn, clk;

  wire       a_valid;
  reg        a_ready;
  wire [7:0] a_operand;

  initial begin
    rstn <= 1'b0;
    #11;
    rstn <= 1'b1;
    repeat(1000) begin
      @(posedge clk);
    end
    $finish;
  end

  initial begin
    clk <= 1'b0;
    forever begin
      #5;
      clk <= ~clk;
    end
  end

  reg [1:0] delay;
  initial begin
    a_ready <= 1'b0;
    @(posedge rstn);
    forever begin
      delay = $random;
      repeat (delay) begin
        @(posedge clk);
      end
      a_ready <= ~a_ready;
    end
  end

  verif_comp_a i0_verif_comp_a (
    .clk       (clk      ),
    .rstn      (rstn     ),
    .a_ready   (a_ready  ),
    .a_valid   (a_valid  ),
    .a_operand (a_operand)
  );

endmodule
