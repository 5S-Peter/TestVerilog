simvision { source $env(S5S_VER_TEST)/ip/special_alu/testbench/verilog/scripts/wave.tcl }

simvision { \
  mmap new  -reuse -name op_radix -radix %x -contents { \
    {%x=0 -bgcolor #66fcf1 -textcolor #000000 -label ADD2 -shape bus} \
    {%x=1 -bgcolor #0b0c10 -textcolor #ffffff -label SUB2 -shape bus} \
    {%x=2 -bgcolor #1f2833 -textcolor #ffffff -label OR2  -shape bus} \
    {%x=3 -bgcolor #45a29e -textcolor #000000 -label AND2 -shape bus} \
    {%x=4 -bgcolor #1f2833 -textcolor #ffffff -label OR   -shape bus} \
    {%x=5 -bgcolor #45a29e -textcolor #000000 -label AND  -shape bus} \
    {%x=6 -bgcolor #66fcf1 -textcolor #000000 -label SUM  -shape bus} \
    {%x=7 -bgcolor #c5c6c7 -textcolor #ffffff -label AVG  -shape bus} \
  } \
}

simvision { \
  waveform format [waveform find -name "*operation*"] -radix op_radix \
}
