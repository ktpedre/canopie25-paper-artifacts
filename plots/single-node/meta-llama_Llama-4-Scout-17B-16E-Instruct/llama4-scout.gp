set terminal postscript eps enhanced color 20
set output 'llama4-scout.eps'

#set title 'meta-llama/Llama-4-Scout-17B-16E-Instruct'
set xlabel 'Maximum Request Concurrency'
set ylabel 'Output Token Throughput (tokens/s)'

set pointsize 1.25
set logscale x 2
#set logscale y 10
set xrange [.9:1050]
set yrange [10:]
#set key top left
set key at screen 0.7,0.93

datafile = 'results.dat'

plot \
    datafile using 1:2 title "Hops HPC, Run 1    (hops15)"    with linespoints lw 3 lc rgb 'red', \
    datafile using 1:3 title "Hops HPC, Run 2    (hops15)"    with linespoints lw 3 lc rgb 'orange', \
    datafile using 1:4 title "Eldorado HPC, Run 1 (eldo1002)" with linespoints lw 3 lc rgb 'green', \
    datafile using 1:5 title "Eldorado HPC, Run 2 (eldo1007)" with linespoints lw 3 lc rgb 'blue', \

set output
