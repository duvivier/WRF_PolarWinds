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
; BEGIN SCRIPT
; set directory
dir = "/data/duvivier/polar_winds/DATA/ASCAT/from_copernicus/"
fname1 = "KNMI-GLO-WIND_L3-OBS_METOP-A_ASCAT_12_ASC_1457024838917.nc"  
fname2 = "KNMI-GLO-WIND_L3-OBS_METOP-A_ASCAT_12_DES_1457025071576.nc"
fname3 = "KNMI-GLO-WIND_L3-OBS_METOP-B_ASCAT_12_ASC_1457025447014.nc"
fname4 = "KNMI-GLO-WIND_L3-OBS_METOP-B_ASCAT_12_DES_1457025648542.nc"

; set outdir and fout names
outdir = "./"
fout  = outdir+"ASCAT_metop_a-b_pass_compare-contours"

print("Comparing ASCAT resolution data")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for Wind variable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vartitle1 = "10m wind speed"
; set contour limits manually:
cmin1               = 0.
cmax1               = 20.
clev1               = 1.
stride1             = 2                 ; label stride
plotlines           = False              ; lines for reg plot
cntype              = "AreaFill"
spreadstart1        = 2                 ; start at color
spreadend1          = 129                ; end at color
colormap            = "MPL_BuPu"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files
;;;;;;;;;;
; Load in first file to compare
f1 = addfile(dir+fname1,"r")
  ; latitude
  dum1 = f1->lat
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lat_1 = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; longitude
  dum1 = f1->lon
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lon_1 = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; u wind
  dum1 = f1->eastward_wind(0,0,:,:)
  u_1 = short2flt(dum1)
  delete([/dum1/])
  ; v wind
  dum1 = f1->northward_wind(0,0,:,:)
  v_1 = short2flt(dum1)
  delete([/dum1/])
  ; wind speed
  dum1 = f1->wind_speed(0,0,:,:)
  ws_1 = short2flt(dum1)
  delete([/dum1/])

  ; make 2d lat/lon values for plotting
  dims = dimsizes(ws_1)
  lat2d_1 = new((/dims(0),dims(1)/),"double")
  lon2d_1 = new((/dims(0),dims(1)/),"double")
  ; make 2d lats
  n = 0
  do n = 0, dims(1)-1
     lat2d_1(:,n) = lat_1
  end do
  ; make 2d lons
  n = 0
  do n = 0, dims(0)-1
     lon2d_1(n,:) = lon_1
  end do
  delete([/dims/])

; Load in second file to compare
f2 = addfile(dir+fname2,"r")
  ; latitude
  dum1 = f2->lat
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lat_2 = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; longitude
  dum1 = f2->lon
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lon_2 = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; u wind
  dum1 = f2->eastward_wind(0,0,:,:)
  u_2 = short2flt(dum1)
  delete([/dum1/])
  ; v wind
  dum1 = f2->northward_wind(0,0,:,:)
  v_2 = short2flt(dum1)
  delete([/dum1/])
  ; wind speed
  dum1 = f2->wind_speed(0,0,:,:)
  ws_2 = short2flt(dum1)
  delete([/dum1/])

  ; make 2d lat/lon values for plotting
  dims = dimsizes(ws_2)
  lat2d_2 = new((/dims(0),dims(1)/),"double")
  lon2d_2 = new((/dims(0),dims(1)/),"double")
  ; make 2d lats
  n = 0
  do n = 0, dims(1)-1
     lat2d_2(:,n) = lat_2
  end do
  ; make 2d lons
  n = 0
  do n = 0, dims(0)-1
     lon2d_2(n,:) = lon_2
  end do
  delete([/dims/])

; Load in third file to compare
f3 = addfile(dir+fname3,"r")
  ; latitude
  dum1 = f3->lat
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lat_3 = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; longitude
  dum1 = f3->lon
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lon_3 = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; u wind
  dum1 = f3->eastward_wind(0,0,:,:)
  u_3 = short2flt(dum1)
  delete([/dum1/])
  ; v wind
  dum1 = f3->northward_wind(0,0,:,:)
  v_3 = short2flt(dum1)
  delete([/dum1/])
  ; wind speed
  dum1 = f3->wind_speed(0,0,:,:)
  ws_3 = short2flt(dum1)
  delete([/dum1/])

  ; make 2d lat/lon values for plotting
  dims = dimsizes(ws_3)
  lat2d_3 = new((/dims(0),dims(1)/),"double")
  lon2d_3 = new((/dims(0),dims(1)/),"double")
  ; make 2d lats
  n = 0
  do n = 0, dims(1)-1
     lat2d_3(:,n) = lat_3
  end do
  ; make 2d lons
  n = 0
  do n = 0, dims(0)-1
     lon2d_3(n,:) = lon_3
  end do
  delete([/dims/])

