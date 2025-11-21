#@ File (label="Select a file") myFile

open(myFile);

// setup informations for the travelling square
nline = 5 ; // number of lines
nrow= 8 ; // number of columns
roiSize_x = 500 ; // size of the pot
roiSize_y = 500 ; // size of the pot
xoffset = 300 ; // x offset (found manually)
yoffset = 12 ; // y offset (found manually)


ROInumber = 0 ; // initialize ROI number value
	// create the loop
	for (line=0 ; line<nline ; line++) {
		for (row=0 ; row <nrow;row++) {
			// calculate ROI position
			x = xoffset + row*roiSize_x ;
			y = yoffset + line*roiSize_y ;
			ROInumber = line*nrow + row + 1 ; // ROI number
			
			// Duplicate the original image to keep it unchanged
			run("Duplicate...", "title=Cropped_Image");
			
			if (ROInumber>2) {
				
			// create square ROI
			makeRectangle(x, y, roiSize_x, roiSize_y);

			// Crop the duplicated image to the ROI
			run("Crop");

			// save resulting cropped image
			saveAs("jpeg", File.getDirectory(myFile)+File.separator + File.getNameWithoutExtension(myFile)+"_pot"+ROInumber+".jpg");
			
			// Close the cropped image 
			close("Cropped_Image");

			}
		}
	}