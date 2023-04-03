;***************************************
; PROGRAM DESCRIPTION: This script plots single panel plots of 
;                      diagnostic variables
; INPUT DATA: WRF output or RACM-WRF output post processed with wrfout-to-cf.ncl
;             and then made into yearly seasonal mean files
; OUTPUT DATA: One Panel plot of specified variable
; Note: This can be looped with 01_wrfsinglepanel_akd_seasonal.csh 
;       to evaluate at multiple hours or variables
; CREATOR: Matt Higgins
;          Modified by Alice DuVivier - April 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS
day = "21"     ;"20" or "21" UTC
pass = "DES"   ;"ASC" or "DES"
sat = "A"      ;"A" or "B" for which satellite
tag1 = "PW-05-40-M-bn"
tag2 = "PW-05-60-M-bn"
tag3 = "PW-10-40-M-bn"
tag4 = "PW-25-40-M-bn"
tag5 = "PW-50-40-M-bn"
tag6 = "PW-05-40-U-bn"
tag7 = "PW-05-60-U-bn"

; BEGIN SCRIPT
print("Comparing ASCAT satellite "+sat+" to WRF on "+day+" "+pass+" pass")
; Set preferences for Wind variable
vartitle1 = "10m wind speed"
; set contour limits manually:
    units = "m s-1"
    cmin1               = 0.
    cmax1               = 20.
    clev1               = 1.
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 1.
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride for diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2      ;2           ; start at color
    spreadend1          = 21     ;129           ; end at color
    spreadstart2        = 23                ; start at color
    spreadend2          = 45                ; end at color
    colormap            = "winds.alice"  ; "MPL_BuPu"

; set directories based on data
outdir = "./"
dir = "/data/duvivier/polar_winds/DATA/"

; ASCAT data
dir_ascat = dir+"ASCAT/from_copernicus/"
if (day.eq."20")then
   dd = 0
   if (sat.eq."A")then
      if (pass.eq."ASC")then
      	 fname0 = "KNMI-GLO-WIND_L3-OBS_METOP-A_ASCAT_12_ASC_1458684163976.nc"
	 time = "20-40"      	 
      end if
      if (pass.eq."DES")then
      	 fname0 = "KNMI-GLO-WIND_L3-OBS_METOP-A_ASCAT_12_DES_1458684291549.nc"
	 time = "14-00"      	 
      end if
   end if 
   if (sat.eq."B")then
      if (pass.eq."ASC")then
      	 fname0 = "KNMI-GLO-WIND_L3-OBS_METOP-B_ASCAT_12_ASC_1458684381691.nc"
	 time = "20-00"      	 
      end if
      if (pass.eq."DES")then
      	 fname0 = "KNMI-GLO-WIND_L3-OBS_METOP-B_ASCAT_12_DES_1458684443600.nc"
	 time = "12-00" ;"11-40"      	 
      end if
   end if   
end if
if (day.eq."21")then
   dd = 1
   if (sat.eq."A")then
      if (pass.eq."ASC")then
      	 fname0 = "KNMI-GLO-WIND_L3-OBS_METOP-A_ASCAT_12_ASC_1458684163976.nc"
	 time = "20-20"      	 
      end if
      if (pass.eq."DES")then
      	 fname0 = "KNMI-GLO-WIND_L3-OBS_METOP-A_ASCAT_12_DES_1458684291549.nc"
	 time = "13-40"      	 
      end if
   end if 
   if (sat.eq."B")then
      if (pass.eq."ASC")then
      	 fname0 = "KNMI-GLO-WIND_L3-OBS_METOP-B_ASCAT_12_ASC_1458684381691.nc"
	 time = "23-00"      	 
      end if
      if (pass.eq."DES")then
      	 fname0 = "KNMI-GLO-WIND_L3-OBS_METOP-B_ASCAT_12_DES_1458684443600.nc"
	 time = "11-00"      	 
      end if
   end if   
end if

; WRF data
dir_wrf1 = dir+tag1+"/wrf2ascat/"
fname1   = "wrf2ascat.2015-05-"+day+"_"+time+"."+tag1+"-cf.nc"

