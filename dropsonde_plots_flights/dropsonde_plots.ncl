;***************************************
; PROGRAM DESCRIPTION: This script plots frequency information for
;                      a SOM trained with three data sets
; INPUT DATA: SOM date and visual files for three data types
; OUTPUT DATA: One  plot of frequency comparisons
; CREATOR: Matt Higgins(Oct 2008), Melissa Nigro (Aug 2011)
;          Modified by Alice DuVivier - April 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
  numb   = "2"
  name1  = "205909"
  name2  = "211845"
  name3  = "211845"
  name4  = "211845"

title_fin = "Polar Winds Dropsonde Comparison: "+"cross jet, north"

; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting polar winds dropsondes")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Get number of Dropsondes to plot (up to 4)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
en_num = stringtoint(numb)
names = new((/en_num/),"string")
do w = 0, en_num - 1
   if (w .eq. 0)
      dum1 = name1
   end if
   if (w .eq. 1)
      dum1 = name2
   end if
   if (w .eq. 2)
      dum1 = name3
   end if
   if (w .eq. 3)
      dum1 = name4
   end if
   names(w) = dum1
   delete([/dum1/])
end do

; select input directory
indir    = "/data/duvivier/polar_winds/DATA/Polar_Winds_Campaign2_Dropsondes_121015/"

; select preferences for figure title based on # of values
outdir = "./"
if (en_num .eq. 1) then
  fout   = outdir+"dropsondes_"+name1
end if
if (en_num .eq. 2) then
  fout   = outdir+"dropsondes_"+name1+"_"+name2
end if
if (en_num .eq. 3) then
  fout   = outdir+"dropsondes_"+name1+"_"+name2+"_"+name3
end if
if (en_num .eq. 4) then
  fout   = outdir+"dropsondes_"+name1+"_"+name2+"_"+name3+"_"+name4
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Preallocate arrays for data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Make new arrays to write to that have average
  head  = new((/en_num/),"string")
  pres  = new((/en_num,2000/),"float")
  temp  = new((/en_num,2000/),"float")
  ws    = new((/en_num,2000/),"float")
  wd    = new((/en_num,2000/),"float")
  hgt   = new((/en_num,2000/),"float")

w = 0
do w = 0, en_num -1
   ; get file name
   inname = indir+"/Drop_20150521-"+names(w)+"_L2_final.dat"
   ; load header
   head(w) = readAsciiHead(inname,1)
   ; load data
   dum = readAsciiTable(inname,19,"float",1)

   ; replace nans
   if (any(isnan_ieee(dum)))then
      fill = -9999999.99
      replace_ieeenan (dum,fill,0)
      dum@_FillValue = fill
   end if

   ; get the number of heights
   dims = dimsizes(dum)
   nh = dims(0)
   
   ; locations of all data determined by useing dropsonde_readme.txt
   pres(w,0:nh-1) = dum(:,1)   ; in mb
   temp(w,0:nh-1) = dum(:,2)   ; in degC
   ws(w,0:nh-1)   = dum(:,13)  ; in m/s
   wd(w,0:nh-1)   = dum(:,14)  ; in deg
   hgt(w,0:nh-1)  = dum(:,16)  ; in m above msl
   delete([/inname,dum,dims,nh/])
end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Plotting dropsonde data")
  wks = gsn_open_wks("ps", outdir+fout)
  plot = new(3,graphic)

;;;;;;;;;;;;;
; Set Resources
;;;;;;;;;;;;;
; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance frame
  res@gsnMaximize                 = True              ; maximize plot
  res@vpHeightF                   = 1.5               ; change aspect ratio of plot (viewport)
  res@vpWidthF                    = 1.0          

; set title resources
  res@tiMainOn                    = True              ; turn on main title for each plot
  res@tiMainFontHeightF           = 0.03              ; set size of font for main plot
  res@tiMainFontThicknessF        = 1.5

; set x axis tick marks
  res@tmXTOn                      = False             ; delete top and right ticks
  res@tmYROn                      = False
  res@trYMaxF                     = 2000.0 ;max(hgt)          ; maximum height to plot to
  res@trYMinF                     = 0.
  res@tiYAxisString               = "Height (m above MSL)"
  res@tiXAxisFontHeightF          = 0.03            ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.03             ; set tick mark label size for x axis
  res@tiYAxisFontHeightF          = 0.03             ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.03             ; set tick mark label size for y axis

