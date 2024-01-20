if {[catch {dump -add ${special_alu_path}  -depth 0 -aggregates -scope "."} errorvar]} {}

set s5s_wave_struct [list \
  ${special_alu_group} [list \
    "-" ${special_alu_path}.rstn \
    "-" ${special_alu_path}.clk \
    {IF_A} [list \
      "-" ${special_alu_path}.a_valid \
      "-" ${special_alu_path}.a_ready \
      "-" ${special_alu_path}.a_operand \
    ] \
    {IF_B} [list \
      "-" ${special_alu_path}.b_valid \
      "-" ${special_alu_path}.b_ready \
      "-" ${special_alu_path}.b_result \
      "-" ${special_alu_path}.b_operation \
    ] \
  ] \
]

s5s_update_wave $s5s_wave_struct