; Load in fourth file to compare
f4 = addfile(dir+fname4,"r")
  ; latitude
  dum1 = f4->lat
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lat_4 = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; longitude
  dum1 = f4->lon
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lon_4 = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; u wind
  dum1 = f4->eastward_wind(0,0,:,:)
  u_4 = short2flt(dum1)
  delete([/dum1/])
  ; v wind
  dum1 = f4->northward_wind(0,0,:,:)
  v_4 = short2flt(dum1)
  delete([/dum1/])
  ; wind speed
  dum1 = f4->wind_speed(0,0,:,:)
  ws_4 = short2flt(dum1)
  delete([/dum1/])

  ; make 2d lat/lon values for plotting
  dims = dimsizes(ws_4)
  lat2d_4 = new((/dims(0),dims(1)/),"double")
  lon2d_4 = new((/dims(0),dims(1)/),"double")
  ; make 2d lats
  n = 0
  do n = 0, dims(1)-1
     lat2d_4(:,n) = lat_4
  end do
  ; make 2d lons
  n = 0
  do n = 0, dims(0)-1
     lon2d_4(n,:) = lon_4
  end do
  delete([/dims/])

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" A-ASC  min: "+min(ws_1)+"  max: "+max(ws_1)) 
  print(vartitle1+" A-DES  min: "+min(ws_2)+"  max: "+max(ws_2))
  print(vartitle1+" B-ASC  min: "+min(ws_1)+"  max: "+max(ws_1)) 
  print(vartitle1+" B-DES  min: "+min(ws_2)+"  max: "+max(ws_2))

; assign 2d lat and lon attributes for plotting:
  u_1@lat2d = lat2d_1
  u_1@lon2d = lon2d_1
  v_1@lat2d = lat2d_1
  v_1@lon2d = lon2d_1  
  ws_1@lat2d = lat2d_1
  ws_1@lon2d = lon2d_1
  u_2@lat2d = lat2d_2
  u_2@lon2d = lon2d_2
  v_2@lat2d = lat2d_2
  v_2@lon2d = lon2d_2  
  ws_2@lat2d = lat2d_2
  ws_2@lon2d = lon2d_2
  u_3@lat2d = lat2d_3
  u_3@lon2d = lon2d_3
  v_3@lat2d = lat2d_3
  v_3@lon2d = lon2d_3  
  ws_3@lat2d = lat2d_3
  ws_3@lon2d = lon2d_3
  u_4@lat2d = lat2d_4
  u_4@lon2d = lon2d_4
  v_4@lat2d = lat2d_4
  v_4@lon2d = lon2d_4  
  ws_4@lat2d = lat2d_4
  ws_4@lon2d = lon2d_4

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

  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin1             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  res@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines         ; contour lines specified above
  res@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in

  res@tiMainFontHeightF          = 0.014
  res@tiMainFontThicknessF       = 1.5
  res@lbLabelBarOn               = False             ; turn off individual label bars

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
  vcres@vcRefAnnoOn                = True
  vcres@gsnLeftString              = ""
  vcres@gsnRightString             = ""

; panel resources
  pnlres                            = True
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbTitleString              = ws_1@units
  pnlres@lbTitlePosition            = "Right"
  pnlres@lbTitleDirection           = "Across"
  pnlres@lbTitleJust                = "CenterLeft"
  pnlres@lbTitleFontHeightF         = 0.0075
  pnlres@lbLabelStride              = stride1
  pnlres@lbLabelFontHeightF         = 0.0095
  pnlres@pmLabelBarWidthF           = 0.65
  pnlres@pmLabelBarHeightF          = 0.1
  pnlres@gsnMaximize                = True             ; fill the page

;;;;;;;;;
;; Denmark Strait Only plotted 
;;;;;;;;;
print("Plotting Denmark Strait region winds")
wks = gsn_open_wks("ps" ,fout)
additional_colors = (/"gray85","yellow", "purple", "red"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(4, graphic)

; order so we're advancing in time

; Plot 0 - A-ASC
  opts                             = res
  opts@tiMainString                = "METOP_A - ASCENDING (20:20UTC)"
  cplot = gsn_csm_contour_map(wks, ws_1, opts)
  vplot = gsn_csm_vector(wks,u_1,v_1,vcres)
  overlay(cplot,vplot) 
;  plot(0) = cplot
  plot(2) = cplot
  delete(opts)

; Plot 1 - A-DES
  opts                             = res
  opts@tiMainString                = "METOP_A - DESCENDING (13:45UTC)"
  cplot = gsn_csm_contour_map(wks, ws_2, opts)
  vplot = gsn_csm_vector(wks,u_2,v_2,vcres)
  overlay(cplot,vplot) 
;  plot(1) = cplot
  plot(1) = cplot
  delete(opts)

; Plot 2 - B-ASC
  opts                             = res
  opts@tiMainString                = "METOP_B - ASCENDING (23:00UTC)"
  cplot = gsn_csm_contour_map(wks, ws_3, opts)
  vplot = gsn_csm_vector(wks,u_3,v_3,vcres)
  overlay(cplot,vplot) 
;  plot(2) = cplot
  plot(3) = cplot
  delete(opts)

; Plot 3 - B-DES
  opts                             = res
  opts@tiMainString                = "METOP_B - DESCENDING (11:00UTC)"
  cplot = gsn_csm_contour_map(wks, ws_4, opts)
  vplot = gsn_csm_vector(wks,u_4,v_4,vcres)
  overlay(cplot,vplot) 
;  plot(3) = cplot
  plot(0) = cplot
  delete(opts)

; Plot final panel plot 
  pnlres@txString                   = "12km ASCAT pass data for 2015-05-21"
  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
