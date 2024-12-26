
dir = getDirectory("Choose directory to save results...");

run("Duplicate...", "duplicate");
rename("FOTO");
run("32-bit");

selectImage("FOTO");
Stack.setChannel(1);
run("Blue");
Stack.setChannel(2);
run("Green");
Stack.setChannel(3);
run("Cyan");
Stack.setChannel(4);
run("Red");
Stack.setChannel(5);
run("Grays");

	//Adjust image and remove autofluorescence
	// multiply values for 3/2 and 4/3 for the TUNEL/ACTA2/CD68 BATCH
	
selectImage("FOTO");
Stack.setDisplayMode("composite");
run("Subtract Background...", "rolling=50");
run("Multiply...", "value=4");
run("Split Channels");


// Signal adjustment

//DAPI

selectWindow("C1-FOTO");
run("Enhance Contrast...", "saturated=0.3 normalize");
run("Unsharp Mask...", "radius=1 mask=0.60");

// ACTA2-568 Enhance //LUM-568x2 // OPG-568x2

selectWindow("C4-FOTO");
//run("Enhance Contrast...", "saturated=0.3 normalize");
run("Multiply...", "value=3");
run("Unsharp Mask...", "radius=1 mask=0.60");

// CD68-647x2 // LUM-647x2 // OPG-647x2 //VCAM-1-647x3
//Batch 2 lum LUM-647, LUM-568x3, OPG-647 AND CD68-647 to equelize threshold values

selectWindow("C5-FOTO");
run("Multiply...", "value=3");
run("Unsharp Mask...", "radius=1 mask=0.60");

myopenedimages=nImages;

for(image=1;image<=myopenedimages;image++){
	selectImage(image);
	run("8-bit");
}

run("Merge Channels...", "c1=[C4-FOTO] c2=[C2-FOTO] c3=[C1-FOTO] c4=[C5-FOTO] create keep");
imageCalculator("Subtract create stack", "Composite","C3-FOTO");
selectWindow("Result of Composite");
run("Arrange Channels...", "new=3214");
rename("FOTO_NON_AF")




	//Save Image

selectImage("FOTO_NON_AF");
saveAs("Tiff");
//*******************************************************************************
