#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# Choose location
##############
set tags = ('PW-50-40-M-bn')
#set tags  = ('PW-50-40-M-bn' 'PW-25-40-M-bn' 'PW-10-40-M-bn' 'PW-05-40-M-bn' 'PW-10-40-U-bn' 'PW-05-40-U-bn' 'PW-10-60-M-bn' 'PW-05-60-M-bn' 'PW-10-60-U-bn' 'PW-05-60-U-bn' 'PW-10-40-M-an' 'PW-05-40-M-an' 'PW-10-40-M-cn' 'PW-05-40-M-cn' 'PW-10-40-M-a' 'PW-05-40-M-a' 'PW-10-40-M-b' 'PW-05-40-M-b' 'PW-10-40-M-c' 'PW-05-40-M-c')
set dates = ('20_12-00' '20_14-00' '20_20-00' '20_20-40' '21_11-00' '21_13-40' '21_20-20' '21_23-00')

##############
# start variable loop
##############
set t = 1
while ($t <= 1)
set d = 1
while ($d <= 8)

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/'
set outdir = $maindir'DATA/'$tags[$t]'/wrf2ascat/'
mkdir -p $outdir
echo 'Now running for '$outdir

set rundir = $maindir'analysis/regridding/ascat/'

# set date
set date = '2015-05-'$dates[$d]

##############
# Input into ncl
##############
        echo 'Regridding to ASCAT for '$tags[$t]' '$date
   ncl 'tag            = "'$tags[$t]'"'\
       'date           = "'$date'"' \
       ${rundir}regrid_WRF_to_ASCAT.ncl

   # remove ESMF weight file
   rm ESMF_wgt-WRF_to_ASCAT.nc

@ d ++
end
@ t ++
end

