/*     StreamGraph - Main program code
       Copyright (C) 2010 Matthew Larsen
 
   This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public 
   License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later 
   version.
   
   This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public License along with this library; if not, write to the Free 
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
   
   Contact: mat.larsen@gmail.com
   Website: http://code.google.com/p/streamgraphgenerator/
   
 */
import processing.pdf.*;

ArrayList series;                     // arraylist holding the series data

/*int timeSeriesLength;                 // what is the total length we are dealing with
float maximumHeight;

int xResolutionMultiplier;        
int yResolutionMultiplier;*/

BufferedReader reader;                // to read in our data
String line;                          // current line being read in from data

StreamGraphSettings currentSettings = new StreamGraphSettings();

PFont titleFont;                      // our title stuff
PFont labelFont;

/* SETTINGS *//*
int windowX = 1024;                         // window size
int windowY = 400;
color bg = color(255, 255, 255);            // set the background colour
int ordering = 2;                           // what dataset ordering to use: 0 = random, 1 = onset-ordered, 2 = inside-out
int g0_positioning = 1;                     // what g0 positioning to use: 0 = stacked graph, 1 = symmetrical, 2 = weighted, 3 = streamgraph
int colouring = 0;                          // how to colour the graph: 0 = random based on seed colour; 1 = ordering based, 2 = onset-based, 
//          3 = time-series sized based, 4 = time & onset size based
color seed_colour = color(107, 163, 211);     // set the seed colouring to use
int seed_colour_tolerance = 150;            // tolerance of randomly generated colours
boolean use_curves = true;                  // true if to use curved lines
float curve_tightness = 0.5;                // tightness of the curves (between -5.0 and 5.0)
*/


void setup() {
  // exporting to PDF?
  if (currentSettings.exportPDF) {
    currentSettings.windowX = 3508;
    currentSettings.windowY = 2480;
  }
  
  // set the window size
  if (currentSettings.exportPDF) {
    size (currentSettings.windowX, currentSettings.windowY, PDF, selectOutput("Save PDF As..."));
  }
  else {
    size (currentSettings.windowX, currentSettings.windowY);
  }
  
  
  series = new ArrayList();

  // open the file for reading
  String loadPath = selectInput();  // opens the filechooser

  reader = createReader(loadPath);
  println(loadPath);
  // read in the file and setup our streamgraphseries objects

  try {
    while ((line = reader.readLine()) != null) {
      // splitup the line by commas
      String[] thisLine = line.split(",");

      // the first element is the name
      StreamGraphSeries newSeries = new StreamGraphSeries();

      // set the title
      newSeries.name = thisLine[0];

      // create an appropriately sized array
      newSeries.originalData = new Float[thisLine.length - 1];

      // go through the rest of the array and input the values
      for (int x = 1; x < thisLine.length; x++) {
        newSeries.originalData[x-1] = Float.parseFloat(thisLine[x]);
      }

      // add this object to the arraylist
      series.add(newSeries);

    }
  }
  catch (Exception e) {
    e.printStackTrace();
  }





  // perform some default setup & analysis
  
  
  
  println("X: " + currentSettings.windowX + " Y: " + currentSettings.windowY);

  // determine time series length
  currentSettings.timeSeriesLength = ((StreamGraphSeries)series.get(0)).originalData.length;
  println("\nTime-series length: " + currentSettings.timeSeriesLength);

  // determine the thickest part
  for (int x = 0; x < series.size(); x++) {
    StreamGraphSeries temps = (StreamGraphSeries)series.get(x);
    currentSettings.maximumHeight += temps.Maximum_Height();
  }
  println("Maximum thickness: " + currentSettings.maximumHeight);

  // determine resolution multipliers
  currentSettings.xResolutionMultiplier = (int)(currentSettings.windowX / (currentSettings.timeSeriesLength - 1));
  
  // make the y multiplier a function of the width, to keep the graph looking sensible
  //currentSettings.yResolutionMultiplier = 2 * (int)(currentSettings.windowY / currentSettings.maximumHeight);
  currentSettings.yResolutionMultiplier = ((int)(currentSettings.windowX / currentSettings.maximumHeight)) ;

  println("X Multiplier: " + currentSettings.xResolutionMultiplier);
  println("Y Multiplier: " + currentSettings.yResolutionMultiplier);

  // order the dataset
  switch (currentSettings.ordering) {
  case 0: 
    series = random_Ordering(series); 
    break;
  case 1: 
    series = onset_Ordering(series); 
    break;
  case 2: 
    series = insideOut_Ordering(series); 
    break;
  case 3:
    series = timeSeriesSize_Ordering(series);
    break;
  }
/*
  println("\nItems in Dataset:");
  println("============================");
  for (int x = 0; x < series.size(); x++) {
    StreamGraphSeries temps = (StreamGraphSeries)series.get(x);
    println("Name: " + temps.name + "   Size: " + temps.Values_Sum() + "   Max Height: " + temps.Maximum_Height() + "   Onset Index: " + temps.Onset_Index());
  }
*/
  // set colour mode and colours
  colorMode(HSB);
  switch ( currentSettings.colouring ) {
    case 0: color_random(); break;
    case 1: color_order(); break;
    case 2: color_onsetTime(); break;
    case 3: color_timeSeriesSize(); break;
    case 4: color_onsetAndTime(); break;
  }



  
  
  // and text mode
  textMode(SHAPE);
  
  
  // title font
  titleFont = createFont(currentSettings.fontToUse, currentSettings.titleFontSize);
  //textMode(SHAPE);
  //textFont(titleFont);

}


