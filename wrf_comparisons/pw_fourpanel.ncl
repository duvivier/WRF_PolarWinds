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
;date = "2015-05-21_23-00"
;varcode = "SH"
;pbl = "U"

; BEGIN SCRIPT
; set directory
  dir = "/data/duvivier/polar_winds/DATA/"
; set simulation tag names
  tag0 = "PW-05-40-"+pbl
  tag1 = "PW-10-40-"+pbl
  tag2 = "PW-25-40-"+pbl
  tag3 = "PW-50-40-"+pbl
; set outdir and fout names
outdir = "./"
fout1  = outdir+varcode+"_pw_comparison_"+tag0+"_"+date
fout2  = outdir+varcode+"_pw_comparison_zoom_"+tag0+"_"+date

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
 if (varcode.eq."SWUS") then
    vartitle1 = "Shortwave up at surface"
    invar1 = "SW_u"
    vartype = "2d"
    cmaptype = "swflux"
  end if
  if (varcode.eq."LWDS") then
    vartitle1 = "Longwave down at surface"
    invar1 = "LW_d"
    cmaptype = "lwflux"
  end if
  if (varcode.eq."LWUS") then
    vartitle1 = "Longwave up at surface"
    invar1 = "LW_u"
    cmaptype = "lwflux"
  end if

; Set the contour interval for each input variable   
; set contour limits manually:
  if (cmaptype.eq."speed") then
    cmin1               = 0.
    cmax1               = 20.
    clev1               = 1.
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 129                ; end at color
    colormap            = "MPL_BuPu"
  end if
  if (cmaptype.eq."pressure") then
    cmin1               = 920
    cmax1               = 1064.
    clev1               = 2.
    stride1             = 4                 ; label stride
    plotlines           = True              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74                ; end at color
    colormap            = "slp_anoms.dave"
  end if
  if (cmaptype.eq."temperature") then
    cmin1               = -16.
    cmax1               = 16.
    clev1               = 2.
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    colormap            = "temp64_anoms.dave"
  end if
  if (cmaptype.eq."mix_rad") then
    cmin1               =  0.
    cmax1               =  0.04
    clev1               =  0.002
    stride1             = 4                 ; label stride
    plotlines           = True              ; lines for reg plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."flux") then
    cmin1               =  -100.
    cmax1               =  100.
    clev1               =  10.
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 254               ; end at color
    spreadstart2        = 2                 ; start at color
    spreadend2          = 254               ; end at color
    colormap            = "BlueYellowRed"
    cminO               =  -400.            ; set overlay information
    cmaxO               =  400.
    clevO               =  50.
    strideO             = 2
    plotlinesO          = True
  end if
  if (cmaptype.eq."precip") then
    cmin1               =  0.
    cmax1               =  300.
    clev1               =  25.
    stride1             = 4                 ; label stride
    plotlines           = False             ; lines for reg plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 51                ; start at color
    spreadend1          = 103               ; end at color
    colormap            = "BrownBlue"
  end if
  if (cmaptype.eq."lwflux") then
    cmin1               =  0.
    cmax1               =  400.
    clev1               =  10.
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 52                 ; start at color
    spreadend1          = 102               ; end at color
    colormap            = "BlWhRe"
  end if
  if (cmaptype.eq."swflux") then
    cmin1               =  0.
    cmax1               =  400.
    clev1               =  10.
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"
    spreadstart1        = 52                 ; start at color
    spreadend1          = 102               ; end at color
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
hgt_2 = f2->Z_sfc
lat2d_2 = f2->lat
lon2d_2 = f2->lon
dims = dimsizes(lat2d_2)     ; get lat/lon dimensions from third domain
n_sn_2 = dims(0)              ; get south/north points
n_we_2 = dims(1)              ; get west/east points
delete(dims)

; Load in fourth file to compare
f3 = addfile(dir+tag3+"/wrfout-cf/wrf-"+date+"."+tag3+"-cf.nc","r")
hgt_3 = f3->Z_sfc
lat2d_3 = f3->lat
lon2d_3 = f3->lon
dims = dimsizes(lat2d_3)     ; get lat/lon dimensions from fourth domain
n_sn_3 = dims(0)              ; get south/north points
n_we_3 = dims(1)              ; get west/east points
delete(dims)

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
u1 = f1->u_10m_tr(0,:,:)
v1 = f1->v_10m_tr(0,:,:)
ice1 = f1->SeaIce(0,:,:)

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
u2 = f2->u_10m_tr(0,:,:)
v2 = f2->v_10m_tr(0,:,:)
ice2 = f2->SeaIce(0,:,:)

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
u3 = f3->u_10m_tr(0,:,:)
v3 = f3->v_10m_tr(0,:,:)
ice3 = f3->SeaIce(0,:,:)

