module verif_comp_a (
  input            clk,
  input            rstn,
  input            a_ready,
  output reg       a_valid,
  output reg [7:0] a_operand
);

  localparam [1:0] IDLE_NR = 0;
  localparam [1:0] IDLE_R  = 1;
  localparam [1:0] REQ     = 2;
  localparam [1:0] HS      = 3;

  wire [1:0] state;
  assign state = {a_valid, a_ready};

  reg[3:0] wait_time;
  always @(posedge clk or negedge rstn) begin
    if (! rstn) begin
      wait_time <= 10;
    end else begin
      case (state)
        IDLE_NR, IDLE_R, HS : begin
          wait_time <= (wait_time == 0) ? $random : wait_time - 1;
        end
        default : begin // including REQ
        end
      endcase
    end
  end


  always @(posedge clk or negedge rstn) begin
    if (! rstn) begin
      a_valid   <= 1'b0;
      a_operand <= 8'hzz;
    end else begin
      case (state)
        IDLE_NR, IDLE_R, HS : begin
          a_valid   <= (wait_time == 0) ? 1'b1    : 1'b0;
          a_operand <= (wait_time == 0) ? $random : a_operand;
        end
        default : begin // including REQ
        end
      endcase
    end
  end


endmodule
