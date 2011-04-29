set terminal postscript "Arial" 30;
set size ratio +0.8;

set style line 1 lt 1 lw 3;
set style line 2 lt 2 lw 3;
set style line 3 lt 3 lw 3;
set style line 4 lt 6 lw 3;
set style line 5 lt 1 lw 2;
set style line 6 lt 2 lw 2;
set style line 7 lt 3 lw 2;
set style line 8 lt 6 lw 2;
set pointsize 2.0;

set lmargin 3
set bmargin 2
set rmargin 0
set tmargin 1

set grid
set style data linespoints;
set key right bottom;

set logscale x;
set xrange [0.022:1.3];
set xlabel "learning sample (%)";
set xtics nomirror norotate ("3" 0.03, "6" 0.06, "12.5" 0.125, "25" 0.25, "50" 0.5, "100" 1.0);

set yrange [0.35:1.02];
set ylabel "accuracy";
set ytics nomirror norotate 0.5,0.1,1.0
set output "accuracy.eps";

################################################################################ All
set title 'target size = 32';
plot 'accuracy.dat' every ::1::6 using 3:5  title "Blue-fringe" with lp ls 1, \
     'accuracy.dat' every ::19::24 using 3:5  title "RPNI" with lp ls 2;

set title 'target size = 64';
plot 'accuracy.dat' every ::7::12 using 3:5  title "Blue-fringe" with lp ls 1, \
     'accuracy.dat' every ::25::30 using 3:5  title "RPNI" with lp ls 2;

set title 'target size = 128';
plot 'accuracy.dat' every ::13::18 using 3:5  title "Blue-fringe" with lp ls 1, \
     'accuracy.dat' every ::31::36 using 3:5  title "RPNI" with lp ls 2;

