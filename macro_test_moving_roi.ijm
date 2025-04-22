// test macro for moving ROI

run("Close All"); // close everything

roiManager("reset");

// Import all REGISTERED images 
File.openSequence("C:/Documents/traitement_image/Arabido_Boris/registered_stack/", " filter=registered");
rename("RegiStack");
numberOfSlices = nSlices;
w = getWidth();
h = getHeight();

selectWindow("RegiStack");
setSlice(4); // select only one image

// setup informations for the travelling square
nrow = 5 ; // number of columns
nline = 8 ; // number of columns
roiSize_x = 500 ; // size of the square
roiSize_y = 500 ; // size of the square
xoffset = 12 ; // x offset (found manually)
yoffset = 300 ; // y offset (found manually)

// create the loop
for (row=0 ; row <nrow;row++) {
	for (line=0 ; line<nline ; line++) {
		// calculate ROI position
		x = xoffset + row*roiSize_x ;
		y = yoffset + line*roiSize_y ;
		
		// create square ROI
		makeRectangle(x, y, roiSize_x, roiSize_y);

		// wait briefly to visualize the ROI
		wait(500); // in miliseconds
	}
}
