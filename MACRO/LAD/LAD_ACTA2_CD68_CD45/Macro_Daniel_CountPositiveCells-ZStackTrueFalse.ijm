run("Set Measurements...", "mean limit redirect=None decimal=3");

dir1 = getDirectory("Choose directory with ND2 files to process...");
dir2 = getDirectory("Choose directory to save results...");
lista = getFileList(dir1);

//Arrays to save data

TotalNuclei=newArray(lista.length);
GreenCells=newArray(lista.length);
RedCells=newArray(lista.length);
FarRedCells=newArray(lista.length);
DoubleCellsGR=newArray(lista.length);
DoubleCellsGFR=newArray(lista.length);

setBatchMode(true);
roiManager("Associate", "false");
roiManager("Centered", "false");
roiManager("UseNames", "true");
run("Clear Results");
roiManager("Reset");
run("Bio-Formats Macro Extensions");
for (a=0; a<lista.length; a++) {
	if (endsWith(lista[a],"nd2")==1) {
		run("Bio-Formats Importer", "open=["+dir1+lista[a]+"] color_mode=Composite view=Hyperstack stack_order=XYCZT");
		roiManager("Reset");
		myORIImage=getImageID();
		run("Z Project...", "projection=[Max Intensity]");
		rename("FOTO");
		run("Split Channels");

	
		//Nuclear staining segmentation and count of total number of nuclei
		
		selectWindow("C1-FOTO");
		run("Gaussian Blur...", "sigma=1.5");
		run("Subtract Background...", "rolling=10");
		//run("FeatureJ Laplacian", "compute smoothing=2.5");
		setAutoThreshold("Moments dark");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Fill Holes");
		run("Watershed");
		run("Analyze Particles...", "size=50-Infinity pixel circularity=0.25-1.00 add");
		TotalNuclei[a]=roiManager("Count");//Total number of Nuclei
		roiManager("Deselect");
		
		
		for(c=0;c<TotalNuclei[a];c++){
			roiManager("Select", c);
			roiManager("rename", "N");
			run("Make Band...", "band=2");
			roiManager("Update");
		}
		roiManager("Deselect");
		
		//(imagename, gaussian, autoThreshold, meanintensityvalue, areavalue,roiname, roicolor)
		
		//Count of Far red cells
		
		FarRedCells[a]=SearchPositiveCells ("C4-FOTO", 0.8, true, "Moments", 500, 5,"FR", "white");

				
		//Count of red cells
		
		RedCells[a]=SearchPositiveCells ("C3-FOTO", 0.8, true, "Otsu", 200, 5,"R", "red");
		
		
		//Count of Green cells
		
		GreenCells[a]=SearchPositiveCells ("C2-FOTO", 0.8, false,"Minimum", 1000, 4,"G", "green");

			
		//Count of Green AND Far red cells
					
		DoubleCellsGFR[a]=SearchDoublePositiveCells ("C2-FOTO", "C4-FOTO", false, "Minimum", "Moments", 1000,4,500,5,"D", "cyan");
		

		//Count of Green AND red cells
					
		DoubleCellsGR[a]=SearchDoublePositiveCells ("C2-FOTO", "C3-FOTO", false, "Minimum", "Otsu", 1000,4,200,5,"Y", "orange");



		//Create binary images
		MakeBinary("C4-FOTO");
		MakeBinary("C3-FOTO");
		MakeBinary("C2-FOTO");


		
		roiManager("Deselect");
		roiManager("Save", dir2 + lista[a]+"_AnalysisROIs.zip");


		//Save MAX image

		selectImage(myORIImage);
		run("Z Project...", "projection=[Max Intensity]");
		saveAs("Tiff", dir2+lista[a]+"_MAX.tif");
		
		
		//Save Image with masks
		run("Merge Channels...", "c1=C3-FOTO c2=C2-FOTO c3=[C1-FOTO] c4=C4-FOTO ignore");
		roiManager("Show All without labels");
		run("Flatten");
		saveAs("Tiff", dir2+lista[a]+"_ROIBins");
		run("Close All");
		roiManager("Reset");
		run("Clear Results");
		
	}
}