void draw() {

  // OK! Lets actually draw this thing

  // smooth lines please
  smooth();
  
  // colour mode
  colorMode(RGB);

  // set the background
  background(currentSettings.bg);

  // set the curve tightness
  curveTightness(currentSettings.curve_tightness);


  // we want to store the top of the previous shape in an array. this becomes the base for the next shape
  int[] prevHeight = new int[currentSettings.timeSeriesLength];
  int[] thisHeight = new int[currentSettings.timeSeriesLength];

  // initially the prevHeight will be the g0 line, fill it in
  for (int i = 0; i < currentSettings.timeSeriesLength; i++) {

    int g0position = 0;

    switch (currentSettings.g0_positioning) {
    case 0: 
      g0position = g0Location_Traditional(i); 
      break;
    case 1: 
      g0position = g0Location_ThemeRiver(i); 
      break;
    case 2: 
      g0position = g0Location_StreamGraph(i); 
      break;
    }

    prevHeight[i] = (height - height / 2 - g0position );
  }

  // for each shape
  for (int x = 0; x < series.size() ; x++) { //|| x < series.size() arflimit
    //noFill();
    //beginShape();
    StreamGraphSeries thisSeries = (StreamGraphSeries)series.get(x);

    // we need to calculate the heights for this timeseries. This will be prevheight + this height. store in the thisheight array
    for (int i = 0; i < currentSettings.timeSeriesLength; i++) {  // for each time interval
      thisHeight[i] = prevHeight[i] - (int)(thisSeries.originalData[i] * currentSettings.yResolutionMultiplier);

    }

    // now we have the tops and bottoms, draw this shape

    // set the fill
    fill(thisSeries.seriesColour);
    //stroke(thisSeries.seriesColour);
    noStroke();

    // begin
    beginShape();

    // draw all along the bottom
    for (int y = 1; y < prevHeight.length; y++) {
      if (currentSettings.use_curves) {
        curveVertex( y * currentSettings.xResolutionMultiplier, prevHeight[y] );
      }
      else {
        vertex( y * currentSettings.xResolutionMultiplier, prevHeight[y] );
      }
    }

    // normal line to the top-right
    if (currentSettings.use_curves) {
      curveTightness(1.0);
      curveVertex( (prevHeight.length - 1) * currentSettings.xResolutionMultiplier, thisHeight[thisHeight.length - 1]);
      curveTightness(currentSettings.curve_tightness);
    }
    else {
      vertex( (prevHeight.length - 1) * currentSettings.xResolutionMultiplier, thisHeight[thisHeight.length - 1]);
    }

    // draw all along the top (back to front)
    for (int y = prevHeight.length - 2; y > 0 ; y--) {
      if (currentSettings.use_curves) {
        curveVertex( y * currentSettings.xResolutionMultiplier, thisHeight[y] );
      }
      else {
        vertex( y * currentSettings.xResolutionMultiplier, thisHeight[y] );
      }
    }

    // normal line to bottom-left
    if (currentSettings.use_curves) {
      curveTightness(1.0);
      curveVertex( 0, prevHeight[1]);
      curveTightness(currentSettings.curve_tightness);
    }
    else {
      vertex( 0, prevHeight[1]);
    }


    // end the shape
    endShape();
    
    
    // BETTER IDEA
    // continuously scan along the graph and integrate over the x to x+2 points. The point with the largest area then becomes the label point (point x+1)
    
    int bestXSoFar = 0;
    float bestXSoFarArea = 0.0;
    for (int i = 0; i < currentSettings.timeSeriesLength - 2; i++) {
      float area1 = 0.0;
      float area2 = 0.0;
      float currentTest = 0.0;
      
      // what is the area between this and x+1
      float a = Math.abs(thisSeries.originalData[i]);
      float b = Math.abs(thisSeries.originalData[i + 1]);
      
      if (a < b) {
        area1 = a + 0.5 * b;
      }
      else {
        area1 = b + 0.5 * a;
      }
      
      // what is the area between x+1 and x+2
      a = Math.abs(thisSeries.originalData[i + 1]);
      b = Math.abs(thisSeries.originalData[i + 2]);
      
      if (a < b) {
        area2 = a + 0.5 * b;
      }
      else {
        area2 = b + 0.5 * a;
      }
      
      // add them
      currentTest = area1 + area2;
      
      // compare to existing area
      if (currentTest > bestXSoFarArea) {
        bestXSoFar = i;
        bestXSoFarArea = currentTest;
      }
    }
    
    
    // save the text location values into the series
    thisSeries.textX = (bestXSoFar) * currentSettings.xResolutionMultiplier;
    thisSeries.textY = prevHeight[bestXSoFar] - (int)(thisSeries.originalData[bestXSoFar] * currentSettings.yResolutionMultiplier / 2);
    thisSeries.textArea = bestXSoFarArea;
    
    
    // swap over the height arrays
    prevHeight = Arrays.copyOf(thisHeight, thisHeight.length);
    
  }
  
  // Graph Title
  // calculate a size for it
  int titleFontSize = currentSettings.yResolutionMultiplier / 5;
  colorMode(RGB, 255);
  
  textFont(titleFont, titleFontSize);
  fill(100, 100, 100);
  //textMode(MODEL);
  text(currentSettings.graphTitle, 10, titleFontSize);
  
  
  
  // labels
  //colorMode(RGB);
  for (int i = 0; i < series.size(); i++) {
    StreamGraphSeries currentSeries = (StreamGraphSeries)series.get(i);
    
    
    textFont(titleFont, currentSettings.windowX / 25 * currentSeries.textArea);
    
    //int textX = (int)(currentSeries.textX - ((currentSeries.name.length() * 30 * currentSeries.textArea) / 2));
    int textX = (int)(currentSeries.textX - ((currentSeries.name.length() * currentSettings.windowX / 90 * currentSeries.textArea) / 2));
    //int textY = currentSeries.textY + ((currentSeries.textArea * currentSettings.yResolutionMultiplier) / 2) + ((100 * currentSeries.textArea) / 2);
    int textY = currentSeries.textY ;
    
    //fill(100,100,100,150);
    
    // give it a stroke
    fill(255,255,255,150);
    text(currentSeries.name, textX + 1, textY + 1);
    text(currentSeries.name, textX + 1, textY - 1);
    text(currentSeries.name, textX - 1, textY + 1);
    text(currentSeries.name, textX - 1, textY - 1);
    
    // a white shadow
    fill(255,255,255,150);
    text(currentSeries.name, textX + 2, textY + 2);
    //fill(255,255,255,150);
    
    fill(red(currentSeries.seriesColour),green(currentSeries.seriesColour),blue(currentSeries.seriesColour));
    text(currentSeries.name, textX, textY);
    
    
    
    // debug - draw a line
    
    //stroke(0,0,0);
    //ellipse(currentSeries.textX, currentSeries.textY, 50 * currentSeries.textArea, 50 * currentSeries.textArea);
    //line(currentSeries.textX, currentSeries.textY, currentSeries.textX, currentSeries.textY + currentSeries.textArea * currentSettings.yResolutionMultiplier);
    
  }
  
  
  // exit if drawing a PDF
  if (currentSettings.exportPDF) {
    println("done");
    exit();
  }
    
    
}

