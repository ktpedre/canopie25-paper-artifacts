set terminal postscript eps enhanced color 20
set output 'llama-405b.eps'

#set title 'meta-llama/Llama-3.1-405B-Instruct"
set xlabel 'Maximum Request Concurrency'
set ylabel 'Output Token Throughput (tokens/s)'

set pointsize 1.25
set logscale x 2
#set logscale y 10
set xrange [.9:1050]
set yrange [10:]
#set key top left
set key at screen 0.78,0.93

datafile = 'results.dat'

set label "crash" at 1000,1550 tc rgb "red" right

plot \
    datafile using 1:2 title "Hops HPC, Run 1             (hops 39-42)"          with linespoints lw 3 lc rgb 'red', \
    datafile using 1:3 title "Hops HPC, Run 2             (hops 22-25)"          with linespoints lw 3 lc rgb 'orange', \
    datafile using 1:4 title "Hops HPC, Run 3 (hops 28, 37-38, 58)"  with linespoints lw 3 lc rgb 'green'

set output
