#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# Choose location
##############
set names  = ('190950' '192456' '194625' '201031' '203004' '204411' '205909' '211845')

##############
# Choose resolution
##############
# list of PBS
set tags = ('U' 'M')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/analysis/dropsonde_plots_flights_wrf/'

##############
# start variable loop
##############
set q = 1
while ($q <= 8)  # max 8

set t = 1
while ($t <= 2)

set outdir = $maindir'figures/PBL_compare_res_'$tags[$t]
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# Input into ncl
##############
        echo 'Processing plots for '$names[$q]' and '$tags[$t]
   ncl 'name           = "'$names[$q]'"'\
       'pbl            = "'$tags[$t]'"' \
       ${maindir}dropsonde_plots_w_wrf.ncl
   mv *.png $outdir
   rm *.ps
@ t ++
end
@ q ++
end

