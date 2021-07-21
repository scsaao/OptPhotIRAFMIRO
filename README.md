# OptPhotIRAFMIRO
The IARF bases .cl script to analyze the optical CCD photometry images
-Aperture Photometry Only

Pr-requisites:

    Working IRAF installed
    Working Astrometry.net installed with appropriate index files
    Working DS9 tool for image visualization 

Important input files:
A) "numfile" or change the name in the main code as applicable - ASCII format

    Description: A file listing all the directories which contains images from the MIRO observations. These directories should have all the calibration files (master FLATS and BIAS frames) in it.

B) "filterlist" or or change the name in the main code as applicable - ASCII format

    Description: A file listing all the filters (Character or Strings that is part of file names e.g., R for Rband etc.)

C) "listfile.txt" or change the name in the main code as applicable - ASCII format

    Description: A file listing sky coordinates of all the stars in the field one per line, e.g.,
    15:12:50.521 -09:05:59.71
    15:12:51.651 -09:05:23.18
    15:12:53.216 -09:03:42.13
    15:12:44.297 -09:06:39.74
    15:12:52.782 -09:06:59.40
    15:13:01.438 -09:06:40.22

D) "cmds" : ASCII file containng one line for executing a command to edit header

    jd=julday(@'date-obs',ut-5.5+(exposure/2+13.5)/3600)

Main Script Name : The IARF bases .cl script to analyze the optical CCD photometry images
-Aperture Photometry Only

Pr-requisites:

    Working IRAF installed
    Working Astrometry.net installed with appropriate index files

Important input files:
A) "numfile" or change the name in the main code as applicable - ASCII format

    Description: A file listing all the directories which contains images from the MIRO observations. These directories should have all the calibration files (master FLATS and BIAS frames) in it.

B) "filterlist" or or change the name in the main code as applicable - ASCII format

    Description: A file listing all the filters (Character or Strings that is part of file names e.g., R for Rband etc.)

C) "listfile.txt" or change the name in the main code as applicable - ASCII format

    Description: A file listing sky coordinates of all the stars in the field one per line, e.g.,
    15:12:50.521 -09:05:59.71
    15:12:51.651 -09:05:23.18
    15:12:53.216 -09:03:42.13
    15:12:44.297 -09:06:39.74
    15:12:52.782 -09:06:59.40
    15:13:01.438 -09:06:40.22

D) "cmds" : ASCII file containng one line for executing a command to edit header

    jd=julday(@'date-obs',ut-5.5+(exposure/2+13.5)/3600)

Main Script Name : "sc_miroOptPhotIRAF.cl"

How to use it: 

Keep all the files in your workig directory.
Open the script and change the paths as applicable
Enter to the IRAF environment 
e.g., by 
> cl
cl >
load improc, imred, ccdproc, ccdred, noao to your working environment
noao> @sc_miroOptPhotIRAF.cl 

The script shall work fine and display interim products in between...
