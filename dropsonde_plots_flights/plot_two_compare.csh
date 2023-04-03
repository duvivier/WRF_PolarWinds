#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
# set simulation info
set tag1 = 'PW-10'
set tag2 = 'PW-10'
set vert1 = '40'
set vert2 = '40'
set pbl1 = 'U'
set pbl2 = 'M'

##############
# Choose location
##############
set names  = ('190950' '192456' '194625' '201031' '203004' '204411' '205909' '211845')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/analysis/dropsonde_plots_flights_wrf/'
set outdir = $maindir'figures/'$tag1'-'$vert1'-'$pbl1'-vs-'$tag2'-'$vert2'-'$pbl2
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 1
while ($q <= 8)  # max 8
##############
# Input into ncl
##############
        echo 'Processing plots for '$names[$q]
   ncl 'name               = "'$names[$q]'"'\
       'tag1               = "'$tag1'"' \
       'tag2               = "'$tag2'"' \
       'vert1              = "'$vert1'"' \
       'vert2              = "'$vert2'"' \
       'pbl1               = "'$pbl1'"' \
       'pbl2               = "'$pbl2'"' \
       ${maindir}dropsonde_plots_compare_two.ncl
   mv *.png $outdir
   rm *.ps
@ q ++
end

