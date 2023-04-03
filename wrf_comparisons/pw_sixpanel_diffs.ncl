;**************************************
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
;date = "2015-05-21_23-00"
;varcode = "WS"
;tag0 = "PW-05-40-M-bn"
;tag1 = "PW-10-40-M-bn"
;tag2 = "PW-05-40-U-bn"
;tag3 = "PW-10-40-U-bn"

; BEGIN SCRIPT
; set directory
  dir = "/data/duvivier/polar_winds/DATA/"
; set outdir and fout names
outdir = "./"

; plot whole domain:
whole_dom = "1"
if (whole_dom .eq. "1")then
   fout1  = outdir+varcode+"_pw_wrf_comparison_"+date
end if
fout2  = outdir+varcode+"_pw_wrf_comparison_zoom_"+date

print("Running Four panel for " + date)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; add each variable set in the c-shell 'varcode' and assign it a title and other necessary information
; Which variables need to be loaded?
  if (varcode.eq."WS") then
    vartitle1 = "10m wind speed"
    invar1 = "ws_10m"
    cmaptype = "speed"
  end if
  if (varcode.eq."SLP") then
    vartitle1 = "Sea Level Pressure"
    invar1 = "slp"
    cmaptype = "pressure"
  end if
  if (varcode.eq."T_sfc") then
    vartitle1 = "Temperature at surface"
    invar1 = "T_sfc"
    cmaptype = "temperature"
  end if
  if (varcode.eq."T2m") then
    vartitle1 = "Temperature at 2 m"
    invar1 = "T_2m"
    cmaptype = "temperature"
  end if
  if (varcode.eq."precip") then
    vartitle1 = "Precipitation"
    invar1 = "precip_c"
    invar2 = "precip_g" 
    cmaptype = "precip"
  end if
  if (varcode.eq."SH") then
    vartitle1 = "Sensible Heat Flux at Sur"
    invar1 = "SH"
    cmaptype = "flux"
  end if
  if (varcode.eq."LH") then
    vartitle1 = "Latent Heat Flux at Sur"
    invar1 = "LH"
    cmaptype = "flux"
  end if
  if (varcode.eq."SWDS") then
    vartitle1 = "Shortwave down at surface"
    invar1 = "SW_d"
    vartype = "2d"
    cmaptype = "swflux"
  end if
  if (varcode.eq."LWDS") then
    vartitle1 = "Longwave down at surface"
    invar1 = "LW_d"
    cmaptype = "lwflux"
  end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."speed") then
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
  end if
  if (cmaptype.eq."pressure") then
    cmin1               = 920
    cmax1               = 1064.
    clev1               = 2.
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 1.
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride for diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74                ; end at color
    spreadstart2        = 76                ; start at color
    spreadend2          = 129               ; end at color
    colormap            = "slp_anoms.dave"
  end if
  if (cmaptype.eq."temperature") then
    cmin1               = -16.
    cmax1               = 16.
    clev1               = 2.
    cmin2               = -7.
    cmax2               = 7.
    clev2               = 1.
    stride1             = 2                 ; label stride
    stride2             = 1                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 106 
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."flux") then
    cmin1               =  -100.
    cmax1               =  100.
    clev1               =  10.
    cmin2               = -50.
    cmax2               =  50.
    clev2               =  10.
    stride1             = 2                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 254               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 254               ; end at color
    colormap            = "BlueYellowRed"
  end if
  if (cmaptype.eq."precip") then
    cmin1               =  0.
    cmax1               =  300.
    clev1               =  25.
    cmin2               = -100.
    cmax2               =  100.
    clev2               =  10.
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride diff plot 
    plotlines           = False             ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."lwflux") then
    cmin1               =  0.
    cmax1               =  400.
    clev1               =  10.
    cmin2               = -100.
    cmax2               =  100.
    clev2               =  10.
    stride1             = 2                 ; label stride
    stride2             = 2
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 52                 ; start at color
    spreadend1          = 102               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 102               ; end at color
    colormap            = "BlWhRe"
  end if
  if (cmaptype.eq."swflux") then
    cmin1               =  0.
    cmax1               =  400.
    clev1               =  10.
    cmin2               = -200.
    cmax2               =  200.
    clev2               =  10.
    stride1             = 2                 ; label stride
    stride2             = 2
    plotlines           = False              ; lines for reg plot
    difflines           = False             ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 52                 ; start at color
    spreadend1          = 102               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 102               ; end at color
    colormap            = "BlWhRe"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files
