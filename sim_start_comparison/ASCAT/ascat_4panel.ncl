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
;day = "21"     ;"20" or "21" UTC
;pass = "ASC"   ;"ASC" or "DES"
;sat = "A"      ;"A" or "B" for which satellite
;tag1 = "PW-50-40-M-an"
;tag2 = "PW-50-40-M-bn"
;tag3 = "PW-50-40-M-cn"


; BEGIN SCRIPT
print("Comparing ASCAT satellite "+sat+" to WRF on "+day+" "+pass+" pass")
; Set preferences for Wind variable
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
	 time = "11-40"      	 
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

; WRF data (3 files)
dir_wrf1 = dir+tag1+"/wrfout-cf/"
fname1   = "wrf-2015-05-"+day+"_"+time+"."+tag1+"-cf.nc"

dir_wrf2 = dir+tag2+"/wrfout-cf/"
fname2   = "wrf-2015-05-"+day+"_"+time+"."+tag2+"-cf.nc"

dir_wrf3 = dir+tag3+"/wrfout-cf/"
fname3   = "wrf-2015-05-"+day+"_"+time+"."+tag3+"-cf.nc"

; set title for panel and fout
title_fin = "ASCAT and WRF on May "+day+", "+time+"UTC"
fout = outdir+"ASCAT_WRF_compare_res_"+tag1+"-"+tag2+"-"+tag3+"-201505"+day+"_"+time

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
; Load in first wrf file
  f1 = addfile(dir_wrf1+fname1,"r")
  hgt_1   = f1->Z_sfc
  lat2d_1 = f1->lat
  lon2d_1 = f1->lon
  ws_1    = f1->ws_10m(0,:,:)
  u_1     = f1->u_10m_tr(0,:,:)
  v_1     = f1->v_10m_tr(0,:,:)
  ; mask above 500m
  ws_1 = where(hgt_1.le.500.0, ws_1, ws_1@_FillValue)
  u_1 = where(hgt_1.le.500.0, u_1, u_1@_FillValue)
  v_1 = where(hgt_1.le.500.0, v_1, v_1@_FillValue)
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
  lat2d_2 = f2->lat
  lon2d_2 = f2->lon
  ws_2    = f2->ws_10m(0,:,:)
  u_2     = f2->u_10m_tr(0,:,:)
  v_2     = f2->v_10m_tr(0,:,:)
  ; mask above 500m
  ws_2 = where(hgt_2.le.500.0, ws_2, ws_2@_FillValue)
  u_2 = where(hgt_2.le.500.0, u_2, u_2@_FillValue)
  v_2 = where(hgt_2.le.500.0, v_2, v_2@_FillValue)
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
  lat2d_3 = f3->lat
  lon2d_3 = f3->lon
  ws_3    = f3->ws_10m(0,:,:)
  u_3     = f3->u_10m_tr(0,:,:)
  v_3     = f3->v_10m_tr(0,:,:)
  ; mask above 500m
  ws_3 = where(hgt_3.le.500.0, ws_3, ws_3@_FillValue)
  u_3 = where(hgt_3.le.500.0, u_3, u_3@_FillValue)
  v_3 = where(hgt_3.le.500.0, v_3, v_3@_FillValue)
  ; assign 2d lat and lon attributes for plotting:
  u_3@lat2d = lat2d_3
  u_3@lon2d = lon2d_3
  v_3@lat2d = lat2d_3
  v_3@lon2d = lon2d_3  
  ws_3@lat2d = lat2d_3
  ws_3@lon2d = lon2d_3

; prints together the variable title (set above for each type of data) with title1 (defined in cshell as the wrf or met info) and the max and min values
  print(vartitle1+" ASCAT min: "+min(ws_0)+"  max: "+max(ws_0)) 
  print(tag1+" min: "+min(ws_1)+"  max: "+max(ws_1)) 
  print(tag2+" min: "+min(ws_2)+"  max: "+max(ws_2))
  print(tag3+" min: "+min(ws_3)+"  max: "+max(ws_3)) 

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

  res@tiMainFontHeightF          = 0.018
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
  vcres@vcRefAnnoOn                = False ;True
  vcres@gsnLeftString              = ""
  vcres@gsnRightString             = ""

; set resources for sea ice overlay
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

; Plot 1 - ASCAT
  opts                             = res
  opts@tiMainString                = "ASCAT"
  cplot = gsn_csm_contour_map(wks, ws_0, opts)
  vplot = gsn_csm_vector(wks,u_0,v_0,vcres)
  overlay(cplot,vplot) 
  plot(0) = cplot
  delete(opts)

; Plot 1 - 5km
  opts                             = res
  opts@tiMainString                = tag1
  cplot = gsn_csm_contour_map(wks, ws_1, opts)
  vplot = gsn_csm_vector(wks,u_1,v_1,vcres)
  iplot = gsn_csm_contour(wks,sat_mask,res_sat)
  overlay(cplot,iplot)
  overlay(cplot,vplot) 
  plot(1) = cplot
  delete(opts)

; Plot 2 - 10km
  opts                             = res
  opts@tiMainString                = tag2
  cplot = gsn_csm_contour_map(wks, ws_2, opts)
  vplot = gsn_csm_vector(wks,u_2,v_2,vcres)
  iplot = gsn_csm_contour(wks,sat_mask,res_sat)
  overlay(cplot,iplot)
  overlay(cplot,vplot) 
  plot(2) = cplot
  delete(opts)

; Plot 3 - 25km
  opts                             = res
  opts@tiMainString                = tag3
  cplot = gsn_csm_contour_map(wks, ws_3, opts)
  vplot = gsn_csm_vector(wks,u_3,v_3,vcres)
  iplot = gsn_csm_contour(wks,sat_mask,res_sat)
  overlay(cplot,iplot)
  overlay(cplot,vplot) 
  plot(3) = cplot
  delete(opts)

; Plot final panel plot 
  pnlres@txString                   = title_fin
  gsn_panel(wks,(/plot/),(/1,4/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