/*
 * COLOURING FUNCTIONS
 *
 * The following functions assign a colour to each of the series
 *
 */

// RANDOM BASED ON SEED
void color_random() {

  // set the colour mode to HSB
  // for each series, assign a random brightness and saturation of the seed value
  colorMode(HSB);

  Random randomNumbers = new Random();

  for (int i = 0; i < series.size(); i++) {
    StreamGraphSeries thisSeries = (StreamGraphSeries)series.get(i);
    thisSeries.seriesColour = color(hue(currentSettings.seed_colour), 255 - randomNumbers.nextInt(currentSettings.seed_colour_tolerance), 255 - randomNumbers.nextInt(currentSettings.seed_colour_tolerance));

  }

}

// ORDERING BASED
void color_order() {
  
  // ok, so we want to adjust the colour based on the ordering
  // we want to split up the available colours into root(n).
  // so lets use HSB space with a range of int(root(n))
  int rootN = (int)Math.sqrt(series.size());
  colorMode(HSB, rootN);
  
  // now progress through the colours for the series in its current order
  int currentHue = 0;
  int currentSaturation = 0;
  for (int i = 0; i < series.size(); i++) {
    StreamGraphSeries thisSeries = (StreamGraphSeries)series.get(i);
    
    thisSeries.seriesColour = color(currentHue, 5 + (currentSaturation++ / 2), 150 - currentHue / 2 );
    
    // if we have reached the max saturation, go to next hue
    if (currentSaturation > rootN) {
      currentHue++;
      currentSaturation = 0;
      
    }
    
  }
  
}