;;;;;;;;;;
; Load in first file to compare
f0 = addfile(dir+tag0+"/wrfout-cf/wrf-"+date+"."+tag0+"-cf.nc","r")
hgt_0 = f0->Z_sfc
lat2d_0 = f0->lat
lon2d_0 = f0->lon
dims = dimsizes(lat2d_0)     ; get lat/lon dimensions from first domain
n_sn_0 = dims(0)              ; get south/north points
n_we_0 = dims(1)              ; get west/east points
delete(dims)

; Load in second file to compare
f1 = addfile(dir+tag1+"/wrfout-cf/wrf-"+date+"."+tag1+"-cf.nc","r")
hgt_1 = f1->Z_sfc
lat2d_1 = f1->lat
lon2d_1 = f1->lon
dims = dimsizes(lat2d_1)     ; get lat/lon dimensions from first domain
n_sn_1 = dims(0)              ; get south/north points
n_we_1 = dims(1)              ; get west/east points
delete(dims)

; Load in third file to compare
f2 = addfile(dir+tag2+"/wrfout-cf/wrf-"+date+"."+tag2+"-cf.nc","r")

; Load in fourth file to compare
f3 = addfile(dir+tag3+"/wrfout-cf/wrf-"+date+"."+tag3+"-cf.nc","r")

;;;;;;;;;;
; load in wrf variables
;;;;;;;;;;
  print("Loading "+varcode+" from each file")
  
; file 0
if (varcode .eq. "precip")then
  dum1 = f0->$invar1$(0,:,:)
  dum2 = f0->$invar2$(0,:,:)
  var0 = dum1+dum2
  copy_VarMeta(dum1,var0)
  delete([/dum1,dum2/])
else
  var0 = f0->$invar1$(0,:,:)
end if
u0 = f0->u_10m_tr(0,:,:)
v0 = f0->v_10m_tr(0,:,:)
ice0 = f0->SeaIce(0,:,:)

; file 1
if (varcode .eq. "precip")then
  dum1 = f1->$invar1$(0,:,:)
  dum2 = f1->$invar2$(0,:,:)
  var1 = dum1+dum2
  copy_VarMeta(dum1,var1)
  delete([/dum1,dum2/])
else
  var1 = f1->$invar1$(0,:,:)
end if

; file 2
if (varcode .eq. "precip")then
  dum1 = f2->$invar1$(0,:,:)
  dum2 = f2->$invar2$(0,:,:)
  var2 = dum1+dum2
  copy_VarMeta(dum1,var2)
  delete([/dum1,dum2/])
else
  var2 = f2->$invar1$(0,:,:)
end if

; file 3
if (varcode .eq. "precip")then
  dum1 = f3->$invar1$(0,:,:)
  dum2 = f3->$invar2$(0,:,:)
  var3 = dum1+dum2
  copy_VarMeta(dum1,var3)
  delete([/dum1,dum2/])
else
  var3 = f3->$invar1$(0,:,:)
end if

print("Loaded variables")

; for everything except wind speed, mask above 500m
if (varcode .ne. "WS") then
  var0 = where(hgt_0.le.500.0, var0, var0@_FillValue)
  var1 = where(hgt_1.le.500.0, var1, var1@_FillValue)
  var2 = where(hgt_0.le.500.0, var2, var2@_FillValue)
  var3 = where(hgt_1.le.500.0, var3, var3@_FillValue)
end if

; calculate differences
diff_1 = var0 - var2
diff_2 = var1 - var3

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" "+tag0+" min: "+min(var0)+"  max: "+max(var0)) 
  print(vartitle1+" "+tag1+" min: "+min(var1)+"  max: "+max(var1)) 
  print(vartitle1+" "+tag2+" min: "+min(var2)+"  max: "+max(var2))
  print(vartitle1+" "+tag3+" min: "+min(var3)+"  max: "+max(var3))

