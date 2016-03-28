/*
 * The Shepherd Project - A Mark-Recapture Framework
 * Copyright (C) 2011 Jason Holmberg
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package org.ecocean.servlet;

import org.ecocean.*;
import org.ecocean.genetics.*;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URISyntaxException;
import java.util.Locale;


//Set alternateID for this encounter/sighting
public class TissueSampleRemoveMicrosatelliteMarkers extends HttpServlet {

  public void init(ServletConfig config) throws ServletException {
    super.init(config);
  }

  public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    doPost(request, response);
  }

  public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String context = ServletUtilities.getContext(request);
    String langCode = ServletUtilities.getLanguageCode(request);
    Locale locale = new Locale(langCode);
    Shepherd myShepherd = new Shepherd(context);
    //set up for response
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();
    boolean locked = false;

    // Prepare for user response.
    String link = "#";
    try {
      link = CommonConfiguration.getServerURL(request, request.getContextPath()) + String.format("/encounters/encounter.jsp?number=%s", request.getParameter("encounter"));
    }
    catch (URISyntaxException ex) {
    }
    ActionResult actionResult = new ActionResult(locale, "encounter.editField", true, link).setLinkParams(request.getParameter("encounter"));

    myShepherd.beginDBTransaction();
    if ((request.getParameter("analysisID")!=null)&&(request.getParameter("encounter")!=null)&&(request.getParameter("sampleID")!=null)&& (!request.getParameter("sampleID").equals("")) && (myShepherd.isTissueSample(request.getParameter("sampleID"), request.getParameter("encounter")))&&(myShepherd.isEncounter(request.getParameter("encounter")))) {
      try {
        
        Encounter enc = myShepherd.getEncounter(request.getParameter("encounter"));
        TissueSample genSample=myShepherd.getTissueSample(request.getParameter("sampleID"), request.getParameter("encounter"));
        
        //MitochondrialDNAAnalysis mtDNA=myShepherd.getMitochondrialDNAAnalysis(request.getParameter("sampleID"), request.getParameter("encounter"), request.getParameter("analysisID"));
        MicrosatelliteMarkersAnalysis msDNA=myShepherd.getMicrosatelliteMarkersAnalysis(request.getParameter("sampleID"), request.getParameter("encounter"), request.getParameter("analysisID"));
        enc.addComments("<p><em>" + request.getRemoteUser() + " on " + (new java.util.Date()).toString() + "</em><br />" + "Removed microsatellite marker analysis ID "+request.getParameter("analysisID")+".<br />"+msDNA.getHTMLString());

        genSample.removeGeneticAnalysis(msDNA);

        myShepherd.throwAwayMicrosatelliteMarkersAnalysis(msDNA);          
        enc.addComments("<p><em>" + request.getRemoteUser() + " on " + (new java.util.Date()).toString() + "</em><br />" + "Removed microsatellite marker analysis ID "+request.getParameter("analysisID")+".<br />");

      } 
      catch (Exception le) {
        locked = true;
        le.printStackTrace();
        myShepherd.rollbackDBTransaction();
        //myShepherd.closeDBTransaction();
      }

      if (!locked) {
        myShepherd.commitDBTransaction();
        //myShepherd.closeDBTransaction();
        actionResult.setMessageOverrideKey("removeTissueSampleMicrosatelliteMarkers").setMessageParams(request.getParameter("encounter"), request.getParameter("sampleID"));
      }
      else {
        actionResult.setSucceeded(false).setMessageOverrideKey("locked");
      }
    } else {
      myShepherd.rollbackDBTransaction();
      actionResult.setSucceeded(false);
    }

    // Reply to user.
    request.getSession().setAttribute(ActionResult.SESSION_KEY, actionResult);
    getServletConfig().getServletContext().getRequestDispatcher(ActionResult.JSP_PAGE).forward(request, response);

    out.close();
    myShepherd.closeDBTransaction();
  }
}
