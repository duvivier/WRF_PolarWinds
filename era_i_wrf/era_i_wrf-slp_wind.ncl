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
;day = "20"  ; "20" "21"
;tagb = "PW-50-40-M-bn"

; BEGIN SCRIPT
print("Plotting ERA SLP and winds on May "+day+" 2015")
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
dir = "/data/duvivier/polar_winds/DATA/"
dira = dir+"ERA_I/met_em/50km/"
fname0a = "met_em.d01.2015-05-"+day+"_00:00:00.nc"
fname1a = "met_em.d01.2015-05-"+day+"_06:00:00.nc"
fname2a = "met_em.d01.2015-05-"+day+"_12:00:00.nc"
fname3a = "met_em.d01.2015-05-"+day+"_18:00:00.nc"

dirb = dir+tagb+"/wrfout-cf/"
fname0b = "wrf-2015-05-"+day+"_00-00."+tagb+"-cf.nc"
fname1b = "wrf-2015-05-"+day+"_06-00."+tagb+"-cf.nc"
fname2b = "wrf-2015-05-"+day+"_12-00."+tagb+"-cf.nc"
fname3b = "wrf-2015-05-"+day+"_18-00."+tagb+"-cf.nc"



title_fin = "ERA_I and WRF ("+tagb+") SLP and Wind field on 2015-05-"+day
fout = outdir+"era_i-wrf-"+tagb+"-SLP_wind-2015-05-"+day

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in ERA files
;;;;;;;;;;
; Load in first ERA file to compare
fin = addfile(dira+fname0a,"r")
   ; latitude
   lat2d_a = fin->XLAT_M(0,:,:)
   ; longitude
   lon2d_a = fin->XLONG_M(0,:,:)
   ; terrain
   hgt_a = fin->HGT_M(0,:,:)
   ; SLP
   slp_0a = fin->PMSL(0,:,:)
   slp_0a = slp_0a/100.0
   ; UU
   dum = fin->UU(0,0,:,:)
   u_0a = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = fin->VV(0,0,:,:)
   v_0a = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_0a = sqrt(u_0a^2 + v_0a^2)
   delete(fin)

; Load in second file to compare
fin = addfile(dira+fname1a,"r")
   ; SLP
   slp_1a = fin->PMSL(0,:,:)
   slp_1a = slp_1a/100.0
   ; UU
   dum = fin->UU(0,0,:,:)
   u_1a = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = fin->VV(0,0,:,:)
   v_1a = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_1a = sqrt(u_1a^2 + v_1a^2)
   delete(fin)

; Load in third file to compare
fin = addfile(dira+fname2a,"r")
   ; SLP
   slp_2a = fin->PMSL(0,:,:)
   slp_2a = slp_2a/100.0
   ; UU
   dum = fin->UU(0,0,:,:)
   u_2a = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = fin->VV(0,0,:,:)
   v_2a = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_2a = sqrt(u_2a^2 + v_2a^2)
   delete(fin)

; Load in fourth file to compare
fin = addfile(dira+fname3a,"r")
   ; SLP
   slp_3a = fin->PMSL(0,:,:)
   slp_3a = slp_3a/100.0
   ; UU
   dum = fin->UU(0,0,:,:)
   u_3a = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; VV
   dum = fin->VV(0,0,:,:)
   v_3a = wrf_user_unstagger(dum,dum@stagger)
   delete(dum)
   ; Wind speed
   ws_3a = sqrt(u_3a^2 + v_3a^2)
   delete(fin)

;;;;;;;;;;
; load in WRF files
;;;;;;;;;;
; Load in first WRF file to compare
fin = addfile(dirb+fname0b,"r")
   ; latitude
   lat2d_b = fin->lat
   ; longitude
   lon2d_b = fin->lon
   ; terrain
   hgt_b = fin->Z_sfc
   ; SLP
   slp_0b = fin->slp(0,:,:)
   ; UU
   u_0b = fin->u_10m_tr(0,:,:)
   ; VV
   v_0b = fin->v_10m_tr(0,:,:)
   ; Wind speed
   ws_0b = fin->ws_10m(0,:,:)
   delete(fin)

; Load in second WRF file to compare
fin = addfile(dirb+fname1b,"r")
   ; SLP
   slp_1b = fin->slp(0,:,:)
   ; UU
   u_1b = fin->u_10m_tr(0,:,:)
   ; VV
   v_1b = fin->v_10m_tr(0,:,:)
   ; Wind speed
   ws_1b = fin->ws_10m(0,:,:)
   delete(fin)

; Load in third WRF file to compare
fin = addfile(dirb+fname2b,"r")
   ; SLP
   slp_2b = fin->slp(0,:,:)
   ; UU
   u_2b = fin->u_10m_tr(0,:,:)
   ; VV
   v_2b = fin->v_10m_tr(0,:,:)
   ; Wind speed
   ws_2b = fin->ws_10m(0,:,:)
   delete(fin)

