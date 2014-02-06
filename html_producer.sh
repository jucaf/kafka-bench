#!/bin/bash
WD="/root/benchmark"
OUTPUT="${WD}/HTML-`date +%s`"
mkdir -p $OUTPUT
echo "<HTML><BODY>" > ${OUTPUT}/index.html

for i in `ls $WD | grep -v HTML`; do mkdir "${OUTPUT}/${i}"; for j in `ls ${WD}/${i}/`; do gnuplot44 -e "set terminal canvas enhanced mousing jsdir '/gnuplot/js'; set dgrid3d 5,10;set xlabel \"producers\"; set ylabel \"msg_size\"; set zlabel \"msg\"; set style data lines; set pm3d; splot \"${WD}/${i}\/${j}\" using 1:3:8" > "${OUTPUT}/${i}/${j}.html"; echo "<a href=\"./${i}/${j}.html\" target=\"_blank\">${i}/${j}</a><br/>">>${OUTPUT}/index.html; done ; done

echo "</BODY></HTML>" >> ${OUTPUT}/index.html
