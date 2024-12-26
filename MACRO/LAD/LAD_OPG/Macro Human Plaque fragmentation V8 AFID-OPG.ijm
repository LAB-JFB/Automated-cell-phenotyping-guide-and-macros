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



	

	//Create Raw ROIs


	
    // Lumen
    
    selectImage(myRGBImage);
    setTool("wand");
	run("Wand Tool...", "tolerance=1 mode=Legacy");
    waitForUser("Define LUMEN ROI","1. Draw LUMEN ROI to area of interest\n2. Use *t* key to save ROI\n3. Repeat for as many areas as necessary\n  \nWhen done, use OK to continue");
    roiManager("Select", roiManager("count")-1);
    roiManager("Rename", "Lumen");
    roiManager("Select", 0);
	run("Enlarge...", "enlarge=200");
    roiManager("add");
    roiManager("Select", roiManager("count")-1);
    roiManager("Rename", "Enlarged Lumen");

    // Plaque
    
	selectImage(myRGBImage);
	setTool("freehand");
	waitForUser("Define Plaque ROI","1. Draw plaque ROI to area of interest\n2. Use *t* key to save ROI\n3. Repeat for as many areas as necessary\n  \nWhen done, use OK to continue");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Plaque");

	// NC 
	
	setTool("wand");
	run("Wand Tool...", "tolerance=1 mode=Legacy");
	waitForUser("Define NC ROI","1. Draw NC ROI to area of interest\n2. Use *t* key to save ROI\n3. Repeat for as many areas as necessary\n  \nWhen done, use OK to continue");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "NC");
	roiManager("Select", roiManager("count")-1);
	run("Enlarge...", "enlarge=100");
    roiManager("add");
    roiManager("Select", roiManager("count")-1);
    roiManager("Rename", "Enlarged NC");

    // Shoulders

    //Shoulder 1
    
	setTool("point");
	makePoint(2088, 3984, "small yellow hybrid");
    waitForUser("Define Shoulder 1 with a point","1. Mark a point in the Shoulder origen of interest\n2. Use *t* key to save ROI\n3. Repeat for as many areas as necessary\n  \nWhen done, use OK to continue");
	roiManager("Select", roiManager("count")-1);
	run("Enlarge...", "enlarge=750");
    roiManager("add");
    roiManager("Select", roiManager("count")-1);
    roiManager("Rename", "Shoulder_Region 1");

    // Shoulder 2

 	setTool("point");
	makePoint(2088, 3984, "small yellow hybrid");
    waitForUser("Define Shoulder 2 with a point","1. Mark a point in the Shoulder origen of interest\n2. Use *t* key to save ROI\n3. Repeat for as many areas as necessary\n  \nWhen done, use OK to continue");
	roiManager("Select", roiManager("count")-1);
	run("Enlarge...", "enlarge=750");
    roiManager("add");
    roiManager("Select", roiManager("count")-1);
    roiManager("Rename", "Shoulder_Region 2");
	roiManager("deselect"); 
	roiManager("show none");

	// Create specicific ROIS

	// Create Pure NC Border region

	Array_With_ROIs_Indexes =  newArray(2,4);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("AND");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Enlarged NC_2");
	Array_With_ROIs_Indexes =  newArray(3,9);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "NC-Border");
	
	//Create Shoulders regions
	
	Array_With_ROIs_Indexes =  newArray(2,6);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("AND");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Shoulder-1");

	Array_With_ROIs_Indexes =  newArray(2,8);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("AND");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Shoulder-2");
	roiManager("deselect"); 
	roiManager("show none");

	// Create FC region
	
	Array_With_ROIs_Indexes =  newArray(2,11);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Plaque-Shoulder_1");
	Array_With_ROIs_Indexes =  newArray(12,13);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Plaque-NO_Shoulders");
	Array_With_ROIs_Indexes =  newArray(1,14);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("AND");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "FC");

	//Create Border region between NC and FC
	
	Array_With_ROIs_Indexes =  newArray(14,15);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Plaque NO shoulder-NO FC");
	Array_With_ROIs_Indexes =  newArray(6,9);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("OR");
	roiManager("Add");
	Array_With_ROIs_Indexes =  newArray(6,17);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Enlarged NC NO shoulder1");
	Array_With_ROIs_Indexes =  newArray(8,18);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("OR");
	roiManager("Add");
	Array_With_ROIs_Indexes =  newArray(8,19);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Enlarged NC NO shoulder1 and 2");
	Array_With_ROIs_Indexes =  newArray(15,20);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("OR");
	roiManager("Add");
	Array_With_ROIs_Indexes =  newArray(14,21);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Region between NC and FC");
	
	// Create NC Border region without shoulders

	Array_With_ROIs_Indexes =  newArray(10,20);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("AND");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "NC border without shoulders");
	roiManager("deselect"); 
	roiManager("show none");
	
	// Create Shoulders without NC border

	// SHoulder 1 NO NC border

	Array_With_ROIs_Indexes =  newArray(9,11);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("OR");
	roiManager("Add");
	Array_With_ROIs_Indexes =  newArray(9,24);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Shoulder 1 NO NC and NC border");

	// SHoulder 2 NO NC border
	
	Array_With_ROIs_Indexes =  newArray(9,12);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("OR");
	roiManager("Add");
	Array_With_ROIs_Indexes =  newArray(9,26);
	roiManager("Select",Array_With_ROIs_Indexes);
	roiManager("XOR");
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", "Shoulder 2 NO NC and NC border");

	
	//Save all ROIs detected and classified

	roiManager("deselect");
	roiManager("save", output+myimagename+"_ROIs.zip");



	
	//Adjust contrast in original

	selectImage(myORIImage);
	EnhanceChannelsContrast(myORIImage,1,300,1700);
	EnhanceChannelsContrast(myORIImage,2,500,1500);
	EnhanceChannelsContrast(myORIImage,3,100,1250);
	EnhanceChannelsContrast(myORIImage,4,500,1750);

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

	myroisarray=newArray(2,3,10,15,22,25,27);
	myroiscolors=newArray("red","green","blue","yellow","magenta","cyan","white");
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