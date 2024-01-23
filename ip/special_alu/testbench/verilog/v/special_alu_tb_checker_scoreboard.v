module special_alu_tb_checker_scoreboard (
  input        clk,
  input        rstn,
  input        a_valid,
  input        a_ready,
  input [ 7:0] a_operand,
  input        b_valid,
  input        b_ready,
  input [ 2:0] b_operation,
  input [10:0] b_result
);

  localparam [2:0] OP_ADD2 = 0;
  localparam [2:0] OP_SUB2 = 1;
  localparam [2:0] OP_OR2  = 2;
  localparam [2:0] OP_AND2 = 3;
  localparam [2:0] OP_OR   = 4;
  localparam [2:0] OP_AND  = 5;
  localparam [2:0] OP_SUM  = 6;
  localparam [2:0] OP_AVG  = 7;

  reg[3:0]  cnt;
  reg[63:0] fifo;

  wire a_hs, b_hs;
  assign a_hs = a_valid & a_ready;
  assign b_hs = b_valid & b_ready;

  integer i;

  always @(posedge clk or negedge rstn) begin
    if (! rstn) begin
      fifo <= 64'h0;
      cnt  <= 3'h0;
    end else begin
      if (a_hs) begin
        if (! b_hs) begin
          cnt  <= (cnt == 8) ? cnt : cnt + 1;
        end
        fifo <= {fifo[55:0], a_operand};
      end else begin
        if (b_hs) begin
          cnt  <= cnt - 1;
        end
      end
    end
  end

  function [7:0] get_fifo_item(input [6:0] index, input [63:0] act_fifo, input [3:0] act_cnt);
  begin
    case (act_cnt - (1+index))
      0 : get_fifo_item = act_fifo[ 7: 0];
      1 : get_fifo_item = act_fifo[15: 8];
      2 : get_fifo_item = act_fifo[23:16];
      3 : get_fifo_item = act_fifo[31:24];
      4 : get_fifo_item = act_fifo[39:32];
      5 : get_fifo_item = act_fifo[47:40];
      6 : get_fifo_item = act_fifo[55:48];
      7 : get_fifo_item = act_fifo[63:56];
      default : 
        case (b_operation)
          OP_AND2, OP_AND : get_fifo_item = 8'hff;
          default         : get_fifo_item = 8'h00;
        endcase
    endcase
  end
  endfunction

  function [10:0] get_exp_result(input [2:0] op, input [63:0] act_fifo, input [3:0] act_cnt);
  begin
    case (op)
      OP_ADD2 : get_exp_result = get_fifo_item(0, act_fifo, act_cnt) + get_fifo_item(1, act_fifo, act_cnt);
      OP_SUB2 : get_exp_result = get_fifo_item(0, act_fifo, act_cnt) - get_fifo_item(1, act_fifo, act_cnt);
      OP_OR2  : get_exp_result = get_fifo_item(0, act_fifo, act_cnt) | get_fifo_item(1, act_fifo, act_cnt);
      OP_AND2 : get_exp_result = get_fifo_item(0, act_fifo, act_cnt) & get_fifo_item(1, act_fifo, act_cnt);
      OP_OR   : begin
        get_exp_result = 11'h0;
        for (i = 0; i < act_cnt; i = i+ 1) begin
          get_exp_result = get_exp_result | get_fifo_item(i, act_fifo, act_cnt);
        end
      end
      OP_AND  : begin
        get_exp_result = 11'h7ff;
        for (i = 0; i < act_cnt; i = i+ 1) begin
          get_exp_result = get_exp_result & get_fifo_item(i, act_fifo, act_cnt);
        end
      end
      OP_SUM  : begin
        get_exp_result = 11'h0;
        for (i = 0; i < act_cnt; i = i+ 1) begin
          get_exp_result = get_exp_result + get_fifo_item(i, act_fifo, act_cnt);
        end
      end
      OP_AVG  : begin
        get_exp_result = 11'h0;
        for (i = 0; i < act_cnt; i = i+ 1) begin
          get_exp_result = get_exp_result + get_fifo_item(i, act_fifo, act_cnt);
        end
        get_exp_result = get_exp_result / act_cnt;
      end
    endcase
  end
  endfunction

  wire [10:0] exp_result;
  assign exp_result = get_exp_result(b_operation, fifo, cnt);

  always @(posedge clk) begin
    if (b_hs) begin
      if (exp_result != b_result) begin
        $display("@ %6t - Mismatch exp: 11'h%3h vs. 11'h%3h", $stime, exp_result, b_result);
      end
    end
  end

  // -----------------
  // CHECKER
  // -----------------
  reg        a_valid_check_r;
  reg        a_ready_check_r;
  reg [ 7:0] a_operand_check_r;
  reg        b_valid_check_r;
  reg        b_ready_check_r;
  reg [ 2:0] b_operation_check_r;
  reg [10:0] b_result_check_r;

  wire a_valid_check_chg;
  wire a_ready_check_chg;
  wire a_operand_check_chg;
  wire b_valid_check_chg;
  wire b_ready_check_chg;
  wire b_operation_check_chg;
  wire b_result_check_chg;

  assign a_valid_check_chg     = (a_valid      == a_valid_check_r     ) ? 1'b0 : 1'b1 ;
  assign a_ready_check_chg     = (a_ready      == a_ready_check_r     ) ? 1'b0 : 1'b1 ;
  assign a_operand_check_chg   = (a_operand    == a_operand_check_r   ) ? 1'b0 : 1'b1 ;
  assign b_valid_check_chg     = (b_valid      == b_valid_check_r     ) ? 1'b0 : 1'b1 ;
  assign b_ready_check_chg     = (b_ready      == b_ready_check_r     ) ? 1'b0 : 1'b1 ;
  assign b_operation_check_chg = (b_operation  == b_operation_check_r ) ? 1'b0 : 1'b1 ;
  assign b_result_check_chg    = (b_result     == b_result_check_r    ) ? 1'b0 : 1'b1 ;

  wire a_valid_check_rise;
  wire a_valid_check_fall;
  wire a_ready_check_rise;
  wire a_ready_check_fall;
  wire b_valid_check_rise;
  wire b_valid_check_fall;
  wire b_ready_check_rise;
  wire b_ready_check_fall;

  assign a_valid_check_rise = a_valid_check_chg &  a_valid;
  assign a_ready_check_rise = a_ready_check_chg &  a_ready;
  assign b_valid_check_rise = b_valid_check_chg &  b_valid;
  assign b_ready_check_rise = b_ready_check_chg &  b_ready;
  assign a_valid_check_fall = a_valid_check_chg & ~a_valid;
  assign a_ready_check_fall = a_ready_check_chg & ~a_ready;
  assign b_valid_check_fall = b_valid_check_chg & ~b_valid;
  assign b_ready_check_fall = b_ready_check_chg & ~b_ready;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      a_valid_check_r     <=  1'b0;
      a_ready_check_r     <=  1'b1;
      a_operand_check_r   <=  7'h00;
      b_valid_check_r     <=  1'b0;
      b_ready_check_r     <=  1'b0;
      b_operation_check_r <=  3'h4;
      b_result_check_r    <= 11'h0;
    end else begin
      a_valid_check_r     <= a_valid     ;
      a_ready_check_r     <= a_ready     ;
      a_operand_check_r   <= a_operand   ;
      b_valid_check_r     <= b_valid     ;
      b_ready_check_r     <= b_ready     ;
      b_operation_check_r <= b_operation ;
      b_result_check_r    <= b_result    ;
    end
  end

  always @(posedge clk) begin
    if (rstn) begin
      // CHK 000 - a_valid can only fall when a_ready is high
      if (a_valid_check_fall && ~a_ready_check_r) begin
        $display("ERR CHK 000 - a_valid can only fall after a handshake!");
      end

      // CHK 001 - operand can only change on new transaction or reset
      if (
        (a_operand_check_chg) &&
        ~ (a_valid_check_rise | (a_valid & a_ready_check_r))
      ) begin
        $display("ERR CHK 001 - @%5t a_operand changed during IDLE interface or during a transaction!", $time);
      end

      // CHK 002 - b_valid can only fall when b_ready is high
      if (b_valid_check_fall && ~b_ready_check_r) begin
        $display("ERR CHK 002 - @%5t b_valid can only fall after a handshake!", $time);
      end

      // CHK 003 - operation can only change on hadshake
      if (
        (b_operation_check_chg) && ~(b_valid_check_r & b_ready_check_r)
      ) begin
        $display("ERR CHK 003 - @%5t b_operation changed without handshake!", $time);
      end

    end
  end

endmodule