// TIME SERIES SIZE
void color_timeSeriesSize() {
  // we want to assign colours based on the size of the time series
  // how do we do this? we put them in timeseries size order and assign colours
  
  // create a new arraylist of util classes
  ArrayList sizeList = new ArrayList();
  for (int i = 0; i < series.size(); i++) {
    StreamGraphSeriesSizeUtility tempUtil = new StreamGraphSeriesSizeUtility((StreamGraphSeries)series.get(i));
    sizeList.add(tempUtil);
  }
  
  // sort that list
  Collections.sort(sizeList);
  
  // copy back to a normal streamgraphseries arraylist
  ArrayList returnSizeList = new ArrayList();
  for (int i = 0; i < sizeList.size(); i++) {
    StreamGraphSeriesSizeUtility sgssu = (StreamGraphSeriesSizeUtility)sizeList.get(i);
    returnSizeList.add((StreamGraphSeries)sgssu.thisSeries);
  }
  
  // now go through the list and assign colours in a similar manner to order-based
  int rootN = (int)Math.sqrt(returnSizeList.size());
  colorMode(HSB, rootN);
  
  // now progress through the colours for the series in its current order
  int currentHue = 0;
  int currentSaturation = 0;
  for (int i = 0; i < returnSizeList.size(); i++) {
    StreamGraphSeries thisSeries = (StreamGraphSeries)returnSizeList.get(i);
    
    thisSeries.seriesColour = color(currentHue, 5 + (currentSaturation++ / 2), 150 - currentHue / 2 );
    
    // if we have reached the max saturation, go to next hue
    if (currentSaturation > rootN) {
      currentHue++;
      currentSaturation = 0;
      
    }
    
  }
  
}

