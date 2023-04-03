#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# Choose location
##############
set days  = ('20' '21')
set pass  = ('ASC' 'DES')
set sat   = ('A' 'B')
set tags  = ('40-M' '40-U')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/analysis/ASCAT_comparisons/'
set outdir = $maindir'figures/ASCAT_WRF_resolution_compare'
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# start variable loop
##############
set d = 1
while ($d <= 2)
set p = 1
while ($p <= 2)
set s = 1
while ($s <= 2)
set t = 1
while ($t <= 2)

##############
# Input into ncl
##############
        echo 'Processing plots for '$names[$q]' and '$tags[$t]
   ncl 'day            = "'$days[$d]'"'\
       'pass           = "'$pass[$p]'"' \
       'sat            = "'$sat[$s]'"' \
       'tag            = "'$tags[$t]'"' \
       ${maindir}ascat_wrf_all_res_compare.ncl
   mv *.png $outdir
   rm *.ps

@ d ++
end
@ p ++
end
@ s ++
end
@ t ++
end

