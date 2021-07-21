struct *list1
struct *list2
struct *list3
struct *list4
struct *list5
struct *list6
string s4,s5,s6,s7
#real x,y,z
#
#==================================== Extra Loop for accessing different Directories ================
#                  Entering in the Directory defined by thw whilw loop
#
#====================================================================================================

list6="numfile"
while(fscan(list6,s7) != EOF){
cd (s7)
print("////////////// I am in Directory////////////// ",(s7))

#____            main program      ________________________________________________________________    

#======================================================================================================#
#                  Starting of main program . This program will do the photometry for all              #
#                  the frames one by one itself and result a data file having instrumental             #
#                  magnitudes for all the stars in the frames and defined by an input file.            #
#                  Requisite files:  listfile.txt>>> sky coordinate file for all the stars of interest.#
#                                 :  cmds >>> required for editing the header of image.                #
#                                 :  filterlist >>> a file with a list of filters.                     #
#======================================================================================================#

list5="/data4/group2/sunilc/workplace/analysis/ccd/ana_pks1510/filterlist"
while(fscan(list5,s6) != EOF){
if(s6=="R") {

!fileroot *1510R*.fit >rlist2
!echo "yes it is R"

} else if(s6=="V") {

!fileroot *1510V*.fit >rlist2
!echo "yes it is V"

} else if(s6=="I") {

!fileroot *1510I*.fit >rlist2
!echo "yes it is I"

} else if(s6=="B") {

!fileroot *1510B*.fit >rlist2
!echo "yes it is B"

} else {

print("   I   finished  for  all   bands  ")

}

print((s6))
#nedit rlist2

!echo "yes it is1"



#----------Script to do Photometry using IRAF and Astrometry.net Tools-----------

list="rlist2"
       
while ( fscan(list,s1) != EOF) {   
           #-------------------------------------------
print((s1))
cp ../listfile.txt .
cp ../cmds .
 
	    hedit ((s1)//".fit",fields="DATA-TYP",value="object",add+,verify-,show+)
            #------------Add WCS to frame header--------
            
	    print("solve-field --ra 15:12:50.5329 --dec -09:05:59.8296 -5 10 --no-plot --overwrite "//(s1)+".fit", >> "slvfldsh.sh")
            print("sky2xy "//(s1)+".new @listfile.txt | cut -d'>' -f2 | cut -d' ' -f2-4 > image_cord.coo", >>"slvfldsh.sh")
	    print("ls "//(s1)//"* |grep new > test.out", >> "slvfldsh.sh")
	    !chmod +x slvfldsh.sh
	    !./slvfldsh.sh
	    
	    #!rm test.out
	    #! ls ((s1)//"*") | grep new >  "test.out"
	    list1="test.out"
	    #print("pre while loop")
 	    while(fscan(list1,s2)!=EOF) {
	    if ((s2)==(s1)//".new")	  {
	    
	    #------------Image Reduction Only Flatfield processing-------
	    ccdproc((s1)//".fit",output=(s1)//".f.fits",ccdtype="",max_cache=2,noproc=no,fixpix=no,overscan=no,trim=no,zerocor=yes,darkcor=no,flatcor=yes,illumcor=no,fringecor=no,readcor=no,scancor=no,readaxis="line",zero="Zero.fits",biassec="[1:9,*]",flat="Flat*",minreplace=1)
	    
	    #imarith ((s1)//".f.fits","/",60,(s1)//".fn.fits")
	    
	    #--------------------------------------------------------------
	    
	    
	    
	    #------------display frame and mark selected object-----------
	    display ((s1)//".f.fits",1)
	    
	    tvmark 1 image_cord.coo mark=circle radii=2 color=206
	    
	    #-------------------------------------------------------------
	    
	    #------------Add JD to Frame Header---------
	    asthedit ((s1)//".f.fits","cmds")
	    #-------------------------------------------
	    
	    #------------Do Aperture Photometry---------
	    
	   #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	   #--------------Fetching the header and making decision for right fwhm and stddev of background -------
	   imexamine((s1)//".f.fits",1,imagecur="image_cord.coo",defkey="a",ncstat=10,nlstat=10,use_display-, > "examfile1")
	   !awk '{if($10+0.0 >0.0) printf "%6.3f\n", $10}' examfile1 > moffat_fwhm
	   type moffat_fwhm | average > fwhm_ave
	   
	   list2="moffat_fwhm"
	   while(fscan(list2,x) != EOF ){
	      datapars.fwhmpsf= x     
	     }#e while list2,x
	    
	    !awk '{printf "%6.3f\n",$2-20}' image_cord.coo >t2
	    !awk '{printf "%6.3f\n",$1-20}' image_cord.coo >t1
	    !paste t1 t2 > t3
	    imexamine((s1)//".f.fits",1,imagecur="t3",defkey="m",ncstat=10,nlstat=10,use_display-, > "examfile2")
	    !awk  '{if($5+0.0 >0.0) printf "%6.3f\n", $5}' examfile2 > stddev_file
	    type stddev_file| average > stddev_ave
	    
	    list3="stddev_ave"
	    while(fscan(list3,y) != EOF ) {
	      datapars.sigma= y     
	     }#endwhile  list3,y
	   
	   
	   
	   print(datapars.fwhmpsf)
	   
	   print(datapars.sigma)
	   rm examfile1 examfile2 fwhm_ave stddev_ave
	   
	   
	   #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	   # datapars.fwhmpsf=2.7
	  #  datapars.sigma=0.102
	    datapars.gain="CCDGAIN"
	    datapars.readnoise=8
	    datapars.exposure="EXPOSURE"
	    datapars.airmass="AIRMASS"
	    datapars.filter="F1POS"
	    datapars.obstime="UT"
	    datapars.datamin=INDEF
	    datapars.datamax=INDEF
	    
	    fitskypars.annulus=10
	    fitskypars.dannulus=10
	    fitskypars.snreject=50
	    
	    photpars.apertures="4,5,6,7,8,9,10,11"
	    
	    centerpars.calgorithm="centroid"
	    centerpars.cbox=15
	    centerpars.cmaxiter=20
	    
	    
	     phot ((s1)//".f.fits",coords="image_cord.coo",output=(s1)//".mag.2")
	    #-------------------------------------------
	               
	    #------------Extracting Fields Interested from output of photometry ------------           
	    i=1
	     while(i<6) {
	     s2="id=="+i
	    
	     #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	     if(i==1){
               txdump  ((s1)//".mag.2", "IMAGE,OTIME,XAIRMASS,IFILTER,XCENTER,YCENTER,MAG,MERR", expr=(s2), > "temp"+i)
	     } else {
		 txdump  ((s1)//".mag.2", "XCENTER,YCENTER,MAG,MERR", expr=(s2), > "temp"+i)
	     }#end else
	    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	     i=i+1 
	     }#end while txdump i..6
	   #-------------------------------------------------
	   
	   #--------------Generate Final Output Files by joining different output files-----
	   
	    
	     imgets((s1)//".f.fits","JD")
	     print((imgets.value),> "tmjd")
	     print(s2)
	     joinlines tmjd temp* maxchar=3200 >> ((s6)//"_band_phot.mag")
	   
	     cp ((s6)//"_band_phot.mag","/data4/group2/sunilc/workplace/analysis/ccd/ana_pks1510/results/"//(s6)//"_"//(s7)//"_band_phot.mag")
	     
	     #--------------------------------------------------------------------------------
	           
            del tmjd
	    del temp*
	    del image_cord.coo
	    del("slvfldsh.sh")
	    del((s1)//"-indx.xyls")
	    del((s1)//".match")
	    del((s1)//".new")
	    del((s1)//".rdls")
	    del((s1)//".solved")
	    del((s1)//".wcs")
	    del((s1)//".axy")
	    del((s1)//".corr")
	    del((s1)//".f.fits")
		    
		    
		    
		    
 		   }# if file not solved
		   
		 print("Field is not solve for this particular image ",(s2))
		   
		}#end while list1,s2, check for solved or not
  		#-------------- End of loop peforming the required action on individual files ----
		
	    }#end while individ list,s1
	    
	    #-------------delete temp files-----------------
	   # del tmjd
	   # del temp*
	   # del image_cord.coo
	   # del("slvfldsh.sh")
	   # del((s1)//"-indx.xyls")
	   # del((s1)//".match")
	   # del((s1)//".new")
	   # del((s1)//".rdls")
	   # del((s1)//".solved")
	   # del((s1)//".wcs")
	   # del((s1)//".axy")
	   # del((s1)//".corr")
	   # del((s1)//".f.fits")
	   # del((s1)//".fnn.fits")
	  
	    #-----------------------------------------------
del test.out
   #end of individual files
# -------------- End of loop iterating same step for different filters ----

del rlist*
#__________________________________________________________________________________________________________
} # end of filters
cd ../

# -------------- End of loop used for switching between different directories ----

print("---------I finished the task for directory",(s7))

} #  end of dirs
