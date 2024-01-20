module special_alu (
  input         rstn,
  input         clk,
  
  input         a_valid,
  input  [7:0]  a_operand,
  output        a_ready,

  output        b_valid,
  output [10:0] b_result,
  input         b_ready,
  input  [2:0]  b_operation
);

  localparam [2:0] OP_ADD2 = 0;
  localparam [2:0] OP_SUB2 = 1;
  localparam [2:0] OP_OR2  = 2;
  localparam [2:0] OP_AND2 = 3;
  localparam [2:0] OP_OR   = 4;
  localparam [2:0] OP_AND  = 5;
  localparam [2:0] OP_SUM  = 6;
  localparam [2:0] OP_AVG  = 7;

  reg  [2:0] wr_ptr;
  reg  [3:0] cnt;
  reg  [7:0] fifo[7:0];

  wire [2:0] ptr_e0;
  assign ptr_e0 = wr_ptr - cnt;
  wire [7:0] fifo_e0;
  assign fifo_e0 = cnt > 0 ? fifo[ptr_e0] : 8'h0;

  wire [2:0] ptr_e1;
  assign ptr_e1 = ptr_e0 + 1;
  wire [7:0] fifo_e1;
  assign fifo_e1 = cnt > 1 ? fifo[ptr_e1] : 8'h0;

  reg a_ready_r;
  assign a_ready = a_ready_r | b_ready;

  wire a_hs;
  assign a_hs = a_valid & a_ready;

  wire b_hs;
  assign b_hs = b_valid & b_ready;

  reg[10:0] result;
  assign b_result = result;

  integer i;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      a_ready_r <= 1'b1;
    end else begin
      if (cnt < 8) begin
        a_ready_r <= 1'b1;
      end else begin
        case ({a_hs, b_hs})
          2'b00 : a_ready_r <= 1'b0;
          2'b01 : a_ready_r <= 1'b1;
          2'b10 : begin end //this can't happen
          2'b11 : a_ready_r <= 1'b0;
        endcase
      end
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      wr_ptr <= 0;
    end else begin
      if (a_hs) begin
        wr_ptr <= wr_ptr + 1;
      end
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      cnt <= 0;
    end else begin
      case ({a_hs, b_hs})
        2'b01 : cnt <= cnt - 1;
        2'b10 : cnt <= cnt + 1;
        default : begin end
      endcase
    end
  end

  always @(posedge clk or negedge rstn) begin
    if (rstn) begin
      if (a_hs) begin
        fifo[wr_ptr] <= a_operand;
      end
    end
  end

  assign b_valid = cnt > (b_operation < 4 ? 1 : 0) ? 1'b1 : 1'b0;

  always @(*) begin
    case (b_operation)
      OP_ADD2 : result = fifo_e0 + fifo_e1;
      OP_SUB2 : result = fifo_e0 - fifo_e1;
      OP_OR2  : result = fifo_e0 | fifo_e1;
      OP_AND2 : result = fifo_e0 & fifo_e1;
      OP_OR   : begin
        result = 11'h0;
        for (i = wr_ptr - cnt; i != wr_ptr; i = i + 1) begin
          result = result | fifo[i[2:0]];
        end
      end
      OP_AND   : begin
        result = 11'h7ff;
        for (i = wr_ptr - cnt; i != wr_ptr; i = i + 1) begin
          result = result & fifo[i[2:0]];
        end
      end
      OP_SUM   : begin
        result = 11'h0;
        for (i = wr_ptr - cnt; i != wr_ptr; i = i + 1) begin
          result = result + fifo[i[2:0]];
        end
      end
      OP_AVG : begin 
        result = 11'h0;
        for (i = wr_ptr - cnt; i != wr_ptr; i = i + 1) begin
          result = result + fifo[i[2:0]];
        end
        result = cnt > 0 ? result / cnt : 11'h0;
      end
      default : result = 11'h0;
    endcase
  end

endmodule
