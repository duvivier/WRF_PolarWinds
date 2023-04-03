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
fname0 = "met_em-2015-05-20_00.era_i-50km.nc"
fname1 = "met_em-2015-05-20_12.era_i-50km.nc"
fname2 = "met_em-2015-05-20_18.era_i-50km.nc"
fname3 = "met_em-2015-05-21_00.era_i-50km.nc"
fname4 = "met_em-2015-05-21_06.era_i-50km.nc"
fname5 = "met_em-2015-05-21_12.era_i-50km.nc"
fname6 = "met_em-2015-05-21_18.era_i-50km.nc"
fname7 = "met_em-2015-05-22_00.era_i-50km.nc"

; BEGIN SCRIPT
print("Plotting ERA SLP and winds")
; set contour limits for wind:
cmin1               = 0.
cmax1               = 20.
clev1               = 1.
stride1             = 2                 ; label stride
plotlines1          = False              ; lines for reg plot
cntype              = "AreaFill"
spreadstart1        = 2                 ; start at color
spreadend1          = 129                ; end at color
colormap            = "MPL_BuPu"
; set contour limits for slp:
cmin2               = 920
cmax2               = 1064.
clev2               = 2.
stride2             = 4                 ; label stride
plotlines2          = True              ; lines for reg plot

; set directories based on WRF run type
outdir = "./"
dir = "/data/duvivier/polar_winds/DATA/ERA_I/old/"
;title_fin = "ERA_I (interp to 50km) SLP and Wind field on 2015-05-"+day
fout = outdir+"era_i-SLP_wind-synoptic"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in ascat file
;;;;;;;;;;
; Load in first file to compare
f0 = addfile(dir+fname0,"r")
   ; latitude
   lat2d = f0->XLAT_M(0,:,:)
   ; longitude
   lon2d = f0->XLONG_M(0,:,:)
   ; terrain
   hgt = f0->HGT_M(0,:,:)
   ; SLP
   slp_0 = f0->PMSL(0,:,:)
   slp_0 = slp_0/100.0
   ; UU
   dum = f0->UU(0,0,:,:)
   u_0 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = f0->VV(0,0,:,:)
   v_0 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_0 = sqrt(u_0^2 + v_0^2)

; Load in second file to compare
f1 = addfile(dir+fname1,"r")
   ; SLP
   slp_1 = f1->PMSL(0,:,:)
   slp_1 = slp_1/100.0
   ; UU
   dum = f1->UU(0,0,:,:)
   u_1 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = f1->VV(0,0,:,:)
   v_1 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_1 = sqrt(u_1^2 + v_1^2)

; Load in third file to compare
f2 = addfile(dir+fname2,"r")
   ; SLP
   slp_2 = f2->PMSL(0,:,:)
   slp_2 = slp_2/100.0
   ; UU
   dum = f2->UU(0,0,:,:)
   u_2 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = f2->VV(0,0,:,:)
   v_2 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_2 = sqrt(u_2^2 + v_2^2)

; Load in fourth file to compare
f3 = addfile(dir+fname3,"r")
   ; SLP
   slp_3 = f3->PMSL(0,:,:)
   slp_3 = slp_3/100.0
   ; UU
   dum = f3->UU(0,0,:,:)
   u_3 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = f3->VV(0,0,:,:)
   v_3 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_3 = sqrt(u_3^2 + v_3^2)

; Load in fourth file to compare
f4 = addfile(dir+fname4,"r")
   ; SLP
   slp_4 = f4->PMSL(0,:,:)
   slp_4 = slp_4/100.0
   ; UU
   dum = f4->UU(0,0,:,:)
   u_4 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = f4->VV(0,0,:,:)
   v_4 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_4 = sqrt(u_4^2 + v_4^2)

; Load in fourth file to compare
f5 = addfile(dir+fname5,"r")
   ; SLP
   slp_5 = f5->PMSL(0,:,:)
   slp_5 = slp_5/100.0
   ; UU
   dum = f5->UU(0,0,:,:)
   u_5 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = f5->VV(0,0,:,:)
   v_5 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_5 = sqrt(u_5^2 + v_5^2)