print("Loaded variables")

; for sea level pressure, mask above 500m
if (varcode .eq. "SLP") then
  var0 = where(hgt_0.le.500.0, var0, var0@_FillValue)
  var1 = where(hgt_1.le.500.0, var1, var1@_FillValue)
  var2 = where(hgt_2.le.500.0, var2, var2@_FillValue)
  var3 = where(hgt_3.le.500.0, var3, var3@_FillValue)
end if

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" "+tag0+" min: "+min(var0)+"  max: "+max(var0)) 
  print(vartitle1+" "+tag1+" min: "+min(var1)+"  max: "+max(var1)) 
  print(vartitle1+" "+tag2+" min: "+min(var2)+"  max: "+max(var2))
  print(vartitle1+" "+tag3+" min: "+min(var3)+"  max: "+max(var3))

; assign 2d lat and lon attributes for plotting:
  var0@lat2d  = lat2d_0
  var0@lon2d  = lon2d_0
  var1@lat2d  = lat2d_1
  var1@lon2d  = lon2d_1
  var2@lat2d  = lat2d_2
  var2@lon2d  = lon2d_2
  var3@lat2d  = lat2d_3
  var3@lon2d  = lon2d_3
  ice0@lat2d  = lat2d_0
  ice0@lon2d  = lon2d_0
  ice1@lat2d  = lat2d_1
  ice1@lon2d  = lon2d_1
  ice2@lat2d  = lat2d_2
  ice2@lon2d  = lon2d_2
  ice3@lat2d  = lat2d_3
  ice3@lon2d  = lon2d_3

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

