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
set varcode  = ('SH' 'LH' 'T_2m' 'T_sfc' 'SWNet' 'LWNet' 'RadNet' 'ENet')
set dates    = ('21_13-40' '21_20-20' '21_23-00')

set tag0 = 'PW-05-40-M-bn'
set tag1 = 'PW-05-60-M-bn'
set tag2 = 'PW-10-40-M-bn'
set tag3 = 'PW-25-40-M-bn'
set tag4 = 'PW-50-40-M-bn'

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/'
set indir = $maindir'DATA/'$tag0'/wrfout-cf/'

##############
# start variable loop
##############
set q = 1
while ($q <= 8)  # max 8

set d = 1
while ($d <= 1)
   set date = '2015-05-'$dates[$d]

   # Input into ncl
   echo 'Processing plots for '$varcode[$q]' and '$date
   ncl 'date               = "'$date'"'\
       'varcode            = "'$varcode[$q]'"' \
       'tag0               = "'$tag0'"' \
       'tag1               = "'$tag1'"' \
       'tag2               = "'$tag2'"' \
       'tag3               = "'$tag3'"' \
       'tag4               = "'$tag4'"' \
       ./sfc_flux_diffs.ncl
   rm *.ps
@ d ++
end
@ q ++
end

