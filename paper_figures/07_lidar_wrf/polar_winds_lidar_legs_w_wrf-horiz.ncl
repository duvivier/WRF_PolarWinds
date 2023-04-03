;***************************************
; PROGRAM DESCRIPTION: This NCL script makes cross section plots of WRF data
; INPUT DATA: WRF output of any resolution
; OUTPUT DATA: spatial plot of cross section location and cross section
; Note: loop this script with 02_21FEB_15Z.csh
; CREATORS: Alice DuVivier - April 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
;MANUAL INPUTS - for testing purposes
pass = "D"
fname1 = "PW-05-40-M-bn"
tag1 = "W05-40-M"
fname2 = "PW-05-60-M-bn"
tag2 = "W05-60-M"
fname3 = "PW-05-40-U-bn"
tag3 = "W05-40-U"
fname4 = "PW-05-60-U-bn"
tag4 = "W05-60-U"
cressrad = 5.0

;;;;;;;;;;;;;;;;;;;;;
; information about each pass. 
; Note that all passes "begin" on the landside. However, we aren't using these points to set the legs, instead use the lidar lat/lon data
if (pass .eq. "A")then
  n_s = 294.0
  n_e = 309.0
  npts = 35
end if
if (pass .eq. "B")then
  n_s = 314.0
  n_e = 324.0
  npts = 25
end if
if (pass .eq. "C")then
  n_s = 364.0
  n_e = 372.0
  npts = 19
end if
if (pass .eq. "D")then
  n_s = 377.0
  n_e = 389.0
  npts = 22
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load lidar data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Loading data for flight leg "+pass)
files = systemfunc("ls /data/duvivier/polar_winds/DATA/DAWN_PROFS_NOTFINAL/*.csv")
ndates = dimsizes(files)
prof_num = new((/ndates/),integer)
n = 0
do n = 0, ndates-1
   dum1 = stringtochar(files(n))
   dum2 = chartostring(dum1(75:77))
   dum3 = stringtoint(dum2)
   prof_num(n) = dum3
   delete([/dum1,dum2,dum3/])
end do

; load only files for this particular leg
inds = ind(prof_num.ge.n_s .and. prof_num.le.n_e)

files_sub = files(inds)
delete(inds)
ndates_sub = dimsizes(files_sub)
nvert = 60
delim = ","
hgt = new((/nvert,ndates_sub/),"float")
wd = new((/nvert,ndates_sub/),"float")
ws = new((/nvert,ndates_sub/),"float")
u  = new((/nvert,ndates_sub/),"float")
v  = new((/nvert,ndates_sub/),"float")
lat = new((/nvert,ndates_sub/),"float")
lon = new((/nvert,ndates_sub/),"float")

n = 0
do n = 0, ndates_sub -1
   f1 = asciiread(files_sub(n),-1,"string")
   tmp = tofloat(str_get_field(f1,1,delim))
   dimz = dimsizes(tmp)
   hgt(0:dimz-1,n) = tofloat(str_get_field(f1,1,delim))
   wd(0:dimz-1,n) = tofloat(str_get_field(f1,2,delim))
   ws(0:dimz-1,n) = tofloat(str_get_field(f1,3,delim))
   u(0:dimz-1,n) = tofloat(str_get_field(f1,4,delim))
   v(0:dimz-1,n) = tofloat(str_get_field(f1,5,delim))
   lat(0:dimz-1,n) = tofloat(str_get_field(f1,10,delim))
   lon(0:dimz-1,n) = tofloat(str_get_field(f1,11,delim))
   delete([/f1,tmp,dimz/])
end do

; reverse the start points for legs A, C, or E so that the side near land is the start of the cross section
if (pass.eq."A" .or. pass.eq."C")then
   hgt = hgt(:,::-1)
   wd  = wd(:,::-1)
   ws  = ws(:,::-1)
   u   = u(:,::-1)
   v   = v(:,::-1)
   lat = lat(:,::-1)
   lon = lon(:,::-1)
end if

; get start and end points for legs.
  st_lat = lat(0,0)
  st_lon = lon(0,0)
  ed_lat = lat(0,ndates_sub-1)
  ed_lon = lon(0,ndates_sub-1)

; flip these around so that the lowest heights are at the bottom of the arrays (missing data is nearer surface)
  hgt = hgt(::-1,:)
  wd  = wd(::-1,:)
  ws  = ws(::-1,:)
  u   = u(::-1,:)
  v   = v(::-1,:)

