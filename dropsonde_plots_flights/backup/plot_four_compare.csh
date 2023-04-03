#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
# set simulation info
set tags1 = ('PW-05-40-U-bn')
set tags2 = ('PW-10-40-U-bn')
set tags3 = ('PW-05-60-U-bn')
set tags4 = ('PW-10-60-U-bn')

##############
# Choose location
##############
set names  = ('190950' '192456' '194625' '201031' '203004' '204411' '205909' '211845')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/analysis/dropsonde_plots_flights_wrf/'
set outdir = $maindir'figures/compare_vert_resolution-UW/'
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# start loops
##############
set q = 1
while ($q <= 8)  # max 8

set t = 1
while ($t <= 1)

##############
# Input into ncl
##############
        echo 'Processing plots for '$names[$q]' and' $tags1[$t]
   ncl 'name               = "'$names[$q]'"'\
       'tag1               = "'$tags1[$t]'"' \
       'tag2               = "'$tags2[$t]'"' \
       'tag3               = "'$tags3[$t]'"' \
       'tag4               = "'$tags4[$t]'"' \
       ${maindir}dropsonde_plots_compare_four.ncl
   mv *.png $outdir
   rm *.ps

@ t ++
end

@ q ++
end

