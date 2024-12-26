//path="C:/Users/vlabrador/Desktop/Resultados"+File.separator;

dir = getDirectory("Choose directory to save results...");

waitForUser("Open fluo image. OK when done to continue");
imagefluo=getTitle();
imagefluoID=getImageID();


waitForUser("Open mask image. OK when done to continue");
imagemask=getTitle();
imagemaskID=getImageID();


//Create mask selection

selectImage(imagemaskID);
setThreshold(0, 0, "raw");
run("Create Selection");
roiManager("add");
roiManager("select", roiManager("count")-1);
roiManager("rename", imagefluo);

selectImage(imagemaskID);
run("Close");

//Segment Fluo image

selectImage(imagefluoID);
run("Select None");
run("Duplicate...", "title="+imagefluo+"_InsideROI duplicate");
roiManager("select", roiManager("count")-1);
setBackgroundColor(0, 0, 0);
run("Clear Outside");
run("Select None");
saveAs(".tif", dir+imagefluo+"_OutsideROI");
run("Close");

selectImage(imagefluoID);
roiManager("select", roiManager("count")-1);
run("Clear");
run("Select None");
saveAs(".tif", dir+imagefluo+"_InsideROI");
run("Close All");

roiManager("deselect");
roiManager("save", dir+"ROIs.zip");

waitForUser("Hecho, a por la siguiente!");