dir_wrf2 = dir+tag2+"/wrf2ascat/"
fname2   = "wrf2ascat.2015-05-"+day+"_"+time+"."+tag2+"-cf.nc"

dir_wrf3 = dir+tag3+"/wrf2ascat/"
fname3   = "wrf2ascat.2015-05-"+day+"_"+time+"."+tag3+"-cf.nc"

dir_wrf4 = dir+tag4+"/wrf2ascat/"
fname4   = "wrf2ascat.2015-05-"+day+"_"+time+"."+tag4+"-cf.nc"

dir_wrf5 = dir+tag5+"/wrf2ascat/"
fname5   = "wrf2ascat.2015-05-"+day+"_"+time+"."+tag5+"-cf.nc"

dir_wrf6 = dir+tag6+"/wrf2ascat/"
fname6   = "wrf2ascat.2015-05-"+day+"_"+time+"."+tag6+"-cf.nc"

dir_wrf7 = dir+tag7+"/wrf2ascat/"
fname7   = "wrf2ascat.2015-05-"+day+"_"+time+"."+tag7+"-cf.nc"

; set title for panel and fout
title_fin = "ASCAT and WRF on May "+day+", "+time+"UTC"
fout = outdir+"ASCAT_WRF_all_diffs-201505"+day+"_"+time

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in ascat file
;;;;;;;;;;
; Load in first file to compare
f0 = addfile(dir_ascat+fname0,"r")
  ; latitude
  dum1 = f0->lat
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lat = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; longitude
  dum1 = f0->lon
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lon = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; u wind
  dum1 = f0->eastward_wind(dd,0,:,:)
  u_0 = short2flt(dum1)
  delete([/dum1/])
  ; v wind
  dum1 = f0->northward_wind(dd,0,:,:)
  v_0 = short2flt(dum1)
  delete([/dum1/])
  ; wind speed
  dum1 = f0->wind_speed(dd,0,:,:)
  ws_0 = short2flt(dum1)
  delete([/dum1/])

  ; make 2d lat/lon values for plotting
  dims = dimsizes(ws_0)
  lat2d_0 = new((/dims(0),dims(1)/),"double")
  lon2d_0 = new((/dims(0),dims(1)/),"double")
  ; make 2d lats
  n = 0
  do n = 0, dims(1)-1
     lat2d_0(:,n) = lat
  end do
  ; make 2d lons
  n = 0
  do n = 0, dims(0)-1
     lon2d_0(n,:) = lon
  end do
  delete([/lat,lon,dims/])
; assign 2d lat and lon attributes for plotting:
  u_0@lat2d = lat2d_0
  u_0@lon2d = lon2d_0
  v_0@lat2d = lat2d_0
  v_0@lon2d = lon2d_0 
  ws_0@lat2d = lat2d_0
  ws_0@lon2d = lon2d_0

; make mask to plot on other figures
sat_mask = where(ws_0 .eq. ws_0@_FillValue, 0.0, 1.0)
delete(sat_mask@_FillValue)
sat_mask = where(sat_mask .eq. 1.0, 1.0, 0.0)
sat_mask@lat2d = lat2d_0
sat_mask@lon2d = lon2d_0

;;;;;;;;;;
; load in wrf files
;;;;;;;;;;
; choose height to mask below
hgt_msk = 100.0

; Load in first wrf file
  f1 = addfile(dir_wrf1+fname1,"r")
  hgt_1   = f1->Z_sfc
  lat2d_1 = f1->lat_ascat
  lon2d_1 = f1->lon_ascat
  ws_1    = f1->ws_10m(0,:,:)
  u_1     = f1->u_10m(0,:,:)
  v_1     = f1->v_10m(0,:,:)
  ; mask above 500m
  ws_1 = where(hgt_1.le.hgt_msk, ws_1, ws_1@_FillValue)
  u_1 = where(hgt_1.le.hgt_msk, u_1, u_1@_FillValue)
  v_1 = where(hgt_1.le.hgt_msk, v_1, v_1@_FillValue)
  ; assign 2d lat and lon attributes for plotting:
  u_1@lat2d = lat2d_1
  u_1@lon2d = lon2d_1
  v_1@lat2d = lat2d_1
  v_1@lon2d = lon2d_1  
  ws_1@lat2d = lat2d_1
  ws_1@lon2d = lon2d_1

