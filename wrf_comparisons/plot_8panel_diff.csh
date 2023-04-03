#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# Choose Variables
##############
# list what variable(s) you want the ncl script to output (42 tot)
# WRF vars are WS through Q_anom2 (13)
# POP vars are WSC through HMXL_28 (29)
set varcode  = ('WS' 'SLP' 'T2m' 'LH' 'SH' 'SWDS' 'LWDS' 'precip')

set tag0 = 'PW-05-40-M-bn'
set tag1 = 'PW-10-40-M-bn'
set tag2 = 'PW-25-40-M-bn'
set tag3 = 'PW-50-40-M-bn'

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/'
set rundir = $maindir'analysis/wrf_comparisons/'
set indir = $maindir'DATA/'$tag0'/wrfout-cf/'
set outdir1 = $rundir'figures/WRF_resolution_compare/Denmark_Strait'
set outdir2 = $rundir'figures/WRF_resolution_compare/Greenland'
mkdir -p $outdir1
mkdir -p $outdir2
echo 'Now running for '$outdir1

##############
# start variable loop
##############
set q = 1
while ($q <= 8)  # max 8

foreach wrf_file (`ls -1 $indir`)
    echo "Let's go for: "$wrf_file
    set date = `echo $wrf_file | cut -c5-20`

   # Input into ncl
   echo 'Processing plots for '$varcode[$q]' and '$date
   ncl 'date               = "'$date'"'\
       'varcode            = "'$varcode[$q]'"' \
       'tag0               = "'$tag0'"' \
       'tag1               = "'$tag1'"' \
       'tag2               = "'$tag2'"' \
       'tag3               = "'$tag3'"' \
       ${rundir}pw_eightpanel_diffs.ncl
   mv *zoom*.png $outdir1
   mv *.png $outdir2
   rm *.ps
end

@ q ++
end