; Load in fourth file to compare
f6 = addfile(dir+fname6,"r")
   ; SLP
   slp_6 = f6->PMSL(0,:,:)
   slp_6 = slp_6/100.0
   ; UU
   dum = f6->UU(0,0,:,:)
   u_6 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = f6->VV(0,0,:,:)
   v_6 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_6 = sqrt(u_6^2 + v_6^2)

; Load in fourth file to compare
f7 = addfile(dir+fname7,"r")
   ; SLP
   slp_7 = f7->PMSL(0,:,:)
   slp_7 = slp_7/100.0
   ; UU
   dum = f7->UU(0,0,:,:)
   u_7 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = f7->VV(0,0,:,:)
   v_7 = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_7 = sqrt(u_7^2 + v_7^2)


; assign lat/lon
  slp_0@lat2d = lat2d
  slp_0@lon2d = lon2d
  slp_0@_FillValue = -999.99
  copy_VarMeta(slp_0, slp_1)
  copy_VarMeta(slp_0, slp_2)
  copy_VarMeta(slp_0, slp_3)
  copy_VarMeta(slp_0, slp_4)
  copy_VarMeta(slp_0, slp_5)
  copy_VarMeta(slp_0, slp_6)
  copy_VarMeta(slp_0, slp_7)
  u_0@lat2d = lat2d
  u_0@lon2d = lon2d
  u_0@_FillValue = -999.99
  copy_VarMeta(u_0, u_1)
  copy_VarMeta(u_0, u_2)
  copy_VarMeta(u_0, u_3)
  copy_VarMeta(u_0, u_4)
  copy_VarMeta(u_0, u_5)
  copy_VarMeta(u_0, u_6)
  copy_VarMeta(u_0, u_7)  
  v_0@lat2d = lat2d
  v_0@lon2d = lon2d
  v_0@_FillValue = -999.99
  copy_VarMeta(v_0, v_1)
  copy_VarMeta(v_0, v_2)
  copy_VarMeta(v_0, v_3)
  copy_VarMeta(v_0, v_4)
  copy_VarMeta(v_0, v_5)
  copy_VarMeta(v_0, v_6)
  copy_VarMeta(v_0, v_7)   
  ws_0@lat2d = lat2d
  ws_0@lon2d = lon2d
  ws_0@_FillValue = -999.99
  copy_VarMeta(ws_0, ws_1)
  copy_VarMeta(ws_0, ws_2)
  copy_VarMeta(ws_0, ws_3)
  copy_VarMeta(ws_0, ws_4)
  copy_VarMeta(ws_0, ws_5)
  copy_VarMeta(ws_0, ws_6)
  copy_VarMeta(ws_0, ws_7)  


