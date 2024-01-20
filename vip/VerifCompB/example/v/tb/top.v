module top();
  reg rstn, clk;

  reg         b_valid;
  wire        b_ready;
  wire [ 2:0] b_operation;
  reg  [10:0] b_result;


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
    b_valid <= 1'b0;
    @(posedge rstn);
    forever begin
      delay = $random;
      repeat (delay) begin
        @(posedge clk);
      end
      b_valid  <= 1'b1;
      b_result <= $random;

      @(posedge clk);
      while (! b_ready)  begin
        @(posedge clk);
      end
      b_valid <= 1'b0;
    end
  end

  verif_comp_b i0_verif_comp_b (
    .clk         (clk      ),
    .rstn        (rstn     ),
    .b_ready     (b_ready  ),
    .b_valid     (b_valid  ),
    .b_operation (b_operation),
    .b_result    ({21'h0,b_result})
  );

endmodule
