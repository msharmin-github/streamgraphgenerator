/*     StreamGraphSeriesOnsetUtility - utility class to allow sorting of StreamGraphSeries by series onset
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
public class StreamGraphSeriesOnsetUtility implements Comparable {
  
  public StreamGraphSeries thisSeries;
  
  public StreamGraphSeriesOnsetUtility(StreamGraphSeries series) {
    thisSeries = series;
  }
  
  /* compareTo
   *
   * utility method to allow comparison by onset time
   *
   */
  public int compareTo(Object o) {
    StreamGraphSeriesOnsetUtility u = (StreamGraphSeriesOnsetUtility)o;
    StreamGraphSeries n = (StreamGraphSeries)u.thisSeries;
    if (n.Onset_Index () > thisSeries.Onset_Index ()) {
      return -1;
    }
    else if (n.Onset_Index () < thisSeries.Onset_Index ()) {
      return 1;
    }
    else {
      return 0;
    }
  }
  
}