// ONSET - BASED
void color_onsetTime() {
  // we want to assign colours based on the onset time
  
  // create a new arraylist of util classes
  ArrayList sizeList = new ArrayList();
  for (int i = 0; i < series.size(); i++) {
    StreamGraphSeriesOnsetUtility tempUtil = new StreamGraphSeriesOnsetUtility((StreamGraphSeries)series.get(i));
    sizeList.add(tempUtil);
  }
  
  // sort that list
  Collections.sort(sizeList);
  
  // copy back to a normal streamgraphseries arraylist
  ArrayList returnSizeList = new ArrayList();
  for (int i = 0; i < sizeList.size(); i++) {
    StreamGraphSeriesOnsetUtility sgssu = (StreamGraphSeriesOnsetUtility)sizeList.get(i);
    returnSizeList.add((StreamGraphSeries)sgssu.thisSeries);
  }
  
  // now go through the list and assign colours in a similar manner to order-based
  int rootN = (int)Math.sqrt(returnSizeList.size());
  colorMode(HSB, rootN);
  
  // now progress through the colours for the series in its current order
  int currentHue = 0;
  int currentSaturation = 0;
  for (int i = 0; i < returnSizeList.size(); i++) {
    StreamGraphSeries thisSeries = (StreamGraphSeries)returnSizeList.get(i);
    
    thisSeries.seriesColour = color(currentHue, 5 + (currentSaturation++ / 2), 150 - currentHue / 2 );
    
    // if we have reached the max saturation, go to next hue
    if (currentSaturation > rootN) {
      currentHue++;
      currentSaturation = 0;
      
    }
    
  }
  
}

// TIME & ONSET BASED
void color_onsetAndTime() {
  
  // ok, what we need to do is construct 2 arraylists with the ordering for both in
  ArrayList sizeList = new ArrayList();
  ArrayList onsetList = new ArrayList();
  
  
  
  /* TIME SERIES ORDERING */
  // create a new arraylist of util classes
  for (int i = 0; i < series.size(); i++) {
    StreamGraphSeriesSizeUtility tempUtil = new StreamGraphSeriesSizeUtility((StreamGraphSeries)series.get(i));
    sizeList.add(tempUtil);
  }
  
  // sort that list
  Collections.sort(sizeList);
  
  // copy back to a normal streamgraphseries arraylist
  ArrayList returnSizeList = new ArrayList();
  for (int i = 0; i < sizeList.size(); i++) {
    StreamGraphSeriesSizeUtility sgssu = (StreamGraphSeriesSizeUtility)sizeList.get(i);
    returnSizeList.add((StreamGraphSeries)sgssu.thisSeries);
  }
  sizeList = returnSizeList;
  
  
  
  /* ONSET ORDERING */
  for (int i = 0; i < series.size(); i++) {
    StreamGraphSeriesOnsetUtility tempUtil = new StreamGraphSeriesOnsetUtility((StreamGraphSeries)series.get(i));
    onsetList.add(tempUtil);
  }
  
  // sort that list
  Collections.sort(onsetList);
  
  // copy back to a normal streamgraphseries arraylist
  returnSizeList = new ArrayList();
  for (int i = 0; i < onsetList.size(); i++) {
    StreamGraphSeriesOnsetUtility sgssu = (StreamGraphSeriesOnsetUtility)onsetList.get(i);
    returnSizeList.add((StreamGraphSeries)sgssu.thisSeries);
  }
  onsetList = returnSizeList;
  
  
  // OK, so to colour we go through each of the series
  // we locate the index of its onset and its time
  // from these we calculate the colour
  int rootN = (int)Math.sqrt(returnSizeList.size());
  colorMode(HSB, rootN);
  
  for (int i = 0; i < series.size(); i++) {
    StreamGraphSeries thisSeries = (StreamGraphSeries)series.get(i);
    
    int onsetIndex = onsetList.indexOf(series.get(i));
    int sizeIndex = sizeList.indexOf(series.get(i));
    
    // calculate a colour
    int currentHue = onsetIndex / rootN;
    int currentSaturation = sizeIndex / rootN;
    
    //thisSeries.seriesColour = color(currentHue, 5 + (currentSaturation++ / 2), 150 - currentHue / 2 );
    thisSeries.seriesColour = color(currentHue, currentSaturation, 150 - currentHue / 2 );
    
  }
  
}


/*
 * ORDERING FUNCTIONS
 *
 * The following functions order the series data appropriately
 * Sorting is only really relevant for data where things have a
 * start and end.
 */

