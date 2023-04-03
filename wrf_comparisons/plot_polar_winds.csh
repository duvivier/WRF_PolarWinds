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
set varcode  = ('WS' 'SLP' 'T2m' 'LH' 'SH' 'SWDS' 'SWUS' 'LWDS' 'LWUS' 'precip')
set pbl = 'U'

##############
# Choose hour and minute
##############
# list of hours
set hours = ('18' '19' '20' '21' '22' '23')
# list of minutes
set minutes = ('00' '20' '40')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/analysis/fourpanel_comparisons/'
set outdir = $maindir'figures'
mkdir -p $outdir
echo 'Now running for '$outdir
set outdir1 = $outdir'/Greenland'
set outdir2 = $outdir'/Denmark_Strait'
mkdir -p $outdir1
mkdir -p $outdir2

##############
# start variable loop
##############
set q = 10
while ($q <= 10)  # max 10

set h = 1
while ($h <= 6)
set hh = $hours[$h]

set m = 1
while ($m <= 3)
set mn = $minutes[$m] 

set date = "2015-05-21_"$hh"-"$mn
#echo $date
##############
# Input into ncl
##############
        echo 'Processing plots for '$varcode[$q]' and '$date
   ncl 'date               = "'$date'"'\
       'varcode            = "'$varcode[$q]'"' \
       'pbl                = "'$pbl'"' \
       ${maindir}pw_fourpanel.ncl
   mv *zoom*.png $outdir2
   mv *.png $outdir1
   rm *.ps
@ m ++
end
@ h ++
end
@ q ++
end