; arrays for different colors, etc.(requires a single array of data)
  res@xyMarkLineModes             = (/"MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines"/)
  res@xyMarkers                   = (/16,16,16,16,16,16,16/)
  res@xyMarkerSizes               = (/0.005,0.005,0.005,0.005,0.005,0.005,0.005,0.005/)
  res@xyLineColors                = (/"black","blue","firebrick","cyan1","pink2","darkorange4","gold"/)
  res@xyMarkerColors              = (/"black","blue","firebrick","cyan1","pink2","darkorange4","gold"/)
  res@xyMonoLineColor             =  False                 ; allow other line colors
  res@xyDashPatterns              = (/0,0,0,0,0,0,0/)
  res@xyLineThicknesses           = (/1.5,1.5,1.5,1.5,1.5,1.5,1.5/)
  res@gsnYRefLine                 = 0.0           ; create a reference line
  res@gsnYRefLineColor            = "grey15"
  res@gsnYRefLineDashPattern      = 16

; panel resources
  pnlres                            = True
  pnlres@gsnMaximize                = True
  pnlres@gsnFrame                   = False  
  pnlres@txFontHeightF              = 0.013
  pnlres@txString                   = title_fin 
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnPanelBottom             = 0.13             ; leave room for legend at bottom
  pnlres@gsnMaximize                = True	       ; fill the page

; legend resources for all the plots
  lgres                     = True
  ;lgres@pmLegendWidthF     = 0.03
  ;lgres@pmLegendHeightF    = 0.01
  lgres@vpWidthF            = 0.75               ; width of legend (NDC)
  lgres@vpHeightF           = 0.05               ; height of legend (NDC)
  lgres@lgLabelFontHeightF  = 0.0075 ;0.01
  lgres@lgAutoManage        = False              ; false allows me to set the legend directly
  lgres@lgOrientation       = "horizontal" 
  lgres@lgMonoLineColor     = False
  lgres@lgMonoItemType      = False
  lgres@lgItemTypes         = res@xyMarkLineModes
  lgres@lgDashIndexes       = res@xyDashPatterns
  lgres@lgMarkerIndexes     = res@xyMarkers
  lgres@lgMonoMarkerSize    = False
  lgres@lgMarkerSizes       = res@xyMarkerSizes
  lgres@lgMonoLineThickness = False
  lgres@lgLineThicknesses   = res@xyLineThicknesses
  lgres@lgLineColors        = res@xyLineColors   ; make the colors for the legend
  lgres@lgMarkerColors      = res@xyMarkerColors
  xpos                      = 0.15   ; xposition 
  ypos                      = 0.3  ; yposition (below figures)

;;;;;;;;;;;;;
; Plot 0 - Temperature
;;;;;;;;;;;;
  opts                   = res
  opts@trXMaxF           = 5.0 ;max(temp)+5.0
  opts@trXMinF           = -15.0 ;min(temp)-5.0
  opts@tiMainString      = "Temperature (deg C)"
  opts@tiXAxisString     = "Temperature (deg C)"
  plot(0) = gsn_csm_xy(wks,temp,hgt,opts)  
  delete(opts)

;;;;;;;;;;;;;
; Plot 1 - Wind speed
;;;;;;;;;;;;
  opts                   = res
  opts@trXMaxF           = max(ws(:,:))+3.0
  opts@trXMinF           = 0.0
  opts@tiMainString      = "Wind Speed (m/s)"
  opts@tiXAxisString     = "Wind Speed (m/s)"
  plot(1) = gsn_csm_xy(wks,ws,hgt,opts)  
  delete(opts)

;;;;;;;;;;;;;
; Plot 1 - Wind Direction
;;;;;;;;;;;;
  opts                   = res
  opts@trXMaxF           = 360.0
  opts@trXMinF           = 0.0
  opts@tiMainString      = "Wind Direction (deg)"
  opts@tiXAxisString     = "Wind Direction (deg)"
  delete(opts@xyMarkLineModes)
  opts@xyMarkLineModes             = (/"Markers","Markers","Markers","Markers","Markers","Markers","Markers"/)
  plot(2) = gsn_csm_xy(wks,wd,hgt,opts)  
  delete(opts)
print("Individual plots complete- panneling")

;;;;;;;;;;;;;
; Panel regular plots
;;;;;;;;;;;;; 
; regular plot
  gsn_panel(wks,(/plot/),(/1,3/),pnlres)
  if (en_num .eq. 2)then 
     gsn_legend_ndc(wks,en_num,(/name1,name2/),xpos ,ypos ,lgres) 
  end if
  if (en_num .eq. 3)then 
     gsn_legend_ndc(wks,en_num,(/name1,name2,name3/),xpos ,ypos ,lgres) 
  end if
  if (en_num .eq. 4)then 
     gsn_legend_ndc(wks,en_num,(/name1,name2,name3,name4/),xpos ,ypos ,lgres) 
  end if
  frame(wks)
  delete(wks)
  print("converting to png")
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
