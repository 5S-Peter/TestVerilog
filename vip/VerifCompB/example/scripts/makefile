

TB_DIR           = ${S5S_VER_TEST}/vip/VerifCompB/example/


COMPILE_RESULT   = ${TB_DIR}/rundir/compile.log
COMPILE_COMMAND  = xrun -64bit -f ${TB_DIR}/file_list/compile.f +access+rwc +timescale=1ns/100ps -c -l ${COMPILE_RESULT}
RUN_RESULT       = ${TB_DIR}/rundir/run.log
RUN_COMMAND      = xrun -64bit -R -l ${RUN_RESULT} -gui ${EXTRA_OPTS}


${COMPILE_RESULT}:
	${COMPILE_COMMAND}

compile: ${COMPILE_RESULT}

.PHONY:${RUN_RESULT}
${RUN_RESULT}: ${COMPILE_RESULT}
	${RUN_COMMAND}

run: ${RUN_RESULT}


clean:
	rm -rf `ls --ignore=makefile --ignore=.default --almost-all`

