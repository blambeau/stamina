ruby results2csv.rb | dba bulk:import --truncate --csv --headers --separator=';' submissions
dba bulk:export --separator=' ' accuracy_avg > analysis/accuracy.dat
dba bulk:export --separator=' ' time_avg > analysis/time.dat
cd analysis && gnuplot *.gnuplot && ps2pdf *.eps
cd ..