; assign 2d lat and lon attributes for plotting:
  var0@lat2d  = lat2d_0
  var0@lon2d  = lon2d_0
  copy_VarMeta(var0,var2)
  var1@lat2d  = lat2d_1
  var1@lon2d  = lon2d_1
  copy_VarMeta(var1,var3)
  ice0@lat2d  = lat2d_0
  ice0@lon2d  = lon2d_0
  diff_1@lat2d = lat2d_0
  diff_1@lon2d = lon2d_0
  diff_2@lat2d = lat2d_1
  diff_2@lon2d = lon2d_1



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
  res@mpCenterLonF                = -40.              ; set the center lat/lon  ---set by akd for Greenland
  res@mpCenterLatF                = 60.               ; -----set by akd for Greenland
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner
  res@tiMainFontHeightF          = 0.014
  res@tiMainFontThicknessF       = 1.5
  res@lbLabelBarOn               = True ;False             ; turn off individual label bars

  ; contour res
  res1                           = res
  res1@cnFillMode                 = cntype
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

  ; difference res
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

; set resources for sea ice overlay
res_ice                            = True               ; reset options
res_ice@gsnLeftString              = ""
res_ice@gsnRightString             = ""
res_ice@gsnFrame                   = False             ; Do not draw plot 
res_ice@gsnDraw                    = False             ; Do not advance fr
res_ice@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
res_ice@cnFillOn                   = False             ; turn on filled contours
res_ice@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
res_ice@cnMinLevelValF             = 0.                ; set min contour level specified above
res_ice@cnMaxLevelValF             = 0.15              ; set max contour level specified above
res_ice@cnLevelSpacingF            = 0.15              ; set contour spacing specified above
res_ice@cnLinesOn                  = True              ; contour lines specified above
res_ice@cnLineLabelsOn             = False             ; line labels on specified above
res_ice@cnLineColor                = "black"
res_ice@cnLineThicknessF           = 2.0
res_ice@tiXAxisOn                  = False
res_ice@tiYAxisOn                  = False
res_ice@trGridType                 = "TriangularMesh"

  ; panel resources
  pnlres                            = True
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelLabelBar           = False ;True
;  pnlres@lbTitleString              = var0@units
;  pnlres@lbTitlePosition            = "Right"
;  pnlres@lbTitleDirection           = "Across"
;  pnlres@lbTitleJust                = "CenterLeft"
;  pnlres@lbTitleFontHeightF         = 0.0075
;  pnlres@lbLabelStride              = stride1
;  pnlres@lbLabelFontHeightF         = 0.0095
;  pnlres@pmLabelBarWidthF           = 0.65
;  pnlres@pmLabelBarHeightF          = 0.1
  pnlres@gsnMaximize                = True             ; fill the page

