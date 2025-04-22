/////////////////////////////////////////////////////////////////////
// Macro for arabidopsis segmentation and pot by pot measurements
// Must be done on registered images
// An Ilastik model must have been trained before
// Configure the Ilastik executable path, and model path
// And run!
// Author : cyril.bozonnet@inrae.fr
/////////////////////////////////////////////////////////////////////
run("Close All"); // close everything

roiManager("reset");

// configure Ilastik path
run("Configure ilastik executable location", 
"executablefile=/home/cbozonnet/Documents/image_processing/ilastik-1.4.1rc2-Linux/run_ilastik.sh numthreads=-1 maxrammb=4096");

// choose Ilastik model
ilastik_model = "/home/cbozonnet/Documents/image_processing/arabidopsis_boris/arabido-J/ilastik_models/lesvos.ilp" ;

// set-up cleaning options (if false, most images are kept open to check segmentation validity)
clean_stuff = false;

// Import all REGISTERED images 
inputDir = getDirectory("Select input folder of REGISTERED images");
File.openSequence(inputDir, " filter=");
rename("RegiStack");
numberOfSlices = nSlices;

// setup informations for the travelling square
nline = 5 ; // number of lines
nrow= 8 ; // number of columns
roiSize_x = 500 ; // size of the pot
roiSize_y = 500 ; // size of the pot
xoffset = 300 ; // x offset (found manually)
yoffset = 12 ; // y offset (found manually)

var min, max; // global variables to help threshold a labelled image

// slice selection
for(s = 1; s <= numberOfSlices; s++) {
	//s = 1 ; // choice of slice
	selectWindow("RegiStack");
	if (clean_stuff) {close("\\Others")}; // close all images except the current one

	setSlice(s); // select only slice
	sliceName = getMetadata("Label") ; //get slice name (original file name)
	  
	// create the temporary image (out of the stack)
	run("Duplicate...", "title=tmp");
	
	// filter the image
	run("Non-local Means Denoising", "sigma=15 smoothing_factor=1 auto slice");
	
	// run pixel classification using Ilastik's trained model
	run("Run Pixel Classification Prediction", "projectfilename=" + ilastik_model +" inputimage=tmp pixelclassificationtype=Segmentation");
	rename("ilastik seg");
	close("tmp");
	
	// threshold the "plant" class (1st class)
	selectWindow("ilastik seg");
	setOption("BlackBackground", true);
	setAutoThreshold("Default dark no-reset");
	//run("Threshold...");
	setThreshold(0, 1);
	run("Convert to Mask");
	
	// clean the binary mask
	// first with an opening to remove white spots followed by a closing to fill dark spots
	run("Morphological Filters", "operation=Opening element=Square radius=2");
	run("Morphological Filters", "operation=Closing element=Square radius=4");
	close("ilastik seg");
	
	// then label the connected components and filter the small objects
	run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
	run("Label Size Filtering", "operation=Greater_Than size=1000");
	
	// Get display range and turn the image back to binary
	getMinAndMax(min, max);
	setOption("BlackBackground", true);
	setAutoThreshold("Default dark no-reset");
	setThreshold(1, max);
	run("Convert to Mask");
	
	// rename the image so it matches the original name
	rename(sliceName);
	
	// set up measurements
	run("Set Measurements...", "area area_fraction display redirect=None decimal=3");
	
	ROInumber = 0 ; // initialize ROI number value
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
			Table.set("Pot number",ROInumber-1+nline*nrow*(s-1),ROInumber,"Summary");
			
			// wait briefly to visualize the ROI
			//wait(200); // in miliseconds
		}
	}
}
// clean everything
if (clean_stuff) {run("Close All")}; // close everything
roiManager("reset");

// Select the "Summary" table
selectWindow("Summary");

// Open the save dialog box
saveAs("results");

// end-up by cleaning the results table
if (clean_stuff)  {run("Clear Results")} ;