; get distances of each lidar profile along this cross section
  dist_lidar = new((/ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub -1
     dist_lidar(n) = gc_latlon(st_lat, st_lon,lat(0,n),lon(0,n),2,4)
  end do
  y_lidar = dist_lidar
  y_lidar = 20.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Create regular grid to interpolate to
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Interpolating to cross section line")
; NOTE: npts for each leg has been chosen above to lead to 2km spacing for each pass

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat, st_lon, ed_lat, ed_lon, npts, 4)
   lats = length@gclat          ; the lats of the points interpolating to
   lons = length@gclon          ; the lons of the points interpolating to
   space_leg = length@spacing       ; the spacing of the points in integer km 
   n_cross = dimsizes(lats)

  ; create regular horizontal distance array to plot values
   dist_grid = new((/n_cross/),"float")
   km = 0.
   n = 0
   do n = 0, n_cross-1
     dist_grid(n) = km
     km = km + space_leg
   end do
   dist_grid!0 = "Horizontal"
   dist_grid@units = "km" 

  ; create vertical spacing in meters
  n_lev = 5000
  n_space = 50   ; 10
  hgt_grid = ispan(0,n_lev,n_space)
  hgt_grid!0 = "Vertical"
  hgt_grid@units = "m"
  n_hgts = dimsizes(hgt_grid)

  ; interpolate lidar data to regular vertical grid before 2d interpolation
  ws_new_1 = new((/n_hgts,ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub-1
    ; use only indicies where heights are not missing
    inds = ind(.not.ismissing(hgt(:,n)))
    xi = hgt(inds,n)
    ws_sub = ws(inds,n)
    ws_new_1(:,n) = linint1_Wrap(xi,ws_sub,False,hgt_grid,0)
    delete([/inds,xi,ws_sub/])
  end do
  
  ; now interpolate lidar data to regular horizontal grid
  ws_lidar = linint2_Wrap(dist_lidar,hgt_grid,ws_new_1,False,dist_grid,hgt_grid,0)
  delete([/u,v,ws,ws_new_1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Interpolate WRF simulations to the cross section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set cressman radii
max_indicies = 5   ; want nearest 5 pts or less

; set WRF time for pass observations
if(pass.eq."A" .or. pass.eq."B")then
  date = "2015-05-21_20-20"
end if
if(pass.eq."C" .or. pass.eq."D")then
  date = "2015-05-21_21-00"
end if

; location of all WRF data
dir = "/data/duvivier/polar_winds/DATA/"

;;;;;;;;;;;;
; First file
;;;;;;;;;;;;
print("interpolating "+fname1+" to flight path pass "+pass)
fin = addfile(dir+fname1+"/wrfout-cf/wrf-"+date+"."+fname1+"-cf.nc","r")
lat2d = fin->lat
lon2d = fin->lon
eta = fin->eta
n_eta = dimsizes(eta)
Z_sfc = fin->Z_sfc
Z_e = fin->Z_e(0,:,:,:)
u = fin->u_tr_e
v = fin->v_tr_e
ws_tmp = sqrt(u^2 + v^2)
copy_VarMeta(u,ws_tmp)
ws_e = ws_tmp(0,:,:,:)
delete([/u,v,ws_tmp/])

; horizontally interpolate
interp_ind = new((/n_cross,max_indicies/),"integer")
interp_wgt = new((/n_cross,max_indicies/),"integer")
ws_sub = new((/n_eta,n_cross/),"float")
Z_e_sub = new((/n_eta,n_cross/),"float")
Z_sfc_sub = new((/n_cross/),"float")

lat1d = ndtooned(lat2d)
lon1d = ndtooned(lon2d)
Z_sfc_1d = ndtooned(Z_sfc)

i = 0
j = 0
; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from line to points on grid
    dist_rad = gc_latlon(lats(i),lons(i),lat1d, lon1d, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc)
    if (any(isnan_ieee(dist_rad))) then       
      nreplacements = num(isnan_ieee(dist_rad))  ; find index of NaN
      replace_ieeenan(dist_rad,0.,0)             ; replace the NaN with 0
      print("replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad).gt.cressrad) then        
      print("Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    indicies = ind(dist_rad.lt.cressrad)    ; indicies where distance is in cressman radius
    weight = (cressrad^2 - dist_rad(indicies)^2) / (cressrad^2 + dist_rad(indicies)^2)  ; give each index a weight

    ; calculate surface height subset
    Z_sfc_sub(i)  = sum(Z_sfc_1d(indicies)*weight)/sum(weight)

    ; calculate the new variable and geopotential heights
    do j = 0, n_eta-1
      ; flatten the eta level of interest 
      ws_1d = ndtooned(ws_e(j,:,:))    
      Z_e_1d  = ndtooned(Z_e(j,:,:))
      ; calculate new array for variable and geopZ
      ws_sub(j,i) =  sum(ws_1d(indicies)*weight)/sum(weight)
      Z_e_sub(j,i)  =  sum(Z_e_1d(indicies)*weight)/sum(weight)
      delete([/ws_1d,Z_e_1d/])
    end do
    delete([/dist_rad,indicies,weight/])
    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do

  copy_VarAtts(ws_e, ws_sub)
  copy_VarAtts(Z_e, Z_e_sub)
  copy_VarAtts(Z_sfc, Z_sfc_sub)

; vertically interpolate
ws_interp = new((/n_hgts,n_cross/),"float")
copy_VarMeta(ws_lidar, ws_interp)
d = 0
h = 0
do d = 0, n_cross-1                   ; Loop through each point along distance
   do h = 0, n_hgts-1                 ; Loop through each height to be interpolated to
     if (Z_sfc_sub(d) .lt. hgt_grid(h)) then    ; If height to interp. to is above surface proceed
       f=0                                      
       if (Z_e_sub(f,d) .lt. hgt_grid(h)) then  ; If height to interp. to  is above first eta level proceed
         ; Find first eta level (f) above height to interpolate to
         do  while (Z_e_sub(f,d) .lt. hgt_grid(h))
           f=f+1                         ; f now = the first level above height to interpolate to 
         end do
	 ; get eta levels of interest
         A_hgt = Z_e_sub(f-1,d)          ; height of the eta level below the height to interpolate to
         B_hgt = Z_e_sub(f,d)            ; height of the eta level above the height to interpolate to
         C_hgt = hgt_grid(h)                 ; height to interpolate to
         total_dist = B_hgt - A_hgt      ; total dist. between eta levels surrounding the height to interp. to
	 ; find if variable is increasing or decreasing here
         if (ws_sub(f,d) .gt. ws_sub(f-1,d)) then
           ; if variable increases with height linearly interp.  
           wt = (C_hgt-A_hgt)/total_dist      ;; wt is a weighting factor 
           ws_interp(h,d) = ws_sub(f-1,d)+((ws_sub(f,d)-ws_sub(f-1,d))*wt)
         else  
           ; if variable decreases with height linearly interp.                                
           wt = (B_hgt-C_hgt)/total_dist
           ws_interp(h,d) = ws_sub(f,d)+((ws_sub(f-1,d)-ws_sub(f,d))*wt)
         end if
       else
         ; if the height to interpolate to is below the first eta level, fill with missing value.
         ws_interp(h,d)= ws_interp@_FillValue
       end if
    else
      ; if the height to interpolate to is below the surface, enter a fill value
      ws_interp(h,d)= ws_interp@_FillValue
    end if
  end do
  delete([/f,A_hgt,B_hgt,C_hgt,total_dist,wt/])
    ; Counter
    if(d%10.eq.0) then
      print("created vert levels for "+d+" of "+n_cross)
    end if
end do
ws_wrf1 = ws_interp
delete([/fin,lat2d,lon2d,eta,n_eta,Z_sfc,Z_e,ws_e,interp_ind,interp_wgt,ws_sub,Z_e_sub,Z_sfc_sub,lat1d,lon1d,Z_sfc_1d,ws_interp/])

;;;;;;;;;;;;
; Second file
;;;;;;;;;;;;
print("interpolating "+fname2+" to flight path pass "+pass)
fin = addfile(dir+fname2+"/wrfout-cf/wrf-"+date+"."+fname2+"-cf.nc","r")
lat2d = fin->lat
lon2d = fin->lon
eta = fin->eta
n_eta = dimsizes(eta)
Z_sfc = fin->Z_sfc
Z_e = fin->Z_e(0,:,:,:)
u = fin->u_tr_e
v = fin->v_tr_e
ws_tmp = sqrt(u^2 + v^2)
copy_VarMeta(u,ws_tmp)
ws_e = ws_tmp(0,:,:,:)
delete([/u,v,ws_tmp/])

; horizontally interpolate
interp_ind = new((/n_cross,max_indicies/),"integer")
interp_wgt = new((/n_cross,max_indicies/),"integer")
ws_sub = new((/n_eta,n_cross/),"float")
Z_e_sub = new((/n_eta,n_cross/),"float")
Z_sfc_sub = new((/n_cross/),"float")

lat1d = ndtooned(lat2d)
lon1d = ndtooned(lon2d)
Z_sfc_1d = ndtooned(Z_sfc)

i = 0
j = 0
; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from line to points on grid
    dist_rad = gc_latlon(lats(i),lons(i),lat1d, lon1d, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc)
    if (any(isnan_ieee(dist_rad))) then       
      nreplacements = num(isnan_ieee(dist_rad))  ; find index of NaN
      replace_ieeenan(dist_rad,0.,0)             ; replace the NaN with 0
      print("replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad).gt.cressrad) then        
      print("Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    indicies = ind(dist_rad.lt.cressrad)    ; indicies where distance is in cressman radius
    weight = (cressrad^2 - dist_rad(indicies)^2) / (cressrad^2 + dist_rad(indicies)^2)  ; give each index a weight

    ; calculate surface height subset
    Z_sfc_sub(i)  = sum(Z_sfc_1d(indicies)*weight)/sum(weight)

    ; calculate the new variable and geopotential heights
    do j = 0, n_eta-1
      ; flatten the eta level of interest 
      ws_1d = ndtooned(ws_e(j,:,:))    
      Z_e_1d  = ndtooned(Z_e(j,:,:))
      ; calculate new array for variable and geopZ
      ws_sub(j,i) =  sum(ws_1d(indicies)*weight)/sum(weight)
      Z_e_sub(j,i)  =  sum(Z_e_1d(indicies)*weight)/sum(weight)
      delete([/ws_1d,Z_e_1d/])
    end do
    delete([/dist_rad,indicies,weight/])
    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do

  copy_VarAtts(ws_e, ws_sub)
  copy_VarAtts(Z_e, Z_e_sub)
  copy_VarAtts(Z_sfc, Z_sfc_sub)

; vertically interpolate
ws_interp = new((/n_hgts,n_cross/),"float")
copy_VarMeta(ws_lidar, ws_interp)
d = 0
h = 0
do d = 0, n_cross-1                   ; Loop through each point along distance
   do h = 0, n_hgts-1                 ; Loop through each height to be interpolated to
     if (Z_sfc_sub(d) .lt. hgt_grid(h)) then    ; If height to interp. to is above surface proceed
       f=0                                      
       if (Z_e_sub(f,d) .lt. hgt_grid(h)) then  ; If height to interp. to  is above first eta level proceed
         ; Find first eta level (f) above height to interpolate to
         do  while (Z_e_sub(f,d) .lt. hgt_grid(h))
           f=f+1                         ; f now = the first level above height to interpolate to 
         end do
	 ; get eta levels of interest
         A_hgt = Z_e_sub(f-1,d)          ; height of the eta level below the height to interpolate to
         B_hgt = Z_e_sub(f,d)            ; height of the eta level above the height to interpolate to
         C_hgt = hgt_grid(h)                 ; height to interpolate to
         total_dist = B_hgt - A_hgt      ; total dist. between eta levels surrounding the height to interp. to
	 ; find if variable is increasing or decreasing here
         if (ws_sub(f,d) .gt. ws_sub(f-1,d)) then
           ; if variable increases with height linearly interp.  
           wt = (C_hgt-A_hgt)/total_dist      ;; wt is a weighting factor 
           ws_interp(h,d) = ws_sub(f-1,d)+((ws_sub(f,d)-ws_sub(f-1,d))*wt)
         else  
           ; if variable decreases with height linearly interp.                                
           wt = (B_hgt-C_hgt)/total_dist
           ws_interp(h,d) = ws_sub(f,d)+((ws_sub(f-1,d)-ws_sub(f,d))*wt)
         end if
       else
         ; if the height to interpolate to is below the first eta level, fill with missing value.
         ws_interp(h,d)= ws_interp@_FillValue
       end if
    else
      ; if the height to interpolate to is below the surface, enter a fill value
      ws_interp(h,d)= ws_interp@_FillValue
    end if
  end do
  delete([/f,A_hgt,B_hgt,C_hgt,total_dist,wt/])
    ; Counter
    if(d%10.eq.0) then
      print("created vert levels for "+d+" of "+n_cross)
    end if
end do
ws_wrf2 = ws_interp
delete([/fin,lat2d,lon2d,eta,n_eta,Z_sfc,Z_e,ws_e,interp_ind,interp_wgt,ws_sub,Z_e_sub,Z_sfc_sub,lat1d,lon1d,Z_sfc_1d,ws_interp/])

;;;;;;;;;;;;
; Third file
;;;;;;;;;;;;
print("interpolating "+fname3+" to flight path pass "+pass)
fin = addfile(dir+fname3+"/wrfout-cf/wrf-"+date+"."+fname3+"-cf.nc","r")
lat2d = fin->lat
lon2d = fin->lon
eta = fin->eta
n_eta = dimsizes(eta)
Z_sfc = fin->Z_sfc
Z_e = fin->Z_e(0,:,:,:)
u = fin->u_tr_e
v = fin->v_tr_e
ws_tmp = sqrt(u^2 + v^2)
copy_VarMeta(u,ws_tmp)
ws_e = ws_tmp(0,:,:,:)
delete([/u,v,ws_tmp/])

; horizontally interpolate
interp_ind = new((/n_cross,max_indicies/),"integer")
interp_wgt = new((/n_cross,max_indicies/),"integer")
ws_sub = new((/n_eta,n_cross/),"float")
Z_e_sub = new((/n_eta,n_cross/),"float")
Z_sfc_sub = new((/n_cross/),"float")

lat1d = ndtooned(lat2d)
lon1d = ndtooned(lon2d)
Z_sfc_1d = ndtooned(Z_sfc)

i = 0
j = 0
; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from line to points on grid
    dist_rad = gc_latlon(lats(i),lons(i),lat1d, lon1d, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc)
    if (any(isnan_ieee(dist_rad))) then       
      nreplacements = num(isnan_ieee(dist_rad))  ; find index of NaN
      replace_ieeenan(dist_rad,0.,0)             ; replace the NaN with 0
      print("replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad).gt.cressrad) then        
      print("Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    indicies = ind(dist_rad.lt.cressrad)    ; indicies where distance is in cressman radius
    weight = (cressrad^2 - dist_rad(indicies)^2) / (cressrad^2 + dist_rad(indicies)^2)  ; give each index a weight

    ; calculate surface height subset
    Z_sfc_sub(i)  = sum(Z_sfc_1d(indicies)*weight)/sum(weight)

    ; calculate the new variable and geopotential heights
    do j = 0, n_eta-1
      ; flatten the eta level of interest 
      ws_1d = ndtooned(ws_e(j,:,:))    
      Z_e_1d  = ndtooned(Z_e(j,:,:))
      ; calculate new array for variable and geopZ
      ws_sub(j,i) =  sum(ws_1d(indicies)*weight)/sum(weight)
      Z_e_sub(j,i)  =  sum(Z_e_1d(indicies)*weight)/sum(weight)
      delete([/ws_1d,Z_e_1d/])
    end do
    delete([/dist_rad,indicies,weight/])
    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do

  copy_VarAtts(ws_e, ws_sub)
  copy_VarAtts(Z_e, Z_e_sub)
  copy_VarAtts(Z_sfc, Z_sfc_sub)

; vertically interpolate
ws_interp = new((/n_hgts,n_cross/),"float")
copy_VarMeta(ws_lidar, ws_interp)
d = 0
h = 0
do d = 0, n_cross-1                   ; Loop through each point along distance
   do h = 0, n_hgts-1                 ; Loop through each height to be interpolated to
     if (Z_sfc_sub(d) .lt. hgt_grid(h)) then    ; If height to interp. to is above surface proceed
       f=0                                      
       if (Z_e_sub(f,d) .lt. hgt_grid(h)) then  ; If height to interp. to  is above first eta level proceed
         ; Find first eta level (f) above height to interpolate to
         do  while (Z_e_sub(f,d) .lt. hgt_grid(h))
           f=f+1                         ; f now = the first level above height to interpolate to 
         end do
	 ; get eta levels of interest
         A_hgt = Z_e_sub(f-1,d)          ; height of the eta level below the height to interpolate to
         B_hgt = Z_e_sub(f,d)            ; height of the eta level above the height to interpolate to
         C_hgt = hgt_grid(h)                 ; height to interpolate to
         total_dist = B_hgt - A_hgt      ; total dist. between eta levels surrounding the height to interp. to
	 ; find if variable is increasing or decreasing here
         if (ws_sub(f,d) .gt. ws_sub(f-1,d)) then
           ; if variable increases with height linearly interp.  
           wt = (C_hgt-A_hgt)/total_dist      ;; wt is a weighting factor 
           ws_interp(h,d) = ws_sub(f-1,d)+((ws_sub(f,d)-ws_sub(f-1,d))*wt)
         else  
           ; if variable decreases with height linearly interp.                                
           wt = (B_hgt-C_hgt)/total_dist
           ws_interp(h,d) = ws_sub(f,d)+((ws_sub(f-1,d)-ws_sub(f,d))*wt)
         end if
       else
         ; if the height to interpolate to is below the first eta level, fill with missing value.
         ws_interp(h,d)= ws_interp@_FillValue
       end if
    else
      ; if the height to interpolate to is below the surface, enter a fill value
      ws_interp(h,d)= ws_interp@_FillValue
    end if
  end do
  delete([/f,A_hgt,B_hgt,C_hgt,total_dist,wt/])
    ; Counter
    if(d%10.eq.0) then
      print("created vert levels for "+d+" of "+n_cross)
    end if
end do
ws_wrf3 = ws_interp
delete([/fin,lat2d,lon2d,eta,n_eta,Z_sfc,Z_e,ws_e,interp_ind,interp_wgt,ws_sub,Z_e_sub,Z_sfc_sub,lat1d,lon1d,Z_sfc_1d,ws_interp/])

;;;;;;;;;;;;
; Fourth file
;;;;;;;;;;;;
print("interpolating "+fname4+" to flight path pass "+pass)
fin = addfile(dir+fname4+"/wrfout-cf/wrf-"+date+"."+fname4+"-cf.nc","r")
lat2d = fin->lat
lon2d = fin->lon
eta = fin->eta
n_eta = dimsizes(eta)
Z_sfc = fin->Z_sfc
Z_e = fin->Z_e(0,:,:,:)
u = fin->u_tr_e
v = fin->v_tr_e
ws_tmp = sqrt(u^2 + v^2)
copy_VarMeta(u,ws_tmp)
ws_e = ws_tmp(0,:,:,:)
delete([/u,v,ws_tmp/])

; horizontally interpolate
interp_ind = new((/n_cross,max_indicies/),"integer")
interp_wgt = new((/n_cross,max_indicies/),"integer")
ws_sub = new((/n_eta,n_cross/),"float")
Z_e_sub = new((/n_eta,n_cross/),"float")
Z_sfc_sub = new((/n_cross/),"float")

lat1d = ndtooned(lat2d)
lon1d = ndtooned(lon2d)
Z_sfc_1d = ndtooned(Z_sfc)

i = 0
j = 0
; do loop to calculate the data subsets
  do i = 0,n_cross-1
    ; get great circle distance from line to points on grid
    dist_rad = gc_latlon(lats(i),lons(i),lat1d, lon1d, 2, 4)  

   ; if the great circle yields some NaNs (topography related, etc)
    if (any(isnan_ieee(dist_rad))) then       
      nreplacements = num(isnan_ieee(dist_rad))  ; find index of NaN
      replace_ieeenan(dist_rad,0.,0)             ; replace the NaN with 0
      print("replaced "+nreplacements+" NaN(s) with 0 at i = "+i) ; print replacements made
    end if

   ; If the minimum radius is greater than the cressman radius then it won't work 
    ;(all points outside sphere of influence.)
    if (min(dist_rad).gt.cressrad) then        
      print("Minimum distance is greater than Cressman radius at i " + i) 
      exit
    end if

    indicies = ind(dist_rad.lt.cressrad)    ; indicies where distance is in cressman radius
    weight = (cressrad^2 - dist_rad(indicies)^2) / (cressrad^2 + dist_rad(indicies)^2)  ; give each index a weight

    ; calculate surface height subset
    Z_sfc_sub(i)  = sum(Z_sfc_1d(indicies)*weight)/sum(weight)

    ; calculate the new variable and geopotential heights
    do j = 0, n_eta-1
      ; flatten the eta level of interest 
      ws_1d = ndtooned(ws_e(j,:,:))    
      Z_e_1d  = ndtooned(Z_e(j,:,:))
      ; calculate new array for variable and geopZ
      ws_sub(j,i) =  sum(ws_1d(indicies)*weight)/sum(weight)
      Z_e_sub(j,i)  =  sum(Z_e_1d(indicies)*weight)/sum(weight)
      delete([/ws_1d,Z_e_1d/])
    end do
    delete([/dist_rad,indicies,weight/])
    ; Counter
    if(i%10.eq.0) then
      print("created horizontal point "+i+" of "+n_cross)
    end if
  end do

  copy_VarAtts(ws_e, ws_sub)
  copy_VarAtts(Z_e, Z_e_sub)
  copy_VarAtts(Z_sfc, Z_sfc_sub)

; vertically interpolate
ws_interp = new((/n_hgts,n_cross/),"float")
copy_VarMeta(ws_lidar, ws_interp)
d = 0
h = 0
do d = 0, n_cross-1                   ; Loop through each point along distance
   do h = 0, n_hgts-1                 ; Loop through each height to be interpolated to
     if (Z_sfc_sub(d) .lt. hgt_grid(h)) then    ; If height to interp. to is above surface proceed
       f=0                                      
       if (Z_e_sub(f,d) .lt. hgt_grid(h)) then  ; If height to interp. to  is above first eta level proceed
         ; Find first eta level (f) above height to interpolate to
         do  while (Z_e_sub(f,d) .lt. hgt_grid(h))
           f=f+1                         ; f now = the first level above height to interpolate to 
         end do
	 ; get eta levels of interest
         A_hgt = Z_e_sub(f-1,d)          ; height of the eta level below the height to interpolate to
         B_hgt = Z_e_sub(f,d)            ; height of the eta level above the height to interpolate to
         C_hgt = hgt_grid(h)                 ; height to interpolate to
         total_dist = B_hgt - A_hgt      ; total dist. between eta levels surrounding the height to interp. to
	 ; find if variable is increasing or decreasing here
         if (ws_sub(f,d) .gt. ws_sub(f-1,d)) then
           ; if variable increases with height linearly interp.  
           wt = (C_hgt-A_hgt)/total_dist      ;; wt is a weighting factor 
           ws_interp(h,d) = ws_sub(f-1,d)+((ws_sub(f,d)-ws_sub(f-1,d))*wt)
         else  
           ; if variable decreases with height linearly interp.                                
           wt = (B_hgt-C_hgt)/total_dist
           ws_interp(h,d) = ws_sub(f,d)+((ws_sub(f-1,d)-ws_sub(f,d))*wt)
         end if
       else
         ; if the height to interpolate to is below the first eta level, fill with missing value.
         ws_interp(h,d)= ws_interp@_FillValue
       end if
    else
      ; if the height to interpolate to is below the surface, enter a fill value
      ws_interp(h,d)= ws_interp@_FillValue
    end if
  end do
  delete([/f,A_hgt,B_hgt,C_hgt,total_dist,wt/])
    ; Counter
    if(d%10.eq.0) then
      print("created vert levels for "+d+" of "+n_cross)
    end if
end do
ws_wrf4 = ws_interp
delete([/fin,lat2d,lon2d,eta,n_eta,Z_sfc,Z_e,ws_e,interp_ind,interp_wgt,ws_sub,Z_e_sub,Z_sfc_sub,lat1d,lon1d,Z_sfc_1d,ws_interp/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting cross section for leg "+pass)
; set outdir and fout names
   outdir = "./"
   fout   = outdir+"lidar_wrf_windspeed_leg_"+pass+"-wrfsims"

;;;;;;;;;;
; Set contour information for totalwind
;;;;;;;;;;
    units = "m s-1"
    cmin1 = 0
    cmax1 = 30.
    clev1 = 2.
    stride1             = 1                  ; label stride
    spreadstart1        = 2                  ; start at color- cross section
    spreadend1          = 129                 ; end at color
    colormap            = "MPL_BuPu"

;;;;;;;;;;;;;
; Cross Section Plot Resources
;;;;;;;;;;;;;

 opts                              = True              ; plot mods desired
  opts@gsnRightString              = ""
  opts@gsnLeftString               = ""
  opts@gsnFrame                    = False             ; Do not draw plot 
  opts@gsnDraw                     = False             ; Do not advance frame

  opts@cnFillMode                  = "AreaFill"
  opts@cnFillOn                    = True              ; Turn on filled contours
  opts@gsnSpreadColors             = True              ; use full colormap
  opts@gsnSpreadColorStart         = spreadstart1      ; start at color specified for variable
  opts@gsnSpreadColorEnd           = spreadend1        ; end at color specified for variable
  opts@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF              = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF              = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF             = clev1             ; set contour spacing specified above
  opts@cnLinesOn                   = False             ; contour lines specified above  
  opts@cnInfoLabelOn               = False             ; turn off label bar at bottom
  opts@cnLineLabelsOn              = False             ; line labels on specified above
  opts@cnMissingValFillColor       = "gray85"          ; missing value color
  opts@cnMissingValFillPattern     = 0                 ; fill in 

  opts@tiMainFontHeightF           = 0.025
  opts@tiMainFontThicknessF        = 1.5  
  opts@tiXAxisString               = "Distance (km)"
;  opts@tiXAxisOffsetYF             = 0.0 ;0.13
  opts@tiYAxisString               = "Height (m)"
  opts@tmXBOn                      = True
  opts@tmXBMode                    = "Explicit"
  opts@tmXBValues                  = (/0,10,20,30,40,50,60,70/)
  opts@tmXBLabels                  = (/"0","10","20","30","40","50","60","70"/)
  opts@tmXBMinorOn                 = True
;  opts@tmXBMinorMode               = "Explicit"
  opts@tmXBMinorValues             = (/5,15,25,35,45,55,65/)              
;  opts@tmXBMinorPerMajor           = 2

  opts@tmYROn                      = False
  opts@tmXTOn                      = False
  opts@tiXAxisFontHeightF          = 0.03              ; set font size for x axis
  opts@tmXBLabelFontHeightF        = 0.03              ; set tick mark label size for x axis
  opts@tiYAxisFontHeightF          = 0.03              ; set font size for y axis
  opts@tmYLLabelFontHeightF        = 0.03              ; set tick mark label size for y axis
  opts@trYMaxF                     = 1800.0
  opts@trXMaxF                     = 71.0 
  opts@vpWidthF                    = 1.0               ; set aspect ratio
  opts@vpHeightF                   = 0.55

  opts@lbLabelBarOn                = False

; Set panel resources
  pnlres                            = True
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbTitleString              = units
  pnlres@lbTitlePosition            = "Right"
  pnlres@lbTitleDirection           = "Across"
  pnlres@lbTitleJust                = "CenterLeft"
  pnlres@lbTitleFontHeightF         = 0.0095 ;0.0125
  pnlres@lbLabelStride              = stride1
  pnlres@lbLabelFontHeightF         = 0.0095 ;0.0125
  pnlres@pmLabelBarWidthF           = 0.95
  pnlres@pmLabelBarHeightF          = 0.1
  pnlres@gsnMaximize                = True             ; fill the page
  pnlres@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page

; set text res for labels
  txres                           = True
  txres@txFontHeightF             = 0.025 
  txres@txFontThicknessF          = 2.
  txres@txFont                    = 22
  txres@txBackgroundFillColor     = "white"
  x_txt                           = 8.0
  y_txt                           = 1650.0

; set polyres to show eta levels
   polyres                         = True
   polyres@gsMarkerIndex           = 7               ; polymarker style
   polyres@gsMarkerSizeF           = 25.               ; polymarker size
   polyres@gsMarkerColor           = "black"          ; polymarker color

;;;;;;;;;;;;;
; Make plots
;;;;;;;;;;;;;
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85","forestgreen"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

 plot = new(6, graphic)    ; one cross section plot and one spatial plot

; Flight leg
 cplot1 = gsn_csm_contour(wks,ws_lidar,opts)
 dum0a = gsn_add_polymarker(wks,cplot1,dist_lidar,y_lidar,polyres)
 dum0b = gsn_add_text(wks,cplot1,"f) Leg "+pass, x_txt,y_txt,txres)
 plot(0) = cplot1

; tag1 WRF plot
 cplot1 = gsn_csm_contour(wks,ws_wrf1,opts)
 dum1 = gsn_add_text(wks,cplot1,"g) "+tag1, x_txt,y_txt,txres)
 plot(1) = cplot1

; tag2 WRF plot
 cplot2 = gsn_csm_contour(wks,ws_wrf2,opts)
 dum2 = gsn_add_text(wks,cplot2,"h) "+tag2, x_txt,y_txt,txres)
 plot(2) = cplot2

; tag3 WRF plot
 cplot3 = gsn_csm_contour(wks,ws_wrf3,opts)
 dum3 = gsn_add_text(wks,cplot3,"i) "+tag3, x_txt,y_txt,txres)
 plot(4) = cplot3

; tag2 WRF plot
 cplot4 = gsn_csm_contour(wks,ws_wrf4,opts)
 dum4 = gsn_add_text(wks,cplot4,"j) "+tag4, x_txt,y_txt,txres)
 plot(5) = cplot4

;;;;;;;;;;;;;
; Final Plots
;;;;;;;;;;;;;

  pnlres                            = True
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/2,3/),pnlres)               ; create final panel 

  delete(wks)
  print("converting to png")
;  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
;         "-trim -border 10 "+fout+".ps "+fout+".png")


  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")


;;;;;;;;;;;;;;;;;;;;;; END script
end