;;;;;;;;;
;; Denmark Strait Only plotted 
;;;;;;;;;
print("Plotting Denmark Strait")
wks = gsn_open_wks("ps" ,fout2)
additional_colors = (/"gray85","yellow", "purple", "red"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot2 = new(6, graphic)

opts1 = res1
opts1@mpLimitMode                 = "LatLon"
opts1@mpMinLatF                   = 64.0
opts1@mpMaxLatF                   = 71.0
opts1@mpMinLonF                   = -35.0
opts1@mpMaxLonF                   = -15.0

opts2 = res2
opts2@mpLimitMode                 = "LatLon"
opts2@mpMinLatF                   = 64.0
opts2@mpMaxLatF                   = 71.0
opts2@mpMinLonF                   = -35.0
opts2@mpMaxLonF                   = -15.0

;;;;;;;;;;;;;
; Plot 0 
  opts1@tiMainString                = tag0 
  cplot0 = gsn_csm_contour_map(wks, var0, opts1) 
  iplot = gsn_csm_contour(wks,ice0,res_ice)
  overlay(cplot0,iplot)
  plot2(0) = cplot0

;;;;;;;;;;;;;
; Plot 1 
;;;;;;;;;;;;;
  opts1@tiMainString                = tag1
  cplot1 = gsn_csm_contour_map(wks, var1, opts1)    
  iplot = gsn_csm_contour(wks,ice0,res_ice)
  overlay(cplot1,iplot)
  plot2(3) = cplot1

;;;;;;;;;;;;;
; Plot 2 
;;;;;;;;;;;;;
  opts1@tiMainString                = tag2
  cplot2 = gsn_csm_contour_map(wks, var2, opts1) 
  iplot = gsn_csm_contour(wks,ice0,res_ice)
  overlay(cplot2,iplot)
  plot2(1) = cplot2

;;;;;;;;;;;;;
; Plot 3 
;;;;;;;;;;;;;
  opts1@tiMainString                = tag3
  cplot3 = gsn_csm_contour_map(wks, var3, opts1)   
  iplot = gsn_csm_contour(wks,ice0,res_ice)
  overlay(cplot3,iplot)
  plot2(4) = cplot3

;;;;;;;;;;;;;
; Plot 4 
;;;;;;;;;;;;;
  opts2@tiMainString                = tag0+" - "+tag2
  cplot1 = gsn_csm_contour_map(wks, diff_1, opts2)    
  iplot = gsn_csm_contour(wks,ice0,res_ice)
  overlay(cplot1,iplot)
  plot2(2) = cplot1

;;;;;;;;;;;;;
; Plot 5 
;;;;;;;;;;;;;
  opts2@tiMainString                = tag1+" - "+tag3
  cplot2 = gsn_csm_contour_map(wks, diff_2, opts2) 
  iplot = gsn_csm_contour(wks,ice0,res_ice)
  overlay(cplot2,iplot)
  plot2(5) = cplot2

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  pnlres@txString                   = varcode+" WRF Denmark Strait comparison: "+date
  gsn_panel(wks,(/plot2/),(/2,3/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout2+".ps "+fout2+".png")

delete([/opts1,opts2/])


if (whole_dom .eq. "1")then
;;;;;;;;;
;; Whole domain plotted 
;;;;;;;;;
print("Making whole domain plot")
wks = gsn_open_wks("ps" ,fout1)
additional_colors = (/"gray85","yellow", "purple", "red"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(6, graphic)

opts1 = res1
opts1@mpLimitMode = "Corners"
opts1@mpLeftCornerLatF            = lat2d_0(0,0)     ; set the lat/lon sides
opts1@mpLeftCornerLonF            = lon2d_0(0,0)
opts1@mpRightCornerLatF           = lat2d_0(n_sn_0-1,n_we_0-1) 
opts1@mpRightCornerLonF           = lon2d_0(n_sn_0-1,n_we_0-1)

opts2 = res2
opts2@mpLimitMode = "Corners"
opts2@mpLeftCornerLatF            = lat2d_1(0,0)     ; set the lat/lon sides
opts2@mpLeftCornerLonF            = lon2d_1(0,0)
opts2@mpRightCornerLatF           = lat2d_1(n_sn_1-1,n_we_1-1) 
opts2@mpRightCornerLonF           = lon2d_1(n_sn_1-1,n_we_1-1)

;;;;;;;;;;;;;
; Plot 0 
  opts1@tiMainString                = tag0 
  plot(0) = gsn_csm_contour_map(wks, var0, opts1) 

;;;;;;;;;;;;;
; Plot 1 
  opts1@tiMainString                = tag1
  plot(3) = gsn_csm_contour_map(wks, var1, opts1)    

;;;;;;;;;;;;;
; Plot 2 
  opts1@tiMainString                = tag2
  plot(1) = gsn_csm_contour_map(wks, var2, opts1) 

;;;;;;;;;;;;;
; Plot 3
  opts1@tiMainString                = tag3
  plot(4) = gsn_csm_contour_map(wks, var3, opts1)   

;;;;;;;;;;;;;
; Plot 4 
  opts2@tiMainString                = tag0+" - "+tag2
  plot(2) = gsn_csm_contour_map(wks, diff_1, opts2)    

;;;;;;;;;;;;;
; Plot 5 
  opts2@tiMainString                = tag1+" - "+tag3
  plot(5) = gsn_csm_contour_map(wks, diff_2, opts2) 

;;;;;;;;;;;;;
; Panel
  print("Paneling whole domain plots")
  pnlres@txString                   = varcode+" WRF Greenland comparison: "+date
  gsn_panel(wks,(/plot/),(/2,3/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout1+".ps "+fout1+".png")

delete([/opts1,opts2/])
end if

;;;;;;;;;;;;;;;;;;;;;; END script
end