; mask based on height (>500m)
  slp_0 = where(hgt.lt.500.0, slp_0, slp_0@_FillValue)
  u_0   = where(hgt.lt.500.0, u_0, u_0@_FillValue)
  v_0   = where(hgt.lt.500.0, v_0, v_0@_FillValue)
  ws_0  = where(hgt.lt.500.0, ws_0, ws_0@_FillValue)
  slp_1 = where(hgt.lt.500.0, slp_1, slp_1@_FillValue)
  u_1   = where(hgt.lt.500.0, u_1, u_1@_FillValue)
  v_1   = where(hgt.lt.500.0, v_1, v_1@_FillValue)
  ws_1  = where(hgt.lt.500.0, ws_1, ws_1@_FillValue)
  slp_2 = where(hgt.lt.500.0, slp_2, slp_2@_FillValue)
  u_2   = where(hgt.lt.500.0, u_2, u_2@_FillValue)
  v_2   = where(hgt.lt.500.0, v_2, v_2@_FillValue)
  ws_2  = where(hgt.lt.500.0, ws_2, ws_2@_FillValue)
  slp_3 = where(hgt.lt.500.0, slp_3, slp_3@_FillValue)
  u_3   = where(hgt.lt.500.0, u_3, u_3@_FillValue)
  v_3   = where(hgt.lt.500.0, v_3, v_3@_FillValue)
  ws_3  = where(hgt.lt.500.0, ws_3, ws_3@_FillValue)  
  slp_4 = where(hgt.lt.500.0, slp_4, slp_4@_FillValue)
  u_4   = where(hgt.lt.500.0, u_4, u_4@_FillValue)
  v_4   = where(hgt.lt.500.0, v_4, v_4@_FillValue)
  ws_4  = where(hgt.lt.500.0, ws_4, ws_4@_FillValue)
  slp_5 = where(hgt.lt.500.0, slp_5, slp_5@_FillValue)
  u_5   = where(hgt.lt.500.0, u_5, u_5@_FillValue)
  v_5   = where(hgt.lt.500.0, v_5, v_5@_FillValue)
  ws_5  = where(hgt.lt.500.0, ws_5, ws_5@_FillValue)
  slp_6 = where(hgt.lt.500.0, slp_6, slp_6@_FillValue)
  u_6   = where(hgt.lt.500.0, u_6, u_6@_FillValue)
  v_6   = where(hgt.lt.500.0, v_6, v_6@_FillValue)
  ws_6  = where(hgt.lt.500.0, ws_6, ws_6@_FillValue)
  slp_7 = where(hgt.lt.500.0, slp_7, slp_7@_FillValue)
  u_7   = where(hgt.lt.500.0, u_7, u_7@_FillValue)
  v_7   = where(hgt.lt.500.0, v_7, v_7@_FillValue)
  ws_7  = where(hgt.lt.500.0, ws_7, ws_7@_FillValue)

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
  res@mpMinLatF                   = 59.0  ;64.0
  res@mpMaxLatF                   = 75.0  ;71.0
  res@mpMinLonF                   = -50.0 ;-35.0
  res@mpMaxLonF                   = -15.0 ;-15.0
  res@tiMainFontHeightF           = 0.025
  res@tiMainFontThicknessF        = 1.5
  res@lbLabelBarOn                = False             ; turn off individual label bars

  ; wind speed resources
  res@cnFillMode                 = cntype
  res@cnFillOn                   = True              ; turn on filled contours
  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = cmin1             ; set min contour level specified above
  res@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  res@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  res@cnLinesOn                  = plotlines1        ; contour lines specified above
  res@cnLineLabelsOn             = plotlines1        ; line labels on specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in

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
  vcres@vcRefAnnoOn                = False
  vcres@gsnLeftString              = ""
  vcres@gsnRightString             = ""
  ;vcres@vcRefAnnoFontHeightF       = 0.025
  ;vcres@vcRefAnnoString1           = "2 m s~S~-1"
  ;vcres@vcRefAnnoString2           = ""

  ; slp resources for overlay
  res_slp                            = True               ; reset options
  res_slp@gsnLeftString              = ""
  res_slp@gsnRightString             = ""
  res_slp@gsnFrame                   = False             ; Do not draw plot 
  res_slp@gsnDraw                    = False             ; Do not advance fr
  res_slp@cnInfoLabelOn              = False             ; Turn off info on contours at bottom
  res_slp@cnFillOn                   = False             ; turn on filled contours
  res_slp@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res_slp@cnMinLevelValF             = cmin2             ; set min contour level specified above
  res_slp@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  res_slp@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  res_slp@cnLinesOn                  = plotlines2        ; contour lines specified above
  res_slp@cnLineLabelsOn             = plotlines2        ; line labels on specified above
  res_slp@cnLineColor                = "black"
  res_slp@cnLineThicknessF           = 1.0
  res_slp@tiXAxisOn                  = False
  res_slp@tiYAxisOn                  = False

; set text res for labels
  txres                           = True
  txres@txFontHeightF             = 0.025 
  txres@txFontThicknessF          = 2.
  txres@txFont                    = 22
  txres@txBackgroundFillColor     = "white"
  lat_txt                         = 75.0
  lon_txt                         = -38.0 

