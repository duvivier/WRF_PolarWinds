#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# Choose location
##############
set days  = ('20' '21' '22')
set hours  = ('00' '06' '12' '18')

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
set h = 1
while ($h <= 4)

set outdir = $maindir'figures/era_wrf_all_res'
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# Input into ncl
##############
        echo 'Processing plots for '$days[$d]' '$hours[$h]
   ncl 'dd            = "'$days[$d]'"'\
       'hh            = "'$hours[$h]'"' \
       ${maindir}era_i_wrf_all_res_compare.ncl
   mv *.png $outdir
   rm *.ps

@ h ++
end
@ d ++
end