// RANDOM
ArrayList random_Ordering(ArrayList toOrder) {
  ArrayList tempList = new ArrayList();

  // randomly pick objects until they are all in the new list
  Random randomNumbers = new Random();

  int selectElement;
  StreamGraphSeries tempSeries;

  while (toOrder.size() != 0) {
    selectElement = randomNumbers.nextInt(toOrder.size());
    tempSeries = (StreamGraphSeries)toOrder.get(selectElement);
    tempList.add(tempSeries);
    toOrder.remove(selectElement);
  }

  return tempList;

}

// ONSET TIME
ArrayList onset_Ordering(ArrayList toOrder) {
  Collections.sort(toOrder);
  return toOrder;
}

// INSIDE OUT - tries to create a sort of 'fan' of the series data
ArrayList insideOut_Ordering(ArrayList toOrder) {
  // first put in onset order
  Collections.sort(toOrder);

  // now create a blank array of the required capacity
  StreamGraphSeries[] insideOut = new StreamGraphSeries[toOrder.size()];

  // pick the lowest index in the sorted array and put in middle of new array
  insideOut[(insideOut.length - 1) / 2] = (StreamGraphSeries)toOrder.get(0);

  //println("insideout top element: " + (insideOut.length - 1));

  // now, as we work up the original array, put in the elements either side of the middle of the new array
  int middle = (insideOut.length - 1) / 2;
  int top = middle + 1;
  int bottom = middle - 1;

  //println ("middle: " + middle);
  //println ("top: " + top);
  //println ("bottom: " + bottom);

  for (int x = 1; x < toOrder.size(); x++) {

    // stop us going out of bounds (this is for last element)
    if (top == insideOut.length) {
      top = bottom;
    }
    if (bottom < 0) {
      bottom = top;
    }

    if (insideOut.length - top > bottom) {
      insideOut[top++] = (StreamGraphSeries)toOrder.get(x);
      //println(((StreamGraphSeries)toOrder.get(x)).name + " inserted at position " + (top - 1));
    }
    else {
      insideOut[bottom--] = (StreamGraphSeries)toOrder.get(x);
      //println(((StreamGraphSeries)toOrder.get(x)).name + " inserted at position " + (bottom + 1));
    }
  }

  return new ArrayList(Arrays.asList(insideOut));
}

// TIME SERIES SIZE
ArrayList timeSeriesSize_Ordering(ArrayList toOrder) {

  // copy to a new arraylist of utility classes
  ArrayList sizeList = new ArrayList();
  for (int i = 0; i < toOrder.size(); i++) {
    sizeList.add(new StreamGraphSeriesSizeUtility((StreamGraphSeries)toOrder.get(i)));
  }
  
  // sort it
  Collections.sort(sizeList);
  
  // copy back to a normal streamgraphseries arraylist
  ArrayList returnSizeList = new ArrayList();
  for (int i = 0; i < sizeList.size(); i++) {
    StreamGraphSeriesSizeUtility sgssu = (StreamGraphSeriesSizeUtility)sizeList.get(i);
    returnSizeList.add((StreamGraphSeries)sgssu.thisSeries);
  }
  
  // return it
  return returnSizeList;
  
}


/*
 * G0 LOCATION FUNCTIONS
 *
 * These functions return the point on the x-axis where the first time-series
 * layer is plotted from given time series location i
 */

// Traditional - All layers are plotted like traditional stacked data with the x-axis on the bottom
int g0Location_Traditional(int i) {
  return -(height / 2);
}

// ThemeRiver - Produces a streamgraph that is symmetrical about the x axis
int g0Location_ThemeRiver(int i) {
  // sum up the values for all the series data at this point
  float sum = 0.0;
  StreamGraphSeries tempSGSObj;

  for (int x = 0; x < series.size(); x++) {
    tempSGSObj = (StreamGraphSeries) series.get(x);
    sum = sum + tempSGSObj.originalData[i];
  }

  // divide by half, return the negation
  return -(int)(sum * currentSettings.yResolutionMultiplier * 0.5);

}

// StreamGraph - Symmetrical, produces smoother results compared to ThemeRiver
int g0Location_StreamGraph(int i) {
  return 0; 
}
// todo