; Load in second wrf file
  f2 = addfile(dir_wrf2+fname2,"r")
  hgt_2   = f2->Z_sfc
  lat2d_2 = f2->lat_ascat
  lon2d_2 = f2->lon_ascat
  ws_2    = f2->ws_10m(0,:,:)
  u_2     = f2->u_10m(0,:,:)
  v_2     = f2->v_10m(0,:,:)
  ; mask above 500m
  ws_2 = where(hgt_2.le.hgt_msk, ws_2, ws_2@_FillValue)
  u_2 = where(hgt_2.le.hgt_msk, u_2, u_2@_FillValue)
  v_2 = where(hgt_2.le.hgt_msk, v_2, v_2@_FillValue)
  ; assign 2d lat and lon attributes for plotting:
  u_2@lat2d = lat2d_2
  u_2@lon2d = lon2d_2
  v_2@lat2d = lat2d_2
  v_2@lon2d = lon2d_2  
  ws_2@lat2d = lat2d_2
  ws_2@lon2d = lon2d_2

; Load in third wrf file
  f3 = addfile(dir_wrf3+fname3,"r")
  hgt_3   = f3->Z_sfc
  lat2d_3 = f3->lat_ascat
  lon2d_3 = f3->lon_ascat
  ws_3    = f3->ws_10m(0,:,:)
  u_3     = f3->u_10m(0,:,:)
  v_3     = f3->v_10m(0,:,:)
  ; mask above 500m
  ws_3 = where(hgt_3.le.hgt_msk, ws_3, ws_3@_FillValue)
  u_3 = where(hgt_3.le.hgt_msk, u_3, u_3@_FillValue)
  v_3 = where(hgt_3.le.hgt_msk, v_3, v_3@_FillValue)
  ; assign 2d lat and lon attributes for plotting:
  u_3@lat2d = lat2d_3
  u_3@lon2d = lon2d_3
  v_3@lat2d = lat2d_3
  v_3@lon2d = lon2d_3  
  ws_3@lat2d = lat2d_3
  ws_3@lon2d = lon2d_3

; Load in second wrf file
  f4 = addfile(dir_wrf4+fname4,"r")
  hgt_4   = f4->Z_sfc
  lat2d_4 = f4->lat_ascat
  lon2d_4 = f4->lon_ascat
  ws_4    = f4->ws_10m(0,:,:)
  u_4     = f4->u_10m(0,:,:)
  v_4     = f4->v_10m(0,:,:)
  ; mask above 500m
  ws_4 = where(hgt_4.le.hgt_msk, ws_4, ws_4@_FillValue)
  u_4 = where(hgt_4.le.hgt_msk, u_4, u_4@_FillValue)
  v_4 = where(hgt_4.le.hgt_msk, v_4, v_4@_FillValue)
  ; assign 2d lat and lon attributes for plotting:
  u_4@lat2d = lat2d_4
  u_4@lon2d = lon2d_4
  v_4@lat2d = lat2d_4
  v_4@lon2d = lon2d_4  
  ws_4@lat2d = lat2d_4
  ws_4@lon2d = lon2d_4

; Load in second wrf file
  f5 = addfile(dir_wrf5+fname5,"r")
  hgt_5   = f5->Z_sfc
  lat2d_5 = f5->lat_ascat
  lon2d_5 = f5->lon_ascat
  ws_5    = f5->ws_10m(0,:,:)
  u_5     = f5->u_10m(0,:,:)
  v_5     = f5->v_10m(0,:,:)
  ; mask above 500m
  ws_5 = where(hgt_5.le.hgt_msk, ws_5, ws_5@_FillValue)
  u_5 = where(hgt_5.le.hgt_msk, u_5, u_5@_FillValue)
  v_5 = where(hgt_5.le.hgt_msk, v_5, v_5@_FillValue)
  ; assign 2d lat and lon attributes for plotting:
  u_5@lat2d = lat2d_5
  u_5@lon2d = lon2d_5
  v_5@lat2d = lat2d_5
  v_5@lon2d = lon2d_5  
  ws_5@lat2d = lat2d_5
  ws_5@lon2d = lon2d_5

