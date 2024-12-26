output= getDirectory("Select folder to save TIF files...");

//Getting Fiji and ROI Manager ready
	
	run("Set Measurements...", "area display redirect=None decimal=3");
	roiManager("Reset");
	roiManager("Associate", "false");
	roiManager("Centered", "false");
	roiManager("UseNames", "true");
	run("Line Width...", "line=2");
	run("Colors...", "foreground=white background=black selection=yellow");
	
	myposition=nResults;


//Define the color channels used for analysis to skip the dialog windows. Integers only.

dapi_channel = NaN; 
green_channel = NaN;
red_channel = NaN;
far_red_channel= NaN;


if (isNaN(dapi_channel) || isNaN(green_channel) || isNaN(red_channel) || isNaN(far_red_channel)) { 

	Dialog.createNonBlocking("Quick Question?");
	Dialog.addMessage("Which channel numbers belong to DAPI & GREEN & RED & FAR RED?");
	Dialog.addNumber("DAPI Channel", 0);
	Dialog.addNumber("GREEN Channel", 0);
	Dialog.addNumber("RED Channel", 0);
	Dialog.addNumber("FAR RED Channel", 0);
	Dialog.show();
	dapi_channel = Dialog.getNumber() ; //Returns the contents of the next numeric field. 
	green_channel = Dialog.getNumber() ; //Returns the contents of the next numeric field. 
	red_channel = Dialog.getNumber() ; //Returns the contents of the next numeric field.
	far_red_channel = Dialog.getNumber() ; //Returns the contents of the next numeric field.
}
	myORIImage=getImageID();
	myimagename=getTitle();
	rename("FOTO");

	// Image calibration

	setVoxelSize(0.6810681, 0.6810681, 0.6810681, "microns");

	
	selectImage(myORIImage);
	run("Duplicate...", "duplicate");
	myCOPYImage=getImageID();
	Stack.getDimensions(width, height, channels, slices, frames);

	//Create RGB smoothed image for ROI selection

	run("Stack to RGB");
	myRGBImage=getImageID();
	run("Gaussian Blur...", "sigma=2");
	setMinAndMax(0, 100);


	/*
	//Adjust contrast in copy
	EnhanceChannelsContrast(myCOPYImage,1,300,1500);
	EnhanceChannelsContrast(myCOPYImage,2,400,1500);
	EnhanceChannelsContrast(myCOPYImage,3,100,1500);
	EnhanceChannelsContrast(myCOPYImage,4,250,1000);
*/

	

	//Create Raw ROIs

	//roicount = roiManager("count");
	//for(j=0; j<roicount; j++)
	
    
    // Intima
    
	selectImage(myRGBImage);
	setTool("freehand");
	waitForUser("Define Intima ROI","1. Draw Intima ROI to area of interest\n2. Use *t* key to save ROI\n3. Repeat for as many areas as necessary\n  \nWhen done, use OK to continue");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Intima");

	

//Save all ROIs detected and classified

roiManager("deselect");
roiManager("save", output+myimagename+"_ROIs.zip");


//Adjust contrast in original

	selectImage(myORIImage);
	EnhanceChannelsContrast(myORIImage,1,200,5000);
	EnhanceChannelsContrast(myORIImage,2,600,5000);
	EnhanceChannelsContrast(myORIImage,3,100,1900);
	EnhanceChannelsContrast(myORIImage,4,200,1500);

	selectImage(myORIImage);
	run("Duplicate...", "duplicate");
	rename("FOTO");
	run("Split Channels");
	setOption("ScaleConversions", true);
	run("AFid", "image=[C2-FOTO] image_0=[C3-FOTO] input=[No Input Mask] method=Niblack method_0=Niblack threshold=30 threshold_0=30 min=20 max=10000 sigma=2 correlation=0.60 number=1 max_0=0 dilation dilation_0=20");
	setOption("ScaleConversions", true);
	selectWindow("Intersection Mask");
	selectWindow("identifiedAF.tif");
	setOption("ScaleConversions", true);
	run("Merge Channels...", "c1=[C3-FOTO] c2=[C2-_AF_Glow_Removed.tif] c3=[C1-FOTO] c4=[C4-FOTO] create");
	run("Arrange Channels...", "new=3214");
	myAFIDmage=getImageID();
	run("Select None");
	saveAs(".tif", output+myimagename+"_Enhanced");

	//Create new image for masks

	newImage("MASKS", "RGB black", width, height, 1);
	mask=getImageID();

	//Save as individual images

	myroisarray=newArray(1);
	myroiscolors=newArray("red");
	countmyroisarray=lengthOf(myroisarray);

	for(j = 0; j < countmyroisarray; j++){
		selectImage(myAFIDmage);
		run("Select None");
		run("Duplicate...", "title=ROI duplicate");
		roi=getImageID();
		selectImage(roi);
		roiManager("select", myroisarray[j]);
		setBackgroundColor(0, 0, 0);
	    run("Clear Outside");
	    run("Select None");
	    roiManager("select", myroisarray[j]);
		myroiname=Roi.getName;
		saveAs("tif", output+myimagename+"_"+myroiname);
		selectImage(roi);
		close();
		selectImage(mask);
		roiManager("select", myroisarray[j]);
		run("Colors...", "foreground="+myroiscolors[j]+" background=black selection=red");
		roiManager("Fill");
		roiManager("deselect");				
	}


	selectImage(mask);
	saveAs(".tif", output+myimagename+"_Masks");

	run("Close All");
	
	




//*******************************************************************************
///Macro functions

//Function to enhance contrast in all channels


function EnhanceChannelsContrast(imagename,channelfunc,mincontrast,maxcontrast){
	//selectWindow(imagename);
	selectImage(imagename);
	Stack.getDimensions(widthf, heightf, channelsf, slicesf, framesf);
	Stack.setDisplayMode("color");
	Stack.setChannel(channelfunc);
	setMinAndMax(mincontrast, maxcontrast);
	run("Apply LUT", "slice");
	Stack.setChannel(1);
	Stack.setDisplayMode("composite");
}