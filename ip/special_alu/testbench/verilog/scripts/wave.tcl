
source $env(S5S_U)/scripting/tcl/tool_specific/xcelium/wave_util/script/wave_utils.tcl

set special_alu_path  special_alu_tb_top.i0_special_alu
set special_alu_group {DUT}
source $env(S5S_VER_TEST)/ip/special_alu/etc/wave.tcl

set checker_path special_alu_tb_top.i0_checker_scoreboard
set s5s_wave_struct [list \
  {TB} [list \
    {CHECKER} [list \
      "-" ${checker_path}.rstn \
      "-" ${checker_path}.clk \
      {IF_A} [list \
        "-" ${checker_path}.a_valid \
        "-" ${checker_path}.a_ready \
        "-" ${checker_path}.a_operand \
      ] \
      {IF_B} [list \
        "-" ${checker_path}.b_valid \
        "-" ${checker_path}.b_ready \
        "-" ${checker_path}.b_result \
        "-" ${checker_path}.b_operation \
      ] \
      {INTERNAL} [list \
        "-" ${checker_path}.a_hs \
        "-" ${checker_path}.b_hs \
        "-" ${checker_path}.cnt \
        "-" ${checker_path}.fifo \
        "-" ${checker_path}.fifo\[63:56\] \
        "-" ${checker_path}.fifo\[55:48\] \
        "-" ${checker_path}.fifo\[47:40\] \
        "-" ${checker_path}.fifo\[39:32\] \
        "-" ${checker_path}.fifo\[31:24\] \
        "-" ${checker_path}.fifo\[23:16\] \
        "-" ${checker_path}.fifo\[15:8\] \
        "-" ${checker_path}.fifo\[7:0\] \
        "-" ${checker_path}.exp_result \
      ] \
    ] \
  ] \
]

s5s_update_wave $s5s_wave_struct
