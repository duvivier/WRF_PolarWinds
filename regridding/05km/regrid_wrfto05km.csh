#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# Choose location
##############
set tags  = ('PW-50-40-M-bn' 'PW-25-40-M-bn' ) #'PW-10-40-M-bn')
#('PW-50-40-M-bn' 'PW-25-40-M-bn' 'PW-10-40-M-bn' 'PW-10-40-U-bn' 'PW-10-60-M-bn' 'PW-10-60-U-bn' 'PW-10-40-M-an' 'PW-10-40-M-cn' 'PW-10-40-M-a' 'PW-10-40-M-b' 'PW-10-40-M-c')

##############
# start variable loop
##############
set t = 1
while ($t <= 2)

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/'
set rundir = $maindir'analysis/regridding/05km/'
set indir = $maindir'DATA/'$tags[$t]'/wrfout-cf/'
set outdir = $maindir'DATA/'$tags[$t]'/wrfto05km/'
mkdir -p $outdir
echo 'Now running for '$outdir

foreach wrf_file (`ls -1 $indir`)

    echo "Let's go for: "$wrf_file
    set date = `echo $wrf_file | cut -c5-20`

   # Input into ncl
   echo 'Regridding to 5km for '$tags[$t]' '$date
   ncl 'tag            = "'$tags[$t]'"'\
       'date           = "'$date'"' \
       ${rundir}regrid_WRF_to_05kmWRF.ncl

   # remove ESMF weight file
   rm ESMF_wgt-WRF_to_05km.nc

end

@ t ++
end

