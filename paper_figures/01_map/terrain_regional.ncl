;***************************************
; PROGRAM DESCRIPTION: This NCL script regrids curvilinear WRf output
;                      from any domain to a 10km WRF domain using 
;                      a Cressman Weighting scheme
; INPUT DATA: WRF geo_em.d01.nc files for 10km grid spacing and 100km spacing
; OUTPUT DATA: plot of the terrain at 10km and labels for locations,
;              difference plot of wrf100 and wrf10 terrain height along southeast coast.
; CREATOR: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; MANUAL INPUTS

; inputs for file
dir = "/data/duvivier/polar_winds/DATA/geo_em/"
fname0 = "geo_em.d01.05km"    
varcode = "hgt"

; set outdir and fout names
outdir = "./"
fout   = outdir+"terrain_region"

;;;;;;;;;;
; add data
;;;;;;;;;;
; load files
f0 = addfile(dir+fname0+".nc","r")
hgt_0 = f0->HGT_M(0,:,:)
lat2d_0 = f0->XLAT_M(0,:,:)
lon2d_0 = f0->XLONG_M(0,:,:)
hgt_0@lat2d = lat2d_0
hgt_0@lon2d = lon2d_0
dims = dimsizes(lat2d_0)     ; get lat/lon dimensions from second domain
n_sn_0 = dims(0)              ; get south/north points
n_we_0 = dims(1)              ; get west/east points
delete(dims)

;;;;;;;;;;;;;
; Load flight path lat/lon
;;;;;;;;;;;;;
data = asciiread("/data/duvivier/polar_winds/DATA/aircraft_track.txt", (/474,2/), "float")
lats_flt = data(:,0)
lons_flt = data(:,1)

;;;;;;;;;;;;;
; Add stuff for labels
;;;;;;;;;;;;;
  ; Irminger Sea
  lat0 = 63.0
  lon0 = -33.
  ; Labrador Sea
  lat1 = 63.
  lon1 = -59.
  ; Iceland
  lat2 = 65.
  lon2 = -17.5
  ; Greenland
  lat3 = 71.0
  lon3 = -40.0
  ; Denmark Strait
  lat4 = 67.0
  lon4 = -26.25 
  ; Cape Farewell
  lat5 = 59.0
  lon5 = -40.
  ; Greenland Sea
  lat6 = 75.
  lon6 = 0.
  ; Norwegian Sea
  lat7 = 67.
  lon7 = -3.

;;;;;;;;;;
; Plotting
;;;;;;;;;;
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85","yellow", "purple", "red"/)
  gsn_merge_colormaps(wks,"terrain.alice",additional_colors)
  plot = new(1, graphic)
  
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
  res@mpLimitMode                 = "Corners"	      ; how to zoom in on map 
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner

  res@cnLinesOn                   = False             ; no contour lines
  res@cnLineLabelsOn              = False             ; don't want labels
  res@cnFillMode                  = "RasterFill"
  res@cnFillOn                    = True              ; turn on filled contours

  res@gsnSpreadColors            = True              ; use full colormap
  res@gsnSpreadColorStart        = 1                 ; start at color specified for each variable above
  res@gsnSpreadColorEnd          = 100               ; end at color specified above
  res@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res@cnMinLevelValF             = 0.                ; set min contour level specified above
  res@cnMaxLevelValF             = 3500.             ; set max contour level specified above
  res@cnLevelSpacingF            = 50.               ; set contour spacing specified above
  res@cnMissingValFillColor      = "gray85"          ; missing value color
  res@cnMissingValFillPattern    = 0                 ; fill in

  res@tiMainFontHeightF          = 0.014
  res@tiMainFontThicknessF       = 1.5
  res@lbLabelBarOn               = False             ; turn off individual label bars

; set line res to show flight path
  lnres                            = True
  lnres@gsLineThicknessF          = 2.5
  lnres@gsLineColor               = "grey"

; set text res for labels
   txres                           = True
   txres@txFontHeightF             = 0.011 ;0.013 
   txres@txFontThicknessF          = 2.0

;;;;;;;;;;;;;
; Plot 0 - 50km
;;;;;;;;;;;;;
  opts0                             = res              ; reset options
  opts0@tiMainString                = "WRF 5km resolution"
  opts0@mpLeftCornerLatF            = lat2d_0(0,0)     ; set the lat/lon sides
  opts0@mpLeftCornerLonF            = lon2d_0(0,0)
  opts0@mpRightCornerLatF           = lat2d_0(n_sn_0-1,n_we_0-1) 
  opts0@mpRightCornerLonF           = lon2d_0(n_sn_0-1,n_we_0-1)

  cplot0 = gsn_csm_contour_map(wks, hgt_0, opts0) 

  dum0 = new(1,graphic)
  dum0 = gsn_add_polyline(wks,cplot0,lons_flt,lats_flt,lnres)

  dum1 = new(1,graphic)
  dum1 = gsn_add_text(wks, cplot0, "Labrador ~C~ Sea", lon1, lat1, txres)

  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks, cplot0, "Iceland", lon2, lat2, txres)

  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks, cplot0, "Greenland", lon3, lat3, txres)

  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks, cplot0, "Denmark ~C~  Strait", lon4, lat4, txres)

  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks, cplot0, "Cape ~C~  Farewell", lon5, lat5, txres)

  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks, cplot0, "Greenland~C~Sea", lon6, lat6, txres)

  dum7 = new(1,graphic)
  dum7 = gsn_add_text(wks, cplot0, "Norwegian~C~Sea", lon7, lat7, txres)

  dum8 = new(1,graphic)
  dum8 = gsn_add_text(wks, cplot0, "Keflavik", lons_flt(0), lats_flt(0)-0.15, txres)

  dum9 = new(1,graphic)
  dum9 = gsn_add_text(wks, cplot0, "Irminger ~C~ Sea", lon0, lat0, txres)

  plot(0) = cplot0

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  pnlres                            = True
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbTitleString              = "m"
  pnlres@lbTitlePosition            = "Right"
  pnlres@lbLabelStride              = 10.
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,1/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