; Load in fourth WRF file to compare
fin = addfile(dirb+fname3b,"r")
   ; SLP
   slp_3b = fin->slp(0,:,:)
   ; UU
   u_3b = fin->u_10m_tr(0,:,:)
   ; VV
   v_3b = fin->v_10m_tr(0,:,:)
   ; Wind speed
   ws_3b = fin->ws_10m(0,:,:)
   delete(fin)

; assign lat/lon
  slp_0a@lat2d = lat2d_a
  slp_0a@lon2d = lon2d_a
  slp_0a@_FillValue = -999.99
  copy_VarMeta(slp_0a, slp_1a)
  copy_VarMeta(slp_0a, slp_2a)
  copy_VarMeta(slp_0a, slp_3a)
  u_0a@lat2d = lat2d_a
  u_0a@lon2d = lon2d_a
  u_0a@_FillValue = -999.99
  copy_VarMeta(u_0a, u_1a)
  copy_VarMeta(u_0a, u_2a)
  copy_VarMeta(u_0a, u_3a)  
  v_0a@lat2d = lat2d_a
  v_0a@lon2d = lon2d_a
  v_0a@_FillValue = -999.99
  copy_VarMeta(v_0a, v_1a)
  copy_VarMeta(v_0a, v_2a)
  copy_VarMeta(v_0a, v_3a)  
  ws_0a@lat2d = lat2d_a
  ws_0a@lon2d = lon2d_a
  ws_0a@_FillValue = -999.99
  copy_VarMeta(ws_0a, ws_1a)
  copy_VarMeta(ws_0a, ws_2a)
  copy_VarMeta(ws_0a, ws_3a)

  slp_0b@lat2d = lat2d_b
  slp_0b@lon2d = lon2d_b
  copy_VarMeta(slp_0b, slp_1b)
  copy_VarMeta(slp_0b, slp_2b)
  copy_VarMeta(slp_0b, slp_3b)
  u_0b@lat2d = lat2d_b
  u_0b@lon2d = lon2d_b
  copy_VarMeta(u_0b, u_1b)
  copy_VarMeta(u_0b, u_2b)
  copy_VarMeta(u_0b, u_3b)
  v_0b@lat2d = lat2d_b
  v_0b@lon2d = lon2d_b
  copy_VarMeta(v_0b, v_1b)
  copy_VarMeta(v_0b, v_2b)
  copy_VarMeta(v_0b, v_3b)
  ws_0b@lat2d = lat2d_b
  ws_0b@lon2d = lon2d_b
  copy_VarMeta(ws_0b, ws_1b)
  copy_VarMeta(ws_0b, ws_2b)
  copy_VarMeta(ws_0b, ws_3b)

; mask based on height (>500m)
  slp_0a = where(hgt_a.lt.500.0, slp_0a, slp_0a@_FillValue)
  u_0a   = where(hgt_a.lt.500.0, u_0a, u_0a@_FillValue)
  v_0a   = where(hgt_a.lt.500.0, v_0a, v_0a@_FillValue)
  ws_0a  = where(hgt_a.lt.500.0, ws_0a, ws_0a@_FillValue)
  slp_1a = where(hgt_a.lt.500.0, slp_1a, slp_1a@_FillValue)
  u_1a   = where(hgt_a.lt.500.0, u_1a, u_1a@_FillValue)
  v_1a   = where(hgt_a.lt.500.0, v_1a, v_1a@_FillValue)
  ws_1a  = where(hgt_a.lt.500.0, ws_1a, ws_1a@_FillValue)
  slp_2a = where(hgt_a.lt.500.0, slp_2a, slp_2a@_FillValue)
  u_2a   = where(hgt_a.lt.500.0, u_2a, u_2a@_FillValue)
  v_2a   = where(hgt_a.lt.500.0, v_2a, v_2a@_FillValue)
  ws_2a  = where(hgt_a.lt.500.0, ws_2a, ws_2a@_FillValue)
  slp_3a = where(hgt_a.lt.500.0, slp_3a, slp_3a@_FillValue)
  u_3a   = where(hgt_a.lt.500.0, u_3a, u_3a@_FillValue)
  v_3a   = where(hgt_a.lt.500.0, v_3a, v_3a@_FillValue)
  ws_3a  = where(hgt_a.lt.500.0, ws_3a, ws_3a@_FillValue) 

  slp_0b = where(hgt_b.lt.500.0, slp_0b, slp_0b@_FillValue)
  u_0b   = where(hgt_b.lt.500.0, u_0b, u_0b@_FillValue)
  v_0b   = where(hgt_b.lt.500.0, v_0b, v_0b@_FillValue)
  ws_0b  = where(hgt_b.lt.500.0, ws_0b, ws_0b@_FillValue)
  slp_1b = where(hgt_b.lt.500.0, slp_1b, slp_1b@_FillValue)
  u_1b   = where(hgt_b.lt.500.0, u_1b, u_1b@_FillValue)
  v_1b   = where(hgt_b.lt.500.0, v_1b, v_1b@_FillValue)
  ws_1b  = where(hgt_b.lt.500.0, ws_1b, ws_1b@_FillValue)
  slp_2b = where(hgt_b.lt.500.0, slp_2b, slp_2b@_FillValue)
  u_2b   = where(hgt_b.lt.500.0, u_2b, u_2b@_FillValue)
  v_2b   = where(hgt_b.lt.500.0, v_2b, v_2b@_FillValue)
  ws_2b  = where(hgt_b.lt.500.0, ws_2b, ws_2b@_FillValue)
  slp_3b = where(hgt_b.lt.500.0, slp_3b, slp_3b@_FillValue)
  u_3b   = where(hgt_b.lt.500.0, u_3b, u_3b@_FillValue)
  v_3b   = where(hgt_b.lt.500.0, v_3b, v_3b@_FillValue)
  ws_3b  = where(hgt_b.lt.500.0, ws_3b, ws_3b@_FillValue) 

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