; resources for vector plots if it's a wind plot
vcres                            = True ;res
vcres@gsnDraw                    = False
vcres@gsnFrame                   = False
vcres@vcGlyphStyle               = "LineArrow"
vcres@vcRefMagnitudeF            = 1.0
vcres@vcRefLengthF               = 0.005
vcres@vcMonoLineArrowColor       = True
vcres@vcLineArrowColor           = "black"
vcres@vcMinDistanceF             = 0.07
vcres@vcRefAnnoOn                = False
vcres@gsnLeftString              = ""
vcres@gsnRightString             = ""
;vcres@gsnScalarContour           = True
;vcres@cnInfoLabelOn              = False
;vcres@mpOutlineOn                = True
;vcres@mpOutlineBoundarySets      = "AllBoundaries" 

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
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbTitleString              = var0@units
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
;; Whole domain plotted 
;;;;;;;;;
print("Making whole domain plot")
wks = gsn_open_wks("ps" ,fout1)
additional_colors = (/"gray85","yellow", "purple", "red"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(4, graphic)

opts = res
opts@mpLimitMode = "Corners"
;;;;;;;;;;;;;
; Plot 0 
  opts0                             = opts              ; reset options
  opts0@tiMainString                = "WRF "+tag0 
  opts0@mpLeftCornerLatF            = lat2d_0(0,0)     ; set the lat/lon sides
  opts0@mpLeftCornerLonF            = lon2d_0(0,0)
  opts0@mpRightCornerLatF           = lat2d_0(n_sn_0-1,n_we_0-1) 
  opts0@mpRightCornerLonF           = lon2d_0(n_sn_0-1,n_we_0-1)
;  plot(0) = gsn_csm_contour_map(wks, var0, opts0) 

;;;;;;;;;;;;;
; Plot 1 
  opts1                             = opts              ; reset options
  opts1@tiMainString                = "WRF "+tag1
  opts1@mpLeftCornerLatF            = lat2d_1(0,0)     ; set the lat/lon sides
  opts1@mpLeftCornerLonF            = lon2d_1(0,0)
  opts1@mpRightCornerLatF           = lat2d_1(n_sn_1-1,n_we_1-1) 
  opts1@mpRightCornerLonF           = lon2d_1(n_sn_1-1,n_we_1-1)
;  plot(1) = gsn_csm_contour_map(wks, var1, opts1)    

;;;;;;;;;;;;;
; Plot 2 
  opts2                             = opts              ; reset options
  opts2@tiMainString                = "WRF "+tag2
  opts2@mpLeftCornerLatF            = lat2d_2(0,0)     ; set the lat/lon sides
  opts2@mpLeftCornerLonF            = lon2d_2(0,0)
  opts2@mpRightCornerLatF           = lat2d_2(n_sn_2-1,n_we_2-1) 
  opts2@mpRightCornerLonF           = lon2d_2(n_sn_2-1,n_we_2-1)
;  plot(2) = gsn_csm_contour_map(wks, var2, opts2) 

;;;;;;;;;;;;;
; Plot 3
  opts3                             = opts              ; reset options
  opts3@tiMainString                = "WRF "+tag3
  opts3@mpLeftCornerLatF            = lat2d_3(0,0)     ; set the lat/lon sides
  opts3@mpLeftCornerLonF            = lon2d_3(0,0)
  opts3@mpRightCornerLatF           = lat2d_3(n_sn_3-1,n_we_3-1) 
  opts3@mpRightCornerLonF           = lon2d_3(n_sn_3-1,n_we_3-1)
;  plot(3) = gsn_csm_contour_map(wks, var3, opts3)   

;;;;;;;;;;;;;
; Panel
  print("Paneling whole domain plots")
  pnlres@txString                   = vartitle1+": "+date
;  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
;system("convert -trim -border 10 -bordercolor white -density 300 "+  \
;         "-rotate -90 -trim -border 10 "+fout1+".ps "+fout1+".png")
delete(opts)

;;;;;;;;;
;; Denmark Strait Only plotted 
;;;;;;;;;
print("Plotting Denmark Strait")
wks = gsn_open_wks("ps" ,fout2)
additional_colors = (/"gray85","yellow", "purple", "red"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot2 = new(4, graphic)

opts = res
opts@mpLimitMode                 = "LatLon"
opts@mpMinLatF                   = 64.0
opts@mpMaxLatF                   = 71.0
opts@mpMinLonF                   = -35.0
opts@mpMaxLonF                   = -15.0

;;;;;;;;;;;;;
; Plot 0 
  opts0                             = opts              ; reset options
  opts0@tiMainString                = "WRF "+tag0 
  cplot0 = gsn_csm_contour_map(wks, var0, opts0) 
  iplot = gsn_csm_contour(wks,ice0,res_ice)
  overlay(cplot0,iplot)
  plot2(0) = cplot0

;;;;;;;;;;;;;
; Plot 1 
;;;;;;;;;;;;;
  opts1                             = opts              ; reset options
  opts1@tiMainString                = "WRF"+tag1
  cplot1 = gsn_csm_contour_map(wks, var1, opts1)    
  iplot = gsn_csm_contour(wks,ice1,res_ice)
  overlay(cplot1,iplot)
  plot2(1) = cplot1

;;;;;;;;;;;;;
; Plot 2 
;;;;;;;;;;;;;
  opts2                             = opts              ; reset options
  opts2@tiMainString                = "WRF "+tag2
  cplot2 = gsn_csm_contour_map(wks, var2, opts2) 
  iplot = gsn_csm_contour(wks,ice2,res_ice)
  overlay(cplot2,iplot)
  plot2(2) = cplot2

;;;;;;;;;;;;;
; Plot 3 
;;;;;;;;;;;;;
  opts3                             = opts              ; reset options
  opts3@tiMainString                = "WRF "+tag3
  cplot3 = gsn_csm_contour_map(wks, var3, opts3)   
  iplot = gsn_csm_contour(wks,ice3,res_ice)
  overlay(cplot3,iplot)
  plot2(3) = cplot3

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  pnlres@txString                   = "WRF Denmark Strait comparison: "+date
  gsn_panel(wks,(/plot2/),(/2,2/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout2+".ps "+fout2+".png")



return


    ; Method 1 (works with differing or same grids for U/V and var1)
    cplot = gsn_csm_contour_map(wks,var1_2d,res)
    iplot = gsn_csm_contour(wks,seaice_2d,res_ice)
    mplot = gsn_csm_contour(wks,var1_2d,res_max)
    vplot = gsn_csm_vector(wks,U_2d,V_2d,vcres)
    overlay(cplot,iplot)
    overlay(cplot,mplot)
    overlay(cplot,vplot)
    dum1(n) = gsn_add_text(wks,cplot,"("+xpos+","+ypos+")", lon_t1, lat_t1, txres)
    dum2(n) = gsn_add_text(wks,cplot,pcnt_txt,lon_t2,lat_t2,txres)
    plot(n) = cplot
    delete([/var1_2d,seaice_2d,U_2d,V_2d/])

;;;;;;;;;;;;;;;;;;;;;; END script
end