; Load in second wrf file
  f6 = addfile(dir_wrf6+fname6,"r")
  hgt_6   = f6->Z_sfc
  lat2d_6 = f6->lat_ascat
  lon2d_6 = f6->lon_ascat
  ws_6    = f6->ws_10m(0,:,:)
  u_6     = f6->u_10m(0,:,:)
  v_6     = f6->v_10m(0,:,:)
  ; mask above 500m
  ws_6 = where(hgt_6.le.hgt_msk, ws_6, ws_6@_FillValue)
  u_6 = where(hgt_6.le.hgt_msk, u_6, u_6@_FillValue)
  v_6 = where(hgt_6.le.hgt_msk, v_6, v_6@_FillValue)
  ; assign 2d lat and lon attributes for plotting:
  u_6@lat2d = lat2d_0
  u_6@lon2d = lon2d_0
  v_6@lat2d = lat2d_0
  v_6@lon2d = lon2d_0  
  ws_6@lat2d = lat2d_0
  ws_6@lon2d = lon2d_0

; Load in second wrf file
  f7 = addfile(dir_wrf7+fname7,"r")
  hgt_7   = f7->Z_sfc
;  lat2d_7 = f7->lat_ascat
;  lon2d_7 = f7->lon_ascat
  ws_7    = f7->ws_10m(0,:,:)
  u_7     = f7->u_10m(0,:,:)
  v_7     = f7->v_10m(0,:,:)
  ; mask above 500m
  ws_7 = where(hgt_7.le.hgt_msk, ws_7, ws_7@_FillValue)
  u_7 = where(hgt_7.le.hgt_msk, u_7, u_7@_FillValue)
  v_7 = where(hgt_7.le.hgt_msk, v_7, v_7@_FillValue)
  ; assign 2d lat and lon attributes for plotting:
  u_7@lat2d = lat2d_0
  u_7@lon2d = lon2d_0
  v_7@lat2d = lat2d_0
  v_7@lon2d = lon2d_0  
  ws_7@lat2d = lat2d_0
  ws_7@lon2d = lon2d_0

; calculate differences
diff_1 = ws_1 - ws_0
diff_2 = ws_2 - ws_0
diff_3 = ws_3 - ws_0
diff_4 = ws_4 - ws_0
diff_5 = ws_5 - ws_0
diff_6 = ws_6 - ws_0
diff_7 = ws_7 - ws_0
copy_VarMeta(ws_0,diff_1)
copy_VarMeta(ws_0,diff_2)
copy_VarMeta(ws_0,diff_3)
copy_VarMeta(ws_0,diff_4)
copy_VarMeta(ws_0,diff_5)
copy_VarMeta(ws_0,diff_6)
copy_VarMeta(ws_0,diff_7)

; calculate and print statistics
; make dummy vars
ws_0_stats = where(lat2d_0.ge.64.0 .and. lat2d_0.le.71.0, ws_0, ws_0@_FillValue)
ws_0_stats = where(lon2d_0.ge.325.0 .and. lon2d_0.le.360.0, ws_0, ws_0@_FillValue)
ws_1_stats = where(lat2d_0.ge.64.0 .and. lat2d_0.le.71.0, ws_1, ws_1@_FillValue)
ws_1_stats = where(lon2d_0.ge.325.0 .and. lon2d_0.le.360.0, ws_1, ws_1@_FillValue)
ws_2_stats = where(lat2d_0.ge.64.0 .and. lat2d_0.le.71.0, ws_2, ws_2@_FillValue)
ws_2_stats = where(lon2d_0.ge.325.0 .and. lon2d_0.le.360.0, ws_2, ws_2@_FillValue)
ws_3_stats = where(lat2d_0.ge.64.0 .and. lat2d_0.le.71.0, ws_3, ws_3@_FillValue)
ws_3_stats = where(lon2d_0.ge.325.0 .and. lon2d_0.le.360.0, ws_3, ws_3@_FillValue)
ws_4_stats = where(lat2d_0.ge.64.0 .and. lat2d_0.le.71.0, ws_4, ws_4@_FillValue)
ws_4_stats = where(lon2d_0.ge.325.0 .and. lon2d_0.le.360.0, ws_4, ws_4@_FillValue)
ws_5_stats = where(lat2d_0.ge.64.0 .and. lat2d_0.le.71.0, ws_5, ws_5@_FillValue)
ws_5_stats = where(lon2d_0.ge.325.0 .and. lon2d_0.le.360.0, ws_5, ws_5@_FillValue)
ws_6_stats = where(lat2d_0.ge.64.0 .and. lat2d_0.le.71.0, ws_6, ws_6@_FillValue)
ws_6_stats = where(lon2d_0.ge.325.0 .and. lon2d_0.le.360.0, ws_6, ws_6@_FillValue)
ws_7_stats = where(lat2d_0.ge.64.0 .and. lat2d_0.le.71.0, ws_7, ws_7@_FillValue)
ws_7_stats = where(lon2d_0.ge.325.0 .and. lon2d_0.le.360.0, ws_7, ws_7@_FillValue)

