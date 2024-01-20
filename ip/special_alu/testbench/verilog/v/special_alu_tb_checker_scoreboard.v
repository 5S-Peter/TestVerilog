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


endmodule
