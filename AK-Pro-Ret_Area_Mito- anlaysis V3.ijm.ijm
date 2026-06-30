//Run the Bionformats multipostion bioformat macro prior to this
inputFolder = getDirectory("Input directory");
outputData = inputFolder + "Output-Data" + File.separator;
if ( !(File.exists(outputData)) ) { File.makeDirectory(outputData); }
outputImages = inputFolder + "Output-Images" + File.separator;
if ( !(File.exists(outputImages)) ) { File.makeDirectory(outputImages); }
processFolder(inputFolder);
  
function processFolder(input) {
    list = getFileList(input);
    for (i = 0; i < list.length; i++) {
        if(File.isDirectory(list[i]))
            processFolder("" + input + list[i]);
        if(endsWith(list[i], ".tif"))
            processFile(input, list[i]);
    }
}
 
function processFile(input, file) {
          print("Processing: " + input + file);
        open(inputFolder + file);
    SaveName2=getTitle();SaveName=replace(SaveName2,".tif","");rename(SaveName);

roiManager("reset");

//MIP the Z stacks and adjust the contrast for both channels
Stack.setChannel(1); run("Enhance Contrast", "saturated=0.4");
Stack.setChannel(2); run("Enhance Contrast", "saturated=0.4");
run("Z Project...", "projection=[Max Intensity] all");rename("Max");
selectWindow("Max");
run("Z Project...", "projection=[Max Intensity]");rename("Max-Time");

//Ask about the ROI number
Dialog.create("Select the number of ROIs to create");
Dialog.addString("How many ROIs to draw", "1");
Dialog.show();
ROIN = Dialog.getString();
  
//loop the rest of this based on the answer above
for (i=0; i<ROIN; i++) {
selectImage("Max-Time");
waitForUser("On the image Max-Time, please draw an ROI around a cell. Do not let the ROI touch the cell. Then press OK");
roiManager("Add");
ROInum=roiManager("count");
roiManager("Select",ROInum-1);


//Mito Stuff
selectWindow("Max");
roiManager("Select",ROInum-1);
run("Duplicate...", "title=Mito duplicate channels=2");
selectWindow("Mito");
MitoName=getTitle();
setAutoThreshold("Default dark no-reset");
run("Analyze Particles...", "size=10-Infinity show=Masks exclude summarize stack");
selectWindow("Mask of Mito");
Pre1=replace(MitoName, "Mito","ROI_"+ROInum+"_Mito_");
saveAs("Tiff", outputImages+Pre1+"_"+SaveName);close();
selectWindow("Summary of Mito");
Table.save(outputData+Pre1+"_"+SaveName+".csv");Table.deleteRows(0, 50, "Summary of Mito");close("Summary of Mito");close("Mito");

//Actin Stuff
selectWindow("Max");
roiManager("Select",ROInum-1);
run("Duplicate...", "title=Actin duplicate channels=1");
ActinName=getTitle();
run("Median...", "radius=2 stack");
setAutoThreshold("Li dark no-reset");
run("Analyze Particles...", "size=100-Infinity show=Masks exclude include summarize stack");
selectWindow("Mask of Actin");
Pre2=replace(ActinName, "Actin","ROI_"+ROInum+"_Actin_");
saveAs("Tiff", outputImages+Pre2+"_"+SaveName);rename("ActMask");
selectWindow("Summary of Actin");
Table.save(outputData+Pre2+"_"+SaveName+".csv");Table.deleteRows(0, 50, "Summary of Actin");close("Summary of Actin");

selectWindow("ActMask");
run("Duplicate...", "title=Diff2 duplicate range=2-48");
selectWindow("ActMask");
run("Duplicate...", "title=Diff1 duplicate range=1-47");
run("Merge Channels...", "c1=Diff1 c2=Diff2 create keep");
selectWindow("Composite");
close("ActMask");
saveAs("Tiff", outputImages+"ROI_"+ROInum+"Pro-Ret_"+SaveName);close();

imageCalculator("Divide create stack", "Diff1","Diff2");
selectImage("Result of Diff1");rename("Protrusion");
setMinAndMax(0, 2);
setThreshold(0, 0, "raw");
selectImage("Protrusion");
run("Analyze Particles...", "size=2-Infinity show=Masks summarize stack");
selectImage("Protrusion");
saveAs("Tiff", outputImages+"ROI_"+ROInum+"_Protrusion_"+SaveName);close();
selectWindow("Summary of Protrusion");
Table.save(outputData+"ROI_"+ROInum+"_Protrusion_"+SaveName+".csv");Table.deleteRows(0, 50, "Summary of Protrusion");close("Summary of Protrusion");

imageCalculator("Divide create stack", "Diff2","Diff1");
selectImage("Result of Diff2");
rename("Retraction");
setMinAndMax(0, 2);
setThreshold(0, 0, "raw");
selectImage("Retraction");
run("Analyze Particles...", "size=2-Infinity show=Masks summarize stack");
selectImage("Retraction");

saveAs("Tiff", outputImages+"ROI_"+ROInum+"_Retraction_"+SaveName);close();
selectWindow("Summary of Retraction");
Table.save(outputData+"ROI_"+ROInum+"_Retraction_"+SaveName+".csv");Table.deleteRows(0, 50, "Summary of Retraction");close("Summary of Retraction");
close("Diff1");close("Diff2");

}
run("Close All");
}



