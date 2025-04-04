// A macro that 
// semi-automatically aligns images of plant trays so all plant pots are aligned. 
// Registration macro from Guenter Pumich on image.sc forum :
// https://forum.image.sc/t/registration-images-of-multiple-plant-pots/110341


// Set the directory where you want to save the images
//outputDir = "C:/Documents/traitement_image/Arabido_Boris/registered_stack/";
//outputName = "regi" ;

roiManager("reset");

// Import all images of the sequence
inputDir = "C:/Documents/traitement_image/Arabido_Boris/sourceim/"
// Define the desired dimensions (width and height)
desiredWidth = 2604; // Set your desired width
desiredHeight = 4624; // Set your desired height

File.openSequence("C:/Documents/traitement_image/Arabido_Boris/sourceim/");
rename("OrigStack");
numberOfSlices = nSlices;
w = getWidth();
h = getHeight();

// Create a template image with the "real" coordinates of a rectangle
// (size of pots without outermost pots), adjust coordinates as you desire
// Sequence = 1 top left - 2 top right - 3 bottom right - 4 bottom left

newImage("Template", "8-bit black", desiredWidth, desiredHeight, 1);
xpoints = newArray(510, 2000, 2000, 510);
ypoints = newArray(810, 810, 3800, 3800);
makeSelection("point", xpoints, ypoints);

// Adjust selections manually for each image
for(s = 1; s <= numberOfSlices; s++) {
  selectWindow("OrigStack");
  setSlice(s);
  makeSelection("point extra large", xpoints, ypoints);
  waitForUser("Move the points in slice " + s + " to their real positions and click OK when finished\n \nUse + and - to zoom in and out\n \nIf accidently a point is deleted set a new point sequence\n(1=TopLeft 2=TopRight 3=BottomRight 4=BottomLeft)");
  Roi.setPosition(s);
  roiManager("Add");
  roiManager("select", roiManager("count") - 1);
  roiManager("rename", d2s(s, 0))
}

// Transform the images slice by slice and create a new stack
for(s = 1; s <= numberOfSlices; s++) {
  selectWindow("OrigStack");
  setSlice(s);
  run("Duplicate...", "title=tmp");
  RoiManager.selectByName(d2s(s, 0));
  run("Landmark Correspondences", "source_image=tmp template_image=Template transformation_method=[Least Squares] alpha=1 mesh_resolution=32 transformation_class=Perspective interpolate");
  if(s == 1) {
    rename("NewStack");
  	close("tmp");
  	close("Transformedtmp");
  }
  if(s > 1) {
  	run("Copy");
  	selectWindow("NewStack");
  	run("Add Slice");
  	run("Paste");
  	close("tmp");
  	close("Transformedtmp");
  }
}
waitForUser("Do not forget to save the new stack! ");
// Save the image sequence as JPEG files
//run("Image Sequence...", "format=JPEG name=" + outputName + " save=" + outputDir);
run("Select None");