///Create Result table
		
		
for(a=0;a<lista.length; a++) {
	setResult("Image name", a, lista[a]);
	setResult("Number of Nuclei", a, TotalNuclei[a]);
	setResult("Number of Green Cells", a, GreenCells[a]);
	setResult("Number of Red Cells", a, RedCells[a]);
	setResult("Number of FarRed Cells", a, FarRedCells[a]);
	setResult("Number of Green AND FarRed Cells", a, DoubleCellsGFR[a]);
	setResult("Number of Green AND Red Cells", a, DoubleCellsGR[a]);
}
updateResults();

selectWindow("Results");
saveAs("results", dir2+"Results.xls");

waitForUser("Done! Your results are here: "+ dir2+"\nMake sure dots and commas are properly displayed on your data sheet");


//Macro functions


function SearchPositiveCells (imagename, gaussian, autoThyesorno,autoThreshold, meanintensityvalue, areavalue,roiname, roicolor){
	selectWindow(imagename);
	run("Select None");
	run("Gaussian Blur...", "sigma="+gaussian);
	
	
	if(autoThyesorno==true) {	setAutoThreshold(autoThreshold+" dark");
	}else{
		getStatistics(areamychannel, meanmychannel, minmychannel, maxmychannel, stdmychannel);
		setThreshold(meanintensityvalue, maxmychannel);
	}
	
	
	cells=0;
	for(j=0;j<roiManager("count");j++){
		selectWindow(imagename);
		roiManager("Select", j);
		List.setMeasurements("limit");	
		areacells=List.getValue("Area");
		meancells=List.getValue("Mean");
		if(meancells>meanintensityvalue && areacells>areavalue ) {
			roiManager("Select", j);
			roiManager("Rename", roiname);
			cells++;
			roiManager("Select", j);
			roiManager("Set Color", roicolor);
			roiManager("Set Line Width", 0);
		}
		
	}
	return cells;
}


function SearchDoublePositiveCells (imagenameA, imagenameB, autoThyesornoA ,autoThresholdA, autoThresholdB, meanintensityvalueA, areavalueA,meanintensityvalueB, areavalueB, roiname, roicolor){
	selectWindow(imagenameA);
	run("Select None");

	if(autoThyesornoA==true) {	setAutoThreshold(autoThresholdA+" dark");
	}else{
		getStatistics(areamychannelA, meanmychannelA, minmychannelA, maxmychannelA, stdmychannelA);
		setThreshold(meanintensityvalueA, maxmychannelA);
	}
	

	selectWindow(imagenameB);
	run("Select None");
	setAutoThreshold(autoThresholdB+" dark");
	cells=0;
	for(j=0;j<roiManager("count");j++){
		selectWindow(imagenameA);
		roiManager("Select", j);
		List.setMeasurements("limit");	
		areacellsA=List.getValue("Area");
		meancellsA=List.getValue("Mean");
		selectWindow(imagenameB);
		roiManager("Select", j);
		List.setMeasurements("limit");	
		areacellsB=List.getValue("Area");
		meancellsB=List.getValue("Mean");
		if(meancellsA>meanintensityvalueA && areacellsA>areavalueA) {
			selectWindow(imagenameB);
			roiManager("Select", j);
			if(meancellsB>meanintensityvalueB && areacellsB>areavalueB) {
				roiManager("Select", j);
				roiManager("Rename", roiname);
				cells++;
				roiManager("Select", j);
				roiManager("Set Color", roicolor);
				roiManager("Set Line Width", 0);
			}
		}
		
	}
	return cells;
}


function MakeBinary(imagenameforbin){
	selectWindow(imagenameforbin);
	run("Select None");
	roiManager("Show None");
	setOption("BlackBackground", true);
	run("Make Binary");
}

