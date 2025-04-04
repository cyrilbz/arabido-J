// test macro for moving ROI

run("Close All"); // close everything

//roiManager("reset");

// Import all REGISTERED images 
File.openSequence("C:/Documents/traitement_image/Arabido_Boris/registered_stack/", " filter=registered");
rename("RegiStack");
numberOfSlices = nSlices;
w = getWidth();
h = getHeight();
s = 4 ; // choice of slice
selectWindow("RegiStack");
setSlice(s); // select only one image

// setup informations for the travelling square
nrow = 5 ; // number of columns
nline = 8 ; // number of columns
roiSize_x = 500 ; // size of the square
roiSize_y = 500 ; // size of the square
xoffset = 12 ; // x offset (found manually)
yoffset = 300 ; // y offset (found manually)
  
// create the Lab stacks
run("Duplicate...", "title=tmp");
run("Lab Stack");
  
// Keep only the "a" channel!
run("Split Channels");
selectWindow("C1-tmp");
close();
selectWindow("C3-tmp");
close();
selectWindow("C2-tmp");
rename("a-"+s);

// perform thresholding
setOption("ScaleConversions", true);
run("8-bit");
run("Auto Threshold", "method=Default");

// set up measurements
run("Set Measurements...", "area area_fraction display redirect=None decimal=3");

// create the loop
for (line=0 ; line<nline ; line++) {
	for (row=0 ; row <nrow;row++) {
		// calculate ROI position
		x = xoffset + row*roiSize_x ;
		y = yoffset + line*roiSize_y ;
		
		// create square ROI
		makeRectangle(x, y, roiSize_x, roiSize_y);
		ROInumber = line*nrow + row + 1 ; // ROI number
		
		// perform measurements
		run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display summarize");
		Table.set("RoI",ROInumber-1,ROInumber,"Summary");
		
		// wait briefly to visualize the ROI
		wait(500); // in miliseconds
	}
}
