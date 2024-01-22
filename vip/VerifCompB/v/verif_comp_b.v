module verif_comp_b (
  input             clk,
  input             rstn,
  input             b_valid,
  input      [31:0] b_result,
  output            b_ready,
  output reg [ 2:0] b_operation
);

  localparam [1:0] IDLE_NR = 0;
  localparam [1:0] IDLE_R  = 1;
  localparam [1:0] REQ     = 2;
  localparam [1:0] HS      = 3;

  localparam [2:0] OP_ADD2 = 0;
  localparam [2:0] OP_SUB2 = 1;
  localparam [2:0] OP_OR2  = 2;
  localparam [2:0] OP_AND2 = 3;
  localparam [2:0] OP_OR   = 4;
  localparam [2:0] OP_AND  = 5;
  localparam [2:0] OP_SUM  = 6;
  localparam [2:0] OP_AVG  = 7;

  wire [1:0] state;
  assign state = {b_valid, b_ready};

  reg[4:0] wait_time;
  always @(posedge clk or negedge rstn) begin
    if (! rstn) begin
      wait_time <= 1;
    end else begin
      case (state)
        HS : begin
          wait_time <= $random;
        end
        REQ : begin
          wait_time <= wait_time - 1;
        end
        default : begin // including IDLE_NR, IDLE_R
        end
      endcase
    end
  end

  assign b_ready = wait_time > 0 ? 1'b0 : 1'b1;

  always @(posedge clk or negedge rstn) begin
    if (! rstn) begin
      b_operation <= OP_OR;
    end else begin
      if (state == HS) begin
        b_operation <= $random;
      end
    end
  end

endmodule