; panel resources
  pnlres                            = True
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbTitleString              = "m s-1"
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
print("Plotting Windspeed, SLP, wind vectors")
wks = gsn_open_wks("ps" ,fout)
additional_colors = (/"gray85","yellow", "purple", "red"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(8, graphic)

; Plot 0 - 00Z
  opts                             = res
  opts@tiMainString                = "ERA: 00Z"
  cplot = gsn_csm_contour_map(wks, ws_0a, opts)
  splot = gsn_csm_contour(wks,slp_0a,res_slp)
  vplot = gsn_csm_vector(wks,u_0a,v_0a,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot) 
  plot(0) = cplot
  delete(opts)

; Plot 1 - 06Z
  opts                             = res
  opts@tiMainString                = "ERA: 06Z"
  cplot = gsn_csm_contour_map(wks, ws_1a, opts)
  splot = gsn_csm_contour(wks,slp_1a,res_slp)
  vplot = gsn_csm_vector(wks,u_1a,v_1a,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot) 
  plot(1) = cplot
  delete(opts)

; Plot 2 - 12Z
  opts                             = res
  opts@tiMainString                = "ERA: 12Z"
  cplot = gsn_csm_contour_map(wks, ws_2a, opts)
  splot = gsn_csm_contour(wks,slp_2a,res_slp)
  vplot = gsn_csm_vector(wks,u_2a,v_2a,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot) 
  plot(2) = cplot
  delete(opts)

; Plot 3 - 18Z
  opts                             = res
  opts@tiMainString                = "ERA: 18Z"
  cplot = gsn_csm_contour_map(wks, ws_3a, opts)
  splot = gsn_csm_contour(wks,slp_3a,res_slp)
  vplot = gsn_csm_vector(wks,u_3a,v_3a,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot) 
  plot(3) = cplot
  delete(opts)

; Plot 4 - 00Z
  opts                             = res
  opts@tiMainString                = "WRF: 00Z"
  cplot = gsn_csm_contour_map(wks, ws_0b, opts)
  splot = gsn_csm_contour(wks,slp_0b,res_slp)
  vplot = gsn_csm_vector(wks,u_0b,v_0b,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot) 
  plot(4) = cplot
  delete(opts)

; Plot 5 - 06Z
  opts                             = res
  opts@tiMainString                = "WRF: 06Z"
  cplot = gsn_csm_contour_map(wks, ws_1b, opts)
  splot = gsn_csm_contour(wks,slp_1b,res_slp)
  vplot = gsn_csm_vector(wks,u_1b,v_1b,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot) 
  plot(5) = cplot
  delete(opts)

; Plot 6 - 12Z
  opts                             = res
  opts@tiMainString                = "WRF: 12Z"
  cplot = gsn_csm_contour_map(wks, ws_2b, opts)
  splot = gsn_csm_contour(wks,slp_2b,res_slp)
  vplot = gsn_csm_vector(wks,u_2b,v_2b,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot) 
  plot(6) = cplot
  delete(opts)

; Plot 7 - 18Z
  opts                             = res
  opts@tiMainString                = "WRF: 18Z"
  cplot = gsn_csm_contour_map(wks, ws_3b, opts)
  splot = gsn_csm_contour(wks,slp_3b,res_slp)
  vplot = gsn_csm_vector(wks,u_3b,v_3b,vcres)
  overlay(cplot,splot)
  overlay(cplot,vplot) 
  plot(7) = cplot
  delete(opts)


; Plot final panel plot 
  pnlres@txString                   = title_fin
  gsn_panel(wks,(/plot/),(/2,4/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
