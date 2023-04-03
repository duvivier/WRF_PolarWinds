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
set tags1 = ('PW-10-40-M' 'PW-10-60-M' 'PW-05-40-M' 'PW-05-60-M' 'PW-10-40-M' 'PW-10-40-U' 'PW-05-40-M' 'PW-05-40-U')
set tags2 = ('PW-10-40-U' 'PW-10-60-M' 'PW-05-40-U' 'PW-05-60-U' 'PW-10-60-M' 'PW-10-60-U' 'PW-05-60-M' 'PW-05-60-U')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/analysis/ASCAT_comparisons/'

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
while ($t <= 8)

set outdir = $maindir'figures/'$tags1[$t]'-vs-'$tags2[$t]
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# Input into ncl
##############
        echo 'Processing plots for '$days[$d]' '$pass[$p]' '$sat[$s]
   ncl 'day            = "'$days[$d]'"'\
       'pass           = "'$pass[$p]'"' \
       'sat            = "'$sat[$s]'"' \
       'tag1           = "'$tags1[$t]'"' \
       'tag2           = "'$tags2[$t]'"' \
       ${maindir}ascat_wrf_one_res_compare.ncl
   mv *.png $outdir
   rm *.ps

@ t ++
end
@ s ++
end
@ p ++
end
@ d ++
end