; panel resources
  pnlres                            = True
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbTitleString              = "m s-1"
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
print("Plotting Windspeed, SLP, wind vectors")
wks = gsn_open_wks("ps" ,fout)
additional_colors = (/"gray85","yellow", "purple", "red"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(8, graphic)

; Plot 0 - 00Z
  opts                             = res
;  opts@tiMainString                = "May 20, 00Z"
  cplot = gsn_csm_contour_map(wks, ws_0, opts)
  splot = gsn_csm_contour(wks,slp_0,res_slp)
  vplot = gsn_csm_vector(wks,u_0,v_0,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot) 
  dum0 = new(1,graphic)
  dum0 = gsn_add_text(wks,cplot,"a) 0000UTC 20 May",lon_txt,lat_txt,txres)
  plot(0) = cplot
  delete(opts)

; Plot 1 - 06Z
  opts                             = res
;  opts@tiMainString                = "May 20, 12Z"
  cplot = gsn_csm_contour_map(wks, ws_1, opts)
  splot = gsn_csm_contour(wks,slp_1,res_slp)
  vplot = gsn_csm_vector(wks,u_1,v_1,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot)
  dum1 = new(1,graphic)
  dum1 = gsn_add_text(wks,cplot,"b) 1200UTC 20 May",lon_txt,lat_txt,txres) 
  plot(1) = cplot
  delete(opts)

; Plot 2 - 12Z
  opts                             = res
;  opts@tiMainString                = "May 20, 18Z"
  cplot = gsn_csm_contour_map(wks, ws_2, opts)
  splot = gsn_csm_contour(wks,slp_2,res_slp)
  vplot = gsn_csm_vector(wks,u_2,v_2,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot) 
  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks,cplot,"c) 1800UTC 20 May",lon_txt,lat_txt,txres)
  plot(2) = cplot
  delete(opts)

; Plot 3 - 06Z
  opts                             = res
;  opts@tiMainString                = "May 21, 00Z"
  cplot = gsn_csm_contour_map(wks, ws_3, opts)
  splot = gsn_csm_contour(wks,slp_3,res_slp)
  vplot = gsn_csm_vector(wks,u_3,v_3,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot)
  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks,cplot,"d) 0000UTC 21 May",lon_txt,lat_txt,txres) 
  plot(3) = cplot
  delete(opts)

; Plot 0 - 00Z
  opts                             = res
;  opts@tiMainString                = "May 21, 06Z"
  cplot = gsn_csm_contour_map(wks, ws_4, opts)
  splot = gsn_csm_contour(wks,slp_4,res_slp)
  vplot = gsn_csm_vector(wks,u_4,v_4,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot)
  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks,cplot,"e) 0600UTC 21 May",lon_txt,lat_txt,txres) 
  plot(4) = cplot
  delete(opts)

; Plot 1 - 06Z
  opts                             = res
;  opts@tiMainString                = "May 21, 12Z"
  cplot = gsn_csm_contour_map(wks, ws_5, opts)
  splot = gsn_csm_contour(wks,slp_5,res_slp)
  vplot = gsn_csm_vector(wks,u_5,v_5,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot)
  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks,cplot,"f) 1200UTC 21 May",lon_txt,lat_txt,txres) 
  plot(5) = cplot
  delete(opts)

; Plot 2 - 12Z
  opts                             = res
;  opts@tiMainString                = "May 21, 18Z"
  cplot = gsn_csm_contour_map(wks, ws_6, opts)
  splot = gsn_csm_contour(wks,slp_6,res_slp)
  vplot = gsn_csm_vector(wks,u_6,v_6,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot)
  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks,cplot,"g) 1800UTC 21 May",lon_txt,lat_txt,txres) 
  plot(6) = cplot
  delete(opts)

; Plot 3 - 06Z
  opts                             = res
;  opts@tiMainString                = "May 22, 00Z"
  cplot = gsn_csm_contour_map(wks, ws_7, opts)
  splot = gsn_csm_contour(wks,slp_7,res_slp)
  vplot = gsn_csm_vector(wks,u_7,v_7,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot)
  dum7 = new(1,graphic)
  dum7 = gsn_add_text(wks,cplot,"h) 0000UTC 22 May",lon_txt,lat_txt,txres) 
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
