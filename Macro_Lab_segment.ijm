// open an image sequence and transform each image into a Lab stack, keep only the "a" channel
run("Close All"); // close everything

roiManager("reset");

// Import all REGISTERED images 
File.openSequence("C:/Documents/traitement_image/Arabido_Boris/registered_stack/", " filter=registered");
rename("RegiStack");
numberOfSlices = nSlices;
w = getWidth();
h = getHeight();

for(s = 1; s <= numberOfSlices; s++) { // loop over all images from the sequence
  selectWindow("RegiStack");
  setSlice(s);
  
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
}

