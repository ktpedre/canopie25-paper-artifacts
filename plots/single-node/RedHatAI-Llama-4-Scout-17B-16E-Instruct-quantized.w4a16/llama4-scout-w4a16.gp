set terminal postscript eps enhanced color 20
set output 'llama4-scout-w4a16.eps'

#set title 'RedHatAI/Llama-4-Scout-17B-16E-Instruct-quantized.w4a16'
set xlabel 'Maximum Request Concurrency'
set ylabel 'Output Token Throughput (tokens/s)'

set pointsize 1.25
set logscale x 2
#set logscale y 10
set xrange [.9:1050]
set yrange [10:]
#set key top left
#set key bottom right
set key at screen 0.68,0.93

datafile = 'results.dat'

plot \
    datafile using 1:2 title "Hops HPC, Run 1 (hops44)"      with linespoints lw 3 lc rgb 'red', \
    datafile using 1:3 title "Hops HPC, Run 2 (hops01)"      with linespoints lw 3 lc rgb 'orange', \
    datafile using 1:4 title "Hops HPC, Run 3 (hops06)"      with linespoints lw 3 lc rgb 'green', \
    datafile using 1:5 title "Hops HPC, Run 4 (hops29)"      with linespoints lw 3 lc rgb 'blue', \
    datafile using 1:6 title "Hops HPC, Run 5 (hops17)"      with linespoints lw 3 lc rgb 'purple', \
    datafile using 1:7 title "Goodall K8s, Run 1 (goodall05)" with linespoints lw 3 lc rgb 'gray', \
    datafile using 1:8 title "Goodall K8s, Run 2 (goodall05)" with linespoints lw 3 lc rgb 'black'

set output
