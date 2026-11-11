#!/bin/bash
halfKB=$(awk '/MemAvailable/{print int($2/2)}' /proc/meminfo)
export OMP_NUM_THREADS=${THREADS:-4} OPENBLAS_NUM_THREADS=${THREADS:-4} OCTAVE_HISTFILE=/dev/null
if [ -n "$GPU" ]; then export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnvblas.so NVBLAS_CONFIG_FILE=/tmp/claude-1000/-home-userstorexxx-gmail-com-Desktop-projectCV/9793ab9e-0611-4df1-9731-8cdd2a53faa1/scratchpad/nvblas.conf; fi
cd ${WORKDIR:-/home/userstorexxx-gmail-com/Desktop/projectCV/Kiosk_Data/cache}
exec systemd-run --user --scope -q -p MemoryMax=${halfKB}K -p MemorySwapMax=0 nice -n 10 octave --no-gui --norc -q --eval "crash_dumps_octave_core(false); sighup_dumps_octave_core(false); sigterm_dumps_octave_core(false); source('$1');"
