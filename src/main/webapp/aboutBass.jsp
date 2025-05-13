<%@ page contentType="text/html; charset=utf-8" language="java"
import="org.ecocean.*,org.ecocean.shepherd.core.*,
         org.ecocean.servlet.ServletUtilities,
         java.util.Properties
         "
%>

<%
String context=ServletUtilities.getContext(request);

Properties props = new Properties();
//Find what language we are in.
String langCode = ServletUtilities.getLanguageCode(request);
//Grab the properties file with the correct language strings.
props = ShepherdProperties.getProperties("aboutBass.properties", langCode, context);
%>
<jsp:include page="header.jsp" flush="true"/>
<link rel="stylesheet" href="css/bassStyles.css">
<div class="container maincontent">


        
  <h1><%=props.getProperty("mainHeader") %></h1>
  <h2><%=props.getProperty("overviewHeader") %></h2>

  <p>
  <%=props.getProperty("overviewP1") %>
  </p>

  <div class="container">
    <div class="row">
      <div class="col-xs-3">
      </div>	
      <div class="col-xs-6">
	    <img class="bass_image" src="cust/mantamatcher/img/bass/danHardingAboutProject.png" />
	    <label class="image_label"><%=props.getProperty("adultImageCaption") %></label>
      </div>
    </div>
  </div>

  <p>
  <%=props.getProperty("overviewP2") %>
  </p>

  <br>

  <div class="container">
    <div class="row">
      <div class="col-xs-3">
      </div>	
      <div class="col-xs-6">
	    <img class="bass_image" src="cust/mantamatcher/img/bass/bass_juv.png" />
	    <label class="image_label"><%=props.getProperty("juvImageCaption") %></label>
      </div>
    </div>
  </div>

  <h3><%=props.getProperty("historyHeader") %></h3>
  <h4><%=props.getProperty("habitsSubHeader") %></h4>

  <p>
  <%=props.getProperty("historyP1") %>
  </p>
  <br>

  <div class="container">
    <div class="row">
      <div class="col-xs-3">
      </div>	
      <div class="col-xs-6">
    	  <img class="bass_image" src="cust/mantamatcher/img/bass/feeding_habits.gif" />
	    <label class="image_label"><%=props.getProperty("feedingImage") %></label>
      </div>
    </div>
  </div>



  <h4><%=props.getProperty("habitatsHeader") %></h4>
  <p>
  <%=props.getProperty("habitatsP1") %>
  </p>

  <div class="container">
    <div class="row">
      <div class="col-xs-3">
      </div>	
      <div class="col-xs-6">
    	  <img class="bass_image" src="cust/mantamatcher/img/bass/danHardingHabitat.png" />
	    <label class="image_label"><%=props.getProperty("multipleGSBImage") %></label>
      </div>
    </div>
  </div>

  <h4><%=props.getProperty("distributionHeader") %></h4>
  <p>
  <%=props.getProperty("distributionP1") %>
  </p>

  <br>

  <div class="container">
    <div class="row">
      <div class="col-xs-6">
    		<img class="bass_image range_map" src="cust/mantamatcher/img/bass/GSB_final_long-01_1900x2596.png" />
	    	<label class="image_label"><%=props.getProperty("rangeMapImage") %></label>
      </div>	
      <div class="col-xs-6">
	    	<img class="bass_image bass_caught" src="cust/mantamatcher/img/bass/bass_caught.png" />
	  	    <label class="image_label"><%=props.getProperty("caughtBassImage") %></label>
      </div>
    </div>
  </div>






  <h4><%=props.getProperty("popConserveHeader") %></h4>
  <p>
  <%=props.getProperty("popConserveP1") %>
  </p>

  <br>

  <div class="container">
    <div class="row">
      <div class="col-xs-3">
      </div>	
      <div class="col-xs-6">
	    	<img class="bass_image bass_caught" src="cust/mantamatcher/img/bass/commercial_landing.png" />
	    	<label class="image_label"><%=props.getProperty("comLandingImage") %></label>
      </div>
    </div>
  </div>

  <p>
  <%=props.getProperty("popConserveP2") %>
  </p>

  <h4><%=props.getProperty("referencesHeader")%></h4>

  <p>
  <%=props.getProperty("ref1") %>
  </p>

  <p>
  <%=props.getProperty("ref2") %>
  </p>

  <p>
  <%=props.getProperty("ref3") %>
  </p>

  <p>
  <%=props.getProperty("ref4") %>
  </p>

  <p>
  <%=props.getProperty("ref5") %>
  </p>




</div>

<jsp:include page="footer.jsp" flush="true"/>
