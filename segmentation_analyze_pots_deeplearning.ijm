/////////////////////////////////////////////////////////////////////
// Macro for plant trays segmentation and pot by pot measurements
// version 2: using DeepLearning for pot by pot segmentation! (trained on arabidopsis)
// Must be done on registered images
// The DeepImageJ model must have been installed manually first
// Author : cyril.bozonnet@inrae.fr
/////////////////////////////////////////////////////////////////////
requires("1.54p");
run("Close All"); // close everything
t0 = getTime();

roiManager("reset");

plot_edges = false ; //if true: red edges are plotted as overlay, if false: the overlay is filled up

// Close Summary table if it exists
if (isOpen("Summary")) {
    selectWindow("Summary");
    run("Close");
}

// Import all REGISTERED images 
inputDir = getDirectory("Select input folder of REGISTERED images");
File.openSequence(inputDir, " filter=");
rename("RegiStack"); // for REGIstered STACK
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

// slice selection
for(s = 1; s <= numberOfSlices; s++) {
	selectWindow("RegiStack");
	setBatchMode("show");
		
	setSlice(s); // select only slice
	sliceName = getMetadata("Label") ; //get slice name (original file name)
	
	// create the temporary image (out of the stack)
	run("Duplicate...", "title=tmp");
	
	// Create an image to accumulate all contours for the current slice
	newImage("Contours_Overlay", "8-bit black", getWidth(), getHeight(), 1);
	setBatchMode("show");
	  
	// select image to process
	selectImage("tmp");
	setBatchMode("show");
		
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
			
			// Duplicate current ROI region
			run("Duplicate...", "title=ROI_" + ROInumber);
			
			// run segmentation using DeepImageJ
			run("DeepImageJ Run", "model_path=arabidoJ-corrected");
			wait(100);
			rename("output");
			
			// threshold the result to get a binary image
			run("32-bit"); //force 32-bit: safer in BatchMode
			setAutoThreshold("Default dark no-reset");
			setOption("BlackBackground", true);
			run("Convert to Mask");
					
			// add some morphological operation to remove noise
			run("Morphological Filters", "operation=Opening element=Square radius=1"); // remove bright spots
			rename("opening");
			close("output");
			run("Morphological Filters", "operation=Closing element=Square radius=1");
			rename(sliceName);
			close("opening");
			
			// perform measurements
			selectImage(sliceName);
 			run("Analyze Particles...", "size=0-Infinity circularity=0.00-1.00 show=Nothing display summarize");
			Table.set("Pot number",ROInumber-1+nline*nrow*(s-1),ROInumber,"Summary");
				
	        // Transfer ROIs back to original image with offset
	        if (plot_edges==true) run("Find Edges");
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
	// Convert overlay to red
	selectWindow("Contours_Overlay");
	run("Red");

	// Use Max to overlay only non-zero pixels on buffer slice
	imageCalculator("Max", "tmp", "Contours_Overlay");
	
	// Replace the slice in the output stack with the overlaid version
	selectWindow("tmp");
	run("Select All");
	run("Copy");
	selectWindow("RegiStack");
	setSlice(s);
	run("Paste");

	// Clean up
	close("Contours_Overlay");	
	close("tmp");
} // end slices

//show original stack with overlay
selectWindow("RegiStack");
rename("RegiStack_with_contours");

print("elapsed time is : " +(getTime()-t0)/1000+"seconds");

//close results table
selectWindow("Results");
run("Close");

// Select the "Summary" table
selectWindow("Summary");
wait(100);
// Open the save dialog box
saveAs("results");
