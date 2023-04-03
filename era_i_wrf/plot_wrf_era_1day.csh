#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# Choose location
##############
set days  = ('20' '21')
set tags  = ('PW-05-40-M-bn' 'PW-10-40-M-bn' 'PW-25-40-M-bn' 'PW-50-40-M-bn')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/analysis/era_i_wrf/'

##############
# start variable loop
##############
set d = 1
while ($d <= 2)
set t = 1
while ($t <= 4)

set outdir = $maindir'figures/era_wrf_one_day'
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# Input into ncl
##############
        echo 'Processing plots for '$days[$d]' '$tags[$t]
   ncl 'day             = "'$days[$d]'"'\
       'tagb            = "'$tags[$t]'"' \
       ${maindir}era_i_wrf-slp_wind.ncl
   mv *.png $outdir
   rm *.ps

@ t ++
end
@ d ++
end

