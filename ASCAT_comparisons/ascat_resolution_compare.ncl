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
; MANUAL INPUTS - for testing purposes

; BEGIN SCRIPT
; set directory
dir = "/data/duvivier/polar_winds/DATA/ASCAT/from_copernicus/"
fname1 = "KNMI-GLO-WIND_L3-OBS_METOP-A_ASCAT_12_ASC_1457024838917.nc"  ; 12km
fname2 = "KNMI-GLO-WIND_L3-OBS_METOP-A_ASCAT_25_ASC_1457024318637.nc"  ; 25km

; set outdir and fout names
outdir = "./"
fout  = outdir+"ASCAT_resolution_compare"

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
cntype              = "RasterFill" ;"AreaFill"
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

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" 12km  min: "+min(ws_1)+"  max: "+max(ws_1)) 
  print(vartitle1+" 25km  min: "+min(ws_2)+"  max: "+max(ws_2))

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
plot = new(2, graphic)

; Plot 0 - 12km 
  opts                             = res
  opts@tiMainString                = "12km"
  cplot = gsn_csm_contour_map(wks, ws_1, opts)
  vplot = gsn_csm_vector(wks,u_1,v_1,vcres)
  overlay(cplot,vplot) 
  plot(0) = cplot
  delete(opts)

; Plot 1 - 25km
  opts                             = res
  opts@tiMainString                = "25km"
  cplot = gsn_csm_contour_map(wks, ws_2, opts)
  vplot = gsn_csm_vector(wks,u_2,v_2,vcres)
  overlay(cplot,vplot) 
  plot(1) = cplot
  delete(opts)

; Plot final panel plot 
  pnlres@txString                   = "ASCAT METOP A Ascending passes from 2015-05-21"
  gsn_panel(wks,(/plot/),(/1,2/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
