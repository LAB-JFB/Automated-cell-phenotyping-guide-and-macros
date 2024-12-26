
path = getDirectory("Choose folder with MAX projection images and ROI zip files");
indexpath=getFileList(path);
output=getDirectory("Choose folder to save results");


setBatchMode(false);
run("Clear Results");
roiManager("Associate", "false");
roiManager("Centered", "false");
roiManager("UseNames", "true");
roiManager("Show All with labels");
roiManager("Reset");



for(i=0; i<indexpath.length;i++){
	if(endsWith(indexpath[i], ".zip")){
		roiManager("open", path+indexpath[i]);
		basename=split(indexpath[i], ".");
		open(path+basename[0]+".nd2_MAX.tif");

		//Edition of ROIs using roiManager tools
		setTool("rectangle");
		run("Channels Tool...");
		roiManager("Show All with labels");
		waitForUser("Edit ROIs using roiManager window tools", "Rename with appropriate ROI name if adding new ROIs:\n  \n  N: Nuclei\n  G: Green\n  R: Red\n  FR: FarRed\n  Y: Green+Red\n  D: Green+FarRed\n   \nOK to Continue with final counting of cells");

		
		//Count Cells after ROI edition based on ROI name

		Green=0;
		Red=0;
		FarRed=0;
		Nuclei=0;
		GreenRed=0;
		GreenFarRed=0;

		totalROIs=roiManager("count");
		for(myroi=0;myroi<totalROIs;myroi++){
			roiManager("select", myroi);
			tempROIname=Roi.getName;
			ROIname=split(tempROIname, "-");
			if(ROIname[0]=="N"){
				Nuclei++;
				roiManager("select", myroi);
				roiManager("Set Color", "yellow");
				roiManager("Set Line Width", 0);
			}else if (ROIname[0]=="G"){
				Green++;
				roiManager("select", myroi);
				roiManager("Set Color", "green");
				roiManager("Set Line Width", 0);
			}else if (ROIname[0]=="R"){
				Red++;
				roiManager("select", myroi);
				roiManager("Set Color", "red");
				roiManager("Set Line Width", 0);
			}else if (ROIname[0]=="FR"){
				FarRed++;
				roiManager("select", myroi);
				roiManager("Set Color", "white");
				roiManager("Set Line Width", 0);
			}else if (ROIname[0]=="Y"){
				GreenRed++;
				roiManager("select", myroi);
				roiManager("Set Color", "orange");
				roiManager("Set Line Width", 0);
			}else if (ROIname[0]=="D"){
				GreenFarRed++;
				roiManager("select", myroi);
				roiManager("Set Color", "cyan");
				roiManager("Set Line Width", 0);
			}
		}
			
	
		//Create result table

	myrow=nResults;
	setResult("Image name", myrow, basename[0]);
	setResult("Number of Total Nuclei", myrow, totalROIs);
	setResult("Number of Green Cells", myrow, Green);
	setResult("Number of Red Cells", myrow, Red);
	setResult("Number of FarRed Cells", myrow, FarRed);
	setResult("Number of Green AND FarRed Cells", myrow, GreenFarRed);
	setResult("Number of Green AND Red Cells", myrow, GreenRed);
	updateResults();

	//Save edited ROIs

	roiManager("deselect");
	roiManager("save", output+basename[0]+"-EditedROIs.zip");

	//Close everything before opening new image
	roiManager("reset");
	run("Close All");
	
	}
}
selectWindow("Results");
saveAs("results", output+"EditedResults.xls");

waitForUser("Done! Your new counts and rois are here: "+ output);