; calculate stats over this domain
dum1 = ndtooned(ws_0_stats)
dum2 = ind(dum1 .ge. 0.0)
tot_pts = dimsizes(dum2)
delete([/dum1,dum2/])

; calculate for tag1
dum1 = ws_1_stats - ws_0_stats
bias = avg(dum1)
rmse = sqrt((sum(dum1^2))/tot_pts)
corr = escorc(ndtooned(ws_1_stats),ndtooned(ws_0_stats))
print(tag1+" bias: "+bias+", rmse: "+rmse+", corr:"+corr)
delete([/dum1,bias,rmse,corr/])

; calculate for tag2
dum1 = ws_2_stats - ws_0_stats
bias = avg(dum1)
rmse = sqrt((sum(dum1^2))/tot_pts)
corr = escorc(ndtooned(ws_2_stats),ndtooned(ws_0_stats))
print(tag2+" bias: "+bias+", rmse: "+rmse+", corr:"+corr)
delete([/dum1,bias,rmse,corr/])

; calculate for tag3
dum1 = ws_3_stats - ws_0_stats
bias = avg(dum1)
rmse = sqrt((sum(dum1^2))/tot_pts)
corr = escorc(ndtooned(ws_3_stats),ndtooned(ws_0_stats))
print(tag3+" bias: "+bias+", rmse: "+rmse+", corr:"+corr)
delete([/dum1,bias,rmse,corr/])

; calculate for tag4
dum1 = ws_4_stats - ws_0_stats
bias = avg(dum1)
rmse = sqrt((sum(dum1^2))/tot_pts)
corr = escorc(ndtooned(ws_4_stats),ndtooned(ws_0_stats))
print(tag4+" bias: "+bias+", rmse: "+rmse+", corr:"+corr)
delete([/dum1,bias,rmse,corr/])

; calculate for tag5
dum1 = ws_5_stats - ws_0_stats
bias = avg(dum1)
rmse = sqrt((sum(dum1^2))/tot_pts)
corr = escorc(ndtooned(ws_5_stats),ndtooned(ws_0_stats))
print(tag5+" bias: "+bias+", rmse: "+rmse+", corr:"+corr)
delete([/dum1,bias,rmse,corr/])

; calculate for tag6
dum1 = ws_6_stats - ws_0_stats
bias = avg(dum1)
rmse = sqrt((sum(dum1^2))/tot_pts)
corr = escorc(ndtooned(ws_6_stats),ndtooned(ws_0_stats))
print(tag6+" bias: "+bias+", rmse: "+rmse+", corr:"+corr)
delete([/dum1,bias,rmse,corr/])

