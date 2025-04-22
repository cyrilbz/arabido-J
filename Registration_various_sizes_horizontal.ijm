// A macro that 
// semi-automatically aligns images of plant trays so all plant pots are aligned. 
// Registration macro from Guenter Pudmich on image.sc forum :
// https://forum.image.sc/t/registration-images-of-multiple-plant-pots/110341
// Main author: Cyril Bozonnet (INRAE, cyril.bozonnet@inrae.fr)

run("Close All"); // close everything
roiManager("reset");

// Specify input directory
inputDir = getDirectory("Select input folder");
// Define the desired dimensions (width and height)
desiredWidth = 4624;// Set your desired width
desiredHeight = 2604;// Set your desired Height

// Create a template image with the "real" coordinates of a rectangle
// (size of pots without outermost pots), adjust coordinates as you desire
// Sequence = 1 top left - 2 top right - 3 bottom right - 4 bottom left

newImage("Template", "8-bit black", desiredWidth, desiredHeight, 1);
xpoints = newArray(810, 3800, 3800, 810); // FIXED template x-points location
ypoints = newArray(510, 510, 2000, 2000); // FIXED template y-points location
makeSelection("point", xpoints, ypoints);

xpoints_2plot = newArray(810, 1800, 1800, 810); // starting x locations for landmarks
ypoints_2plot = newArray(510,510,1200,1200); // starting y locations for landmarks

// Get list of files in the directory
fileList = getFileList(inputDir);
nfiles = 1 ; //fileList.length ; 
// Adjust selections manually for each image
for(s = 0; s < nfiles; s++) {
  open(inputDir + fileList[s]);
  //setSlice(s);
  makeSelection("point extra large", xpoints_2plot, ypoints_2plot);
  waitForUser("Move the points in image " + s +1 + " out of "+nfiles+" to their real positions and click OK when finished\n \nUse + and - to zoom in and out\n \nIf accidently a point is deleted set a new point sequence\n(1=TopLeft 2=TopRight 3=BottomRight 4=BottomLeft)");
  Roi.setPosition(s);
  roiManager("Add");
  roiManager("select", roiManager("count") - 1);
  roiManager("rename", d2s(s, 0))
}
// ask output folder before processing
outpath = getDirectory("Select output folder")

// Transform the images slice by slice and create a new stack
for(s = 0; s < nfiles; s++) {
  selectWindow(fileList[s]);
  //setSlice(s);
  run("Duplicate...", "title=tmp");
  RoiManager.selectByName(d2s(s, 0));
  run("Landmark Correspondences", "source_image=tmp template_image=Template transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Perspective interpolate");
  if(s == 0) {
    rename("RegisteredStack");
  	close("tmp");
  	close("Transformedtmp");
  	setMetadata("Label", "r_"+fileList[s]); // add a name to the slice
  }
  if(s > 0) {
  	run("Copy");
  	selectWindow("RegisteredStack");
  	run("Add Slice");
  	run("Paste");
  	close("tmp");
  	close("Transformedtmp");
  	setMetadata("Label", "r_"+fileList[s]); // add a name to the slice
  }
}

// Save the image sequence as TIFF files
run("Image Sequence... ", "dir="+outpath+" format=TIFF name=[] use");
selectWindow("RegisteredStack");
close("\\Others");