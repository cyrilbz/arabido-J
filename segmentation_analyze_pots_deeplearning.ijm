/////////////////////////////////////////////////////////////////////
// Macro for arabidopsis segmentation and pot by pot measurements
// version 2: using DeepLearning for segmentation!
// Must be done on registered images
// The DeepImageJ model must have been installed manually first
// And run!
// Author : cyril.bozonnet@inrae.fr
/////////////////////////////////////////////////////////////////////
requires("1.54p");
run("Close All"); // close everything
roiManager("reset");

// Close Summary table if it exists
if (isOpen("Summary")) {
    selectWindow("Summary");
    run("Close");
}

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

// Create a duplicate stack for overlays
selectWindow("RegiStack");
run("Duplicate...", "duplicate");
rename("RegiStack_with_contours");

// slice selection
for(s = 1; s <= numberOfSlices; s++) {
	//s = 1 ; // choice of slice
	selectWindow("RegiStack");
		
	setSlice(s); // select only slice
	sliceName = getMetadata("Label") ; //get slice name (original file name)
	
	// create the temporary image (out of the stack)
	run("Duplicate...", "title=tmp");
	
	// Create an image to accumulate all contours for the current slice
	newImage("Contours_Overlay", "8-bit black", getWidth(), getHeight(), 1);
	  
	// select image to process
	selectImage("tmp");
		
	// set up measurements
	run("Set Measurements...", "area area_fraction display redirect=None decimal=3");
	
	ROInumber = 0 ; // initialize ROI number value
	// create the loop
	//// nline=1;nrow=4; // for debugging
	for (line=0 ; line<nline ; line++) {
		for (row=0 ; row <nrow;row++) {
			// calculate ROI position
			x = xoffset + row*roiSize_x ;
			y = yoffset + line*roiSize_y ;
			
			// create square ROI
			makeRectangle(x, y, roiSize_x, roiSize_y);
			ROInumber = line*nrow + row + 1 ; // ROI number
			
			// Duplicate current ROI region
			run("Duplicate...", "title=ROI_" + ROInumber);
			
			// run segmentation using DeepImageJ
			run("DeepImageJ Run", "model_path=arabidoJ-4loc_19112025_151028");
			wait(100); // wait a little so the active window is the ouput from DeepIJ!
			rename("segmentation");
			
			// threshold the result to get a binary image
			setAutoThreshold("Default dark no-reset");
			setOption("BlackBackground", true);
			run("Convert to Mask");
			run("Make Binary");
			
			// add some morphological operation to remove noise
			run("Morphological Filters", "operation=Opening element=Square radius=1"); // remove bright spots
			rename("opening");
			run("Morphological Filters", "operation=Closing element=Square radius=1");
			rename(sliceName);
			close("opening");
			close("segmentation");
	
			// perform measurements
 			run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display summarize");
			Table.set("Pot number",ROInumber-1+nline*nrow*(s-1),ROInumber,"Summary");
				
	        // Optional: Transfer ROIs back to original image with offset
	        run("Find Edges");
	        rename("edges");
	        run("Select All");
	        run("Copy");
	        selectWindow("Contours_Overlay");
	        makeRectangle(x, y, roiSize_x, roiSize_y);
	        run("Paste");

			// clean & prepare for next iteration
			close("edges");
			close("ROI_" + ROInumber);
			selectImage("tmp");			
		} //end rows
	} //end lines
	// Convert contours buffer to red
	selectWindow("Contours_Overlay");
	run("Red");

	// Use Max to overlay only non-zero pixels on buffer slice
	imageCalculator("Max", "tmp", "Contours_Overlay");
	
	// Replace the slice in the output stack with the overlaid version
	selectWindow("tmp");
	run("Select All");
	run("Copy");
	selectWindow("RegiStack_with_contours");
	setSlice(s);
	run("Paste");

	// Clean up
	close("Contours_Overlay");	
	close("tmp");
} // end slices

// Select the "Summary" table
selectWindow("Summary");
wait(100);
// Open the save dialog box
saveAs("results");

//close results table
selectWindow("Results");
run("Close");