; calculate for tag7
dum1 = ws_7_stats - ws_0_stats
bias = avg(dum1)
rmse = sqrt((sum(dum1^2))/tot_pts)
corr = escorc(ndtooned(ws_7_stats),ndtooned(ws_0_stats))
print(tag7+" bias: "+bias+", rmse: "+rmse+", corr:"+corr)
delete([/dum1,bias,rmse,corr/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Making plots")
; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -25.              ; set the center lat/lon  ---set by akd for Greenland
  res@mpCenterLatF                = 65.               ; -----set by akd for Greenland
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner
  res@mpLimitMode                 = "LatLon"
  res@mpMinLatF                   = 64.0
  res@mpMaxLatF                   = 71.0
  res@mpMinLonF                   = -35.0
  res@mpMaxLonF                   = -15.0
  res@tiMainFontHeightF           = 0.014  ;0.02
  res@tiMainFontThicknessF        = 1.5

  ; contour resources					
  res1                            = res
  res@cnFillMode                  = cntype
  res1@cnFillOn                   = True              ; turn on filled contours
  res1@gsnSpreadColors            = True              ; use full colormap
  res1@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  res1@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  res1@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res1@cnMinLevelValF             = cmin1             ; set min contour level specified above
  res1@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  res1@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  res1@cnLinesOn                  = plotlines         ; contour lines specified above
  res1@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res1@cnMissingValFillColor      = "gray85"          ; missing value color
  res1@cnMissingValFillPattern    = 0                 ; fill in
  res1@lbLabelBarOn               = False             ; turn off individual label bars

  ; difference resources
  res2                           = res
  res2@cnFillMode                 = cntype
  res2@cnFillOn                   = True              ; turn on filled contours
  res2@gsnSpreadColors            = True              ; use full colormap
  res2@gsnSpreadColorStart        = spreadstart2      ; start at color specified for each variable above
  res2@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  res2@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res2@cnMinLevelValF             = cmin2             ; set min contour level specified above
  res2@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  res2@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  res2@cnLinesOn                  = difflines         ; contour lines specified above
  res2@cnLineLabelsOn             = difflines         ; line labels on specified above
  res2@cnMissingValFillColor      = "gray85"          ; missing value color
  res2@cnMissingValFillPattern    = 0                 ; fill in
  res2@lbLabelBarOn               = False             ; turn off individual label bars

; vector resources
  vcres                            = True 
  vcres@gsnDraw                    = False
  vcres@gsnFrame                   = False
  vcres@vcGlyphStyle               = "LineArrow"
  vcres@vcRefMagnitudeF            = 2.0
  vcres@vcRefLengthF               = 0.005
  vcres@vcMonoLineArrowColor       = True
  vcres@vcLineArrowColor           = "black"
  vcres@vcMinDistanceF             = 0.05
  vcres@vcRefAnnoOn                = False ;True
  vcres@gsnLeftString              = ""
  vcres@gsnRightString             = ""

; set resources for satellite overlay
  res_sat                            = True               ; reset options
  res_sat@gsnLeftString              = ""
  res_sat@gsnRightString             = ""
  res_sat@gsnFrame                   = False             ; Do not draw plot 
  res_sat@gsnDraw                    = False             ; Do not advance fr
  res_sat@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_sat@cnFillOn                   = False             ; turn on filled contours
  res_sat@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_sat@cnMinLevelValF             = 0.                ; set min contour level specified above
  res_sat@cnMaxLevelValF             = 0.15              ; set max contour level specified above
  res_sat@cnLevelSpacingF            = 0.15              ; set contour spacing specified above
  res_sat@cnLinesOn                  = True              ; contour lines specified above
  res_sat@cnLineLabelsOn             = False             ; line labels on specified above
  res_sat@cnLineColor                = "black"
  res_sat@cnLineThicknessF           = 2.0
  res_sat@tiXAxisOn                  = False
  res_sat@tiYAxisOn                  = False

; set text res for labels
  txres                           = True
  txres@txFontHeightF             = 0.025 
  txres@txFontThicknessF          = 2.
  txres@txFont                    = 22
  txres@txBackgroundFillColor     = "white"
  lat_txt                         = 70.5
  lon_txt                         = -29.5 

; panel resources
  pnlres                            = True
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbTitleString              = units
  pnlres@lbTitlePosition            = "Right"
  pnlres@lbTitleDirection           = "Across"
  pnlres@lbTitleJust                = "CenterLeft"
  pnlres@lbTitleFontHeightF         = 0.0125 ;0.0075
  pnlres@lbLabelStride              = stride1
  pnlres@lbLabelFontHeightF         = 0.0125 ;0.0095
  pnlres@pmLabelBarWidthF           = 0.95
  pnlres@pmLabelBarHeightF          = 0.1
  pnlres@gsnMaximize                = True             ; fill the page

;;;;;;;;;
;; Denmark Strait Only plotted 
;;;;;;;;;
print("Plotting Denmark Strait region winds")
wks = gsn_open_wks("ps" ,fout)
additional_colors = (/"gray85","yellow", "purple", "red"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(8, graphic)

; Plot 0 - ASCAT
  opts                             = res2
  opts@tiMainString                = "ASCAT"
  cplot = gsn_csm_contour_map(wks, ws_0, opts)
  ;plot(0) = cplot
  delete(opts)

; Plot 1 
  opts                             = res2
;  opts@tiMainString                = "(W05-40 - ASCAT) at "+time+"UTC"
  cplot = gsn_csm_contour_map(wks, diff_1, opts)
  iplot = gsn_csm_contour(wks,sat_mask,res_sat)
  overlay(cplot,iplot)
  dum1 = new(1,graphic)
  dum1 = gsn_add_text(wks,cplot,"i) W05-40-M - ASCAT",lon_txt,lat_txt,txres)
  plot(1) = cplot
  delete(opts)

; Plot 3
  opts                             = res2
;  opts@tiMainString                = "(W10-40 - ASCAT) at "+time+"UTC"
  cplot = gsn_csm_contour_map(wks, diff_3, opts)
  iplot = gsn_csm_contour(wks,sat_mask,res_sat)
  overlay(cplot,iplot)
  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks,cplot,"j) W10-40-M - ASCAT",lon_txt,lat_txt,txres)
  plot(2) = cplot
  delete(opts)

; Plot 4
  opts                             = res2
;  opts@tiMainString                = "(W25-40 - ASCAT) at "+time+"UTC"
  cplot = gsn_csm_contour_map(wks, diff_4, opts)
  iplot = gsn_csm_contour(wks,sat_mask,res_sat)
  overlay(cplot,iplot)
  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks,cplot,"k) W25-40-M - ASCAT",lon_txt,lat_txt,txres)
  plot(3) = cplot
  delete(opts)

; Plot 6
  opts                             = res2
;  opts@tiMainString                = "(W50-40 - ASCAT) at "+time+"UTC"
  cplot = gsn_csm_contour_map(wks, diff_5, opts)
  iplot = gsn_csm_contour(wks,sat_mask,res_sat)
  overlay(cplot,iplot)
  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks,cplot,"l) W50-40-M - ASCAT",lon_txt,lat_txt,txres)
  plot(4) = cplot
  delete(opts)

