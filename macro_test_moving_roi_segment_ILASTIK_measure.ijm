// test macro for moving ROI

run("Close All"); // close everything

roiManager("reset");

// Import all REGISTERED images 
File.openSequence("/home/cbozonnet/Documents/image_processing/arabidopsis_boris/2025_02_20-Lesvos/2025_02_20-registered/", " filter=");
rename("RegiStack");
numberOfSlices = nSlices;
w = getWidth();
h = getHeight();
s = 10 ; // choice of slice
selectWindow("RegiStack");
setSlice(s); // select only one image

// setup informations for the travelling square
nrow = 5 ; // number of columns
nline = 8 ; // number of columns
roiSize_x = 500 ; // size of the square
roiSize_y = 500 ; // size of the square
xoffset = 12 ; // x offset (found manually)
yoffset = 300 ; // y offset (found manually)
  
// create the temporary image (out of the stack)
run("Duplicate...", "title=tmp");

// filter the image
run("Non-local Means Denoising", "sigma=15 smoothing_factor=1 auto slice");

// configure Ilastik path
run("Configure ilastik executable location", 
"executablefile=/home/cbozonnet/Documents/image_processing/ilastik-1.4.1rc2-Linux/run_ilastik.sh numthreads=-1 maxrammb=4096");

// run pixel classification using trained model
ilastik_model = "/home/cbozonnet/Documents/image_processing/arabidopsis_boris/arabido-J/ilastik_models/lesvos.ilp"
run("Run Pixel Classification Prediction", 
"projectfilename=" + ilastik_model +" inputimage=tmp pixelclassificationtype=Segmentation");
rename("ilastik seg")

// threshold the "plant" class (1st class)
selectWindow("ilastik seg");
setOption("BlackBackground", true);
setAutoThreshold("Default dark no-reset");
//run("Threshold...");
setThreshold(0, 1);
run("Convert to Mask");

// clean the binary mask
// first with an opening
run("Morphological Filters", "operation=Opening element=Square radius=2");

// then label the connected components and filter the small objects
run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
run("Label Size Filtering", "operation=Greater_Than size=1000");

// Get display range and turn the image to binary
var min, max; // global variables
getMinAndMax(min, max);
setOption("BlackBackground", true);
setAutoThreshold("Default dark no-reset");
//run("Threshold...");
setThreshold(01, max);
run("Convert to Mask");

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
		//wait(500); // in miliseconds
	}
}
