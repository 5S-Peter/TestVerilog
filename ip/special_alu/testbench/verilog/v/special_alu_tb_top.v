module special_alu_tb_top();

  wire rstn, clk;

  wire a_valid, a_ready;
  wire [7:0] a_operand;

  wire b_valid, b_ready;
  wire [2:0] b_operation;
  wire [10:0] b_result;

  special_alu_tb_clk_rstn i0_clk_rstn (
    .rstn    (rstn),
    .clk     ( clk)
  );

  verif_comp_a i0_verif_comp_a (
    .clk      (      clk),
    .rstn     (     rstn),
    .a_ready  (  a_ready),
    .a_valid  (  a_valid),
    .a_operand(a_operand)
  );

  verif_comp_b i0_verif_comp_b (
    .clk         (              clk),
    .rstn        (             rstn),
    .b_valid     (          b_valid),
    .b_result    ({21'h0, b_result}),
    .b_ready     (          b_ready),
    .b_operation (      b_operation)
  );

  special_alu_tb_checker_scoreboard i0_checker_scoreboard (
    .clk         (         clk),
    .rstn        (        rstn),
    .a_ready     (     a_ready),
    .a_valid     (     a_valid),
    .a_operand   (   a_operand),
    .b_valid     (     b_valid),
    .b_result    (    b_result),
    .b_ready     (     b_ready),
    .b_operation ( b_operation)
  );

  special_alu i0_special_alu (
    .clk         (         clk),
    .rstn        (        rstn),
    .a_ready     (     a_ready),
    .a_valid     (     a_valid),
    .a_operand   (   a_operand),
    .b_valid     (     b_valid),
    .b_result    (    b_result),
    .b_ready     (     b_ready),
    .b_operation ( b_operation)
  );

  initial begin
    repeat (1000) begin
      @(posedge clk);
    end
    $finish;
  end

endmodule