; Plot 2 
  opts                             = res2
;  opts@tiMainString                = "(W05-60 - ASCAT) at "+time+"UTC"
  cplot = gsn_csm_contour_map(wks, diff_2, opts)
  iplot = gsn_csm_contour(wks,sat_mask,res_sat)
  overlay(cplot,iplot)
  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks,cplot,"m) W05-60-M - ASCAT",lon_txt,lat_txt,txres)
  plot(5) = cplot
  delete(opts)

; Plot 7
  opts                             = res2
  cplot = gsn_csm_contour_map(wks, diff_6, opts)
  iplot = gsn_csm_contour(wks,sat_mask,res_sat)
  overlay(cplot,iplot)
  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks,cplot,"n) W05-40-U - ASCAT",lon_txt,lat_txt,txres)
  plot(6) = cplot
  delete(opts)

; Plot 6
  opts                             = res2
  cplot = gsn_csm_contour_map(wks, diff_7, opts)
  iplot = gsn_csm_contour(wks,sat_mask,res_sat)
  overlay(cplot,iplot)
  dum7 = new(1,graphic)
  dum7 = gsn_add_text(wks,cplot,"o) W05-60-U - ASCAT",lon_txt,lat_txt,txres)
  plot(7) = cplot
  delete(opts)

; Plot final panel plot 
;  pnlres@txString                   = title_fin
  gsn_panel(wks,(/plot/),(/2,4/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
