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
# list of sizes
set tags = ('PW50' 'PW25' 'PW10' 'PW5')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/analysis/dropsonde_plots_flights_wrf/'
set outdir = $maindir'PBL_compare_MYNN2.5_UW'
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# start variable loop
##############
set q = 1
while ($q <= 8)  # max 8

set t = 1
while ($t <= 4)
##############
# Input into ncl
##############
        echo 'Processing plots for '$names[$q]' and '$tags[$t]
   ncl 'name               = "'$names[$q]'"'\
       'tag            = "'$tags[$t]'"' \
       ${maindir}dropsonde_plots_compare_PBL.ncl
   mv *.png $outdir
   rm *.ps
@ t ++
end
@ q ++
end

