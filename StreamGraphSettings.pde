/*     StreamGraphSettings - Adjust settings for generating the StreamGraph 
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
public class StreamGraphSettings {

  // currently populated with default settings
  public boolean exportPDF = true;                   // false means you get a window showing you the graph PDF is at A4 Landscape

    public int windowX = 1000;                         // window size. Default: 1000 x 400
  public int windowY = 400;
  public color bg = color(255, 255, 255);            // set the background colour
  public int ordering = 1;                           // what dataset ordering to use: 0 = random, 1 = onset-ordered, 2 = inside-out, 3 = timeseries size

  public int g0_positioning = 1;                     // what g0 positioning to use: 0 = stacked graph, 1 = symmetrical, 2 = weighted, 3 = streamgraph

  public int colouring = 2;                          // how to colour the graph: 0 = random based on seed colour; 1 = ordering based, 2 = onset-based, 
  //                          3 = time-series sized based, 4 = time & onset size based

  public color seed_colour = color(107, 163, 211);   // set the seed colouring to use
  public int seed_colour_tolerance = 150;            // tolerance of randomly generated colours
  public boolean use_curves = true;                  // true if to use curved lines
  public float curve_tightness = 0.5;                // tightness of the curves (between -5.0 and 5.0)

  public String graphTitle = "Youtube Profile Views";

  public String fontToUse = "Agency FB";
  public int titleFontSize = 48;



  int timeSeriesLength;                 // what is the total length we are dealing with
  float maximumHeight;

  int xResolutionMultiplier;        
  int yResolutionMultiplier;
}

