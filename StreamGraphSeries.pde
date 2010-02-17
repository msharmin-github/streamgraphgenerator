/*     StreamGraphSeries - class for containing the data for a series on a StreamGraph
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
public class StreamGraphSeries implements Comparable {
  
  public String name;              // name of this series
  public Float[] originalData;     // the original set of float values for it (height of layer compared to 0-x axis
  public color seriesColour;       // the colour of this series
  
  public int textX = 0;            // location for the labels
  public int textY = 0; 
  public float textArea = 0;
  
  /* Instance variables - these are to increase performance */
  private float value_sum;
  private boolean value_sum_set = false;
  private float maximum_height;
  private boolean maximum_height_set = false;
  private int onset_index;
  private boolean onset_index_set = false;
  
  /* Values_Sum
   *
   * returns the sum of all the values in this series
   *
   */
  public float Values_Sum () {
    
    if (!value_sum_set) {
      
      float tempSum = 0.0;
      
      for (int x = 0; x < originalData.length; x++) {
        tempSum += originalData[x];
      }
      
      value_sum = tempSum;
      value_sum_set = true;
      
    }
    
    return value_sum;
  }
  
  /* Maximum_Height
   * 
   * returns the greatest value in the data
   *
   */
  public float Maximum_Height () {
    
    if (!maximum_height_set) {
      // use a naive algorithm
      float max = originalData[0];
      float min = originalData[0];
    
      for (int i = 0; i < originalData.length; i++) {
        if (originalData[i] > max) {
          max = originalData[i];
        }
        else if (originalData[i] < min) {
          min = originalData[i];
        }
      }
      
      maximum_height = max;
      maximum_height_set = true;
    }
          
    return maximum_height;
  }
  
  /* Onset_Index
   *
   * returns the first index number where the data is non-zero
   *
   */
  public int Onset_Index () {
    
    if (!onset_index_set) {
      // do this naively
      for (int i = 0; i < originalData.length; i++) {
        if (originalData[i] != 0) {
          onset_index = i;
          break;
        }
      }
      
      onset_index_set = true;
    }
    
    return onset_index;
  }
  
  /* compareTo
   *
   * allows sorting of this class by onset time
   *
   */
  public int compareTo(Object o) {
    StreamGraphSeries n = (StreamGraphSeries)o;
    if (n.Onset_Index() > this.Onset_Index()) {
      return -1;
    }
    else if (n.Onset_Index() < this.Onset_Index()) {
      return 1;
    }
    else {
      return 0;
    }
  }
  
  /* compareToSize
   *
   * utility method to allow comparison by timeseries size
   *
   */
  public int compareToSize(Object o) {
    StreamGraphSeries n = (StreamGraphSeries)o;
    if (n.Values_Sum () > this.Values_Sum ()) {
      return -1;
    }
    else if (n.Values_Sum () < this.Values_Sum ()) {
      return 1;
    }
    else {
      return 0;
    }
  }
  
}
