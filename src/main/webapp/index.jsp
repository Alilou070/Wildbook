<%@ page contentType="text/html; charset=utf-8" language="java"
     import="org.ecocean.*,
              org.ecocean.servlet.ServletUtilities,
              java.util.ArrayList,
              java.util.List,
              java.util.Map,
              java.util.Iterator,
              java.util.Properties,
              java.util.StringTokenizer,
              org.ecocean.cache.*
              "
%>
<%@ page import="org.ecocean.shepherd.core.Shepherd" %>
<%@ page import="org.ecocean.shepherd.core.ShepherdProperties" %>


<jsp:include page="header.jsp" flush="true"/>

<%
String context=ServletUtilities.getContext(request);

//set up our Shepherd

Shepherd myShepherd=null;
myShepherd=new Shepherd(context);
myShepherd.setAction("index.jsp");


String langCode=ServletUtilities.getLanguageCode(request);

//check for and inject a default user 'tomcat' if none exists
// Make a properties object for lang support.
Properties props = new Properties();
// Grab the properties file with the correct language strings.
props = ShepherdProperties.getProperties("index.properties", langCode,context);


//check for and inject a default user 'tomcat' if none exists
if (!CommonConfiguration.isWildbookInitialized(myShepherd)) {
  System.out.println("WARNING: index.jsp has determined that CommonConfiguration.isWildbookInitialized()==false!");
  %>
    <script type="text/javascript">
      console.log("Wildbook is not initialized!");
    </script>
  <%
  StartupWildbook.initializeWildbook(request, myShepherd);
}

String mapKey = CommonConfiguration.getGoogleMapsKey(context);
%>

<style type="text/css">
.full_screen_map {
position: absolute !important;
top: 0px !important;
left: 0px !important;
z-index: 1 !imporant;
width: 100% !important;
height: 100% !important;
margin-top: 0px !important;
margin-bottom: 8px !important;
}
</style>

<script src="//maps.google.com/maps/api/js?key=<%=mapKey%>&language=<%=langCode%>"></script>


<script src="cust/mantamatcher/js/google_maps_style_vars.js"></script>
<script src="cust/mantamatcher/js/richmarker-compiled.js"></script>


<!-- Adds fade-away scroll down prompt.  -->
<!-- Credit to Colin Irwin http://www.silvabokis.com for
	the code this was based off of. -->
<script>
$(window).load(function() {
	$("body.scrolled").removeClass("scrolled");
	$("body:not(.scrolled)").addClass("not-scrolled");

});
$(window).scroll(function(){
    offset = $(this).scrollTop();
    if (offset > 100) {
        $("body:not(.scrolled)").addClass("scrolled");
        $("body.scrolled)").removeClass("not-scrolled");
   } else {
       $("body.scrolled").removeClass("scrolled");
       $("body:not(.scrolled)").addClass("not-scrolled");
   }
});
</script>



  <script type="text/javascript">
  var map;
  var mapZoom = 6;
  var center;
  var newCenter;
//Define the overlay, derived from google.maps.OverlayView
  function Label(opt_options) {
   // Initialization
   this.setValues(opt_options);

   // Label specific
   var span = this.span_ = document.createElement('span');
   span.style.cssText = 'font-weight: bold;' +
                        'white-space: nowrap; ' +
                        'padding: 2px; z-index: 999 !important;';
   span.style.zIndex=999;

   var div = this.div_ = document.createElement('div');
   div.style.zIndex=999;

   div.appendChild(span);
   div.style.cssText = 'position: absolute; display: none;z-index: 999 !important;';
  };
  Label.prototype = new google.maps.OverlayView;

  // Implement onAdd
  Label.prototype.onAdd = function() {
   var pane = this.getPanes().overlayLayer;
   pane.appendChild(this.div_);

   // Ensures the label is redrawn if the text or position is changed.
   var me = this;
   this.listeners_ = [
     google.maps.event.addListener(this, 'position_changed',
         function() { me.draw(); }),
     google.maps.event.addListener(this, 'text_changed',
         function() { me.draw(); })
   ];
  };

  // Implement onRemove
  Label.prototype.onRemove = function() {
   this.div_.parentNode.removeChild(this.div_);

   // Label is removed from the map, stop updating its position/text.
   for (var i = 0, I = this.listeners_.length; i < I; ++i) {
     google.maps.event.removeListener(this.listeners_[i]);
   }
  };


  // Implement draw
  Label.prototype.draw = function() {
   var projection = this.getProjection();
   var position = projection.fromLatLngToDivPixel(this.get('position'));

   var div = this.div_;
   div.style.left = position.x + 'px';
   div.style.top = position.y + 'px';
   div.style.display = 'block';
   div.style.zIndex=999;

   this.span_.innerHTML = this.get('text').toString();
  };


  		//map
  		//var map;
  	  var bounds = new google.maps.LatLngBounds();

      function initialize() {

    	// Create an array of styles for our Google Map.
  	    //var gmap_styles = [{"stylers":[{"visibility":"off"}]},{"featureType":"water","stylers":[{"visibility":"on"},{"color":"#00c0f7"}]},{"featureType":"landscape","stylers":[{"visibility":"on"},{"color":"#005589"}]},{"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"visibility":"on"},{"color":"#00c0f7"},{"weight":1}]}]

    	//dummy array to feed into styled map input. Just here so I don't have to alter the styling code ic case they need all/some of it back later.
    	var blankStyles = [];

    	if($("#map_canvas").hasClass("full_screen_map")){mapZoom=3;}

    	if (center == null) {
	    	center = new google.maps.LatLng(32.6104351,-117.3712712);
    	} else {
    		center = map.getCenter();
    	}

        map = new google.maps.Map(document.getElementById('map_canvas'), {
          zoom: mapZoom,
          center: center,
          mapTypeId: google.maps.MapTypeId.HYBRID,
          zoomControl: true,
          scaleControl: false,
          scrollwheel: false,
          disableDoubleClickZoom: false,
        });

    	  //adding the fullscreen control to exit fullscreen
    	  var fsControlDiv = document.createElement('DIV');
    	  var fsControl = new FSControl(fsControlDiv, map);
    	  fsControlDiv.index = 1;
    	  map.controls[google.maps.ControlPosition.TOP_RIGHT].push(fsControlDiv);


    	    // !!! Whack All the styling and hardcode satellite type map.  !!!

    	    //map.setMapTypeId('satellite');

        var markers = [];
 	    var movePathCoordinates = [];

 	    //iterate here to add points per location ID

 		var maxZoomService = new google.maps.MaxZoomService();
 		maxZoomService.getMaxZoomAtLatLng(map.getCenter(), function(response) {
 			    if (response.status == google.maps.MaxZoomStatus.OK) {
 			    	if(response.zoom < map.getZoom()){
 			    		map.setZoom(response.zoom);
 			    	}
 			    }

 		});



 		// let's add map points for our locationIDs
 		<%
 		List<String> locs=CommonConfiguration.getIndexedPropertyValues("locationID", context);
 		int numLocationIDs = locs.size();
 		Properties locProps=ShepherdProperties.getProperties("locationIDGPS.properties", "", context);
 		myShepherd.beginDBTransaction();

 		try{
	 		for(int i=0;i<numLocationIDs;i++){

	 			String locID = locs.get(i);
	 			if((locProps.getProperty(locID)!=null)&&(locProps.getProperty(locID).indexOf(",")!=-1)){

	 				StringTokenizer st = new StringTokenizer(locProps.getProperty(locID), ",");
	 				String lat = st.nextToken();
	 				String longit=st.nextToken();
	 				String thisLatLong=lat+","+longit;

	 		        //now  let's calculate how many
	 		        int numSightings=myShepherd.getNumEncounters(locID);
	 		        if(numSightings>0){

	 		        	Integer numSightingsInteger=new Integer(numSightings);


	 		          %>

	 		         var latLng<%=i%> = new google.maps.LatLng(<%=thisLatLong%>);
			          bounds.extend(latLng<%=i%>);

	 		          var divString<%=i%> = "<div style=\"font-weight:bold;margin-top: 5px; text-align: center;line-height: 45px;vertical-align: middle;width:60px;height:60px;padding: 2px; background-image: url('cust/mantamatcher/img/bass/gsb_map_marker_square_outline.png');background-size: cover\"><%=numSightingsInteger.toString() %></div>";


	 		         var marker<%=i%> = new RichMarker({
	 		            position: latLng<%=i%>,
	 		            map: map,
	 		            draggable: false,
	 		            content: divString<%=i%>,
	 		            flat: true,
				    anchor: RichMarkerPosition.MIDDLE
	 		        });



	 			      markers.push(marker<%=i%>);
	 		          map.fitBounds(bounds);

	 				<%
	 			} //end if

	 			}  //end if

	 		}  //end for
 		}
 		catch(Exception e){
 			e.printStackTrace();
 		}
 		finally{
 			myShepherd.rollbackDBTransaction();
 		}
 	 	%>

    	 google.maps.event.addListener(map, 'dragend', function() {
    		var idleListener = google.maps.event.addListener(map, 'idle', function() {
    			google.maps.event.removeListener(idleListener);
    			console.log("GetCenter : "+map.getCenter());
    			mapZoom = map.getZoom();
    			newCenter = map.getCenter();
    			center = newCenter;
    			map.setCenter(map.getCenter());
    		});

 	     });

    	 google.maps.event.addDomListener(window, "resize", function() {
 	    	console.log("Resize Center : "+center);
 	    	google.maps.event.trigger(map, "resize");
 	  	    console.log("Resize : "+newCenter);
 	  	    map.setCenter(center);
 	     });

 	 } // end initialize function






      function fullScreen(){
  		$("#map_canvas").addClass('full_screen_map');
  		$('html, body').animate({scrollTop:0}, 'slow');
  		initialize();

  		//hide header
  		$("#header_menu").hide();

  		if(overlaysSet){overlaysSet=false;setOverlays();}
  		//alert("Trying to execute fullscreen!");
  	}


  	function exitFullScreen() {
  		$("#header_menu").show();
  		$("#map_canvas").removeClass('full_screen_map');

  		initialize();
  		if(overlaysSet){overlaysSet=false;setOverlays();}
  		//alert("Trying to execute exitFullScreen!");
  	}




  	//making the exit fullscreen button
  	function FSControl(controlDiv, map) {

  	  // Set CSS styles for the DIV containing the control
  	  // Setting padding to 5 px will offset the control
  	  // from the edge of the map
  	  controlDiv.style.padding = '5px';

  	  // Set CSS for the control border
  	  var controlUI = document.createElement('DIV');
  	  controlUI.style.backgroundColor = '#f8f8f8';
  	  controlUI.style.borderStyle = 'solid';
  	  controlUI.style.borderWidth = '1px';
  	  controlUI.style.borderColor = '#a9bbdf';;
  	  controlUI.style.boxShadow = '0 1px 3px rgba(0,0,0,0.5)';
  	  controlUI.style.cursor = 'pointer';
  	  controlUI.style.textAlign = 'center';
  	  controlUI.title = 'Toggle the fullscreen mode';
  	  //controlDiv.appendChild(controlUI);

  	  // Set CSS for the control interior
  	  var controlText = document.createElement('DIV');
  	  controlText.style.fontSize = '12px';
  	  controlText.style.fontWeight = 'bold';
  	  controlText.style.color = '#000000';
  	  controlText.style.paddingLeft = '4px';
  	  controlText.style.paddingRight = '4px';
  	  controlText.style.paddingTop = '3px';
  	  controlText.style.paddingBottom = '2px';
  	  controlUI.appendChild(controlText);
  	  controlText.style.visibility='hidden';
  	  //toggle the text of the button

  	  if($("#map_canvas").hasClass("full_screen_map")){
  	      controlText.innerHTML = 'Exit Fullscreen';
  	  } else {
  	      controlText.innerHTML = 'Fullscreen';
  	  }
 	  google.maps.event.addDomListener(controlUI, 'click', function() {
 	 	if($("#map_canvas").hasClass("full_screen_map")){
 	  	  exitFullScreen();
 	  	} else {
 	  	  fullScreen();
 	  	}
 	  });

  	  // Setup the click event listeners: toggle the full screen
  	}
    google.maps.event.addDomListener(window, 'load', initialize);



  </script>

<%



//let's quickly get the data we need from Shepherd
int numMarkedIndividuals=0;
int numIndyLeftID = 0;
int numIndyRightID = 0;
int numEncLeftID = 0;
int numEncRightID = 0;

int numEncounters=0;
int numDataContributors=0;

int numCitScientists=0;

int numUsersWithRoles=0;
int numUsers=0;
myShepherd.beginDBTransaction();
QueryCache qc=QueryCacheFactory.getQueryCache(context);

//String url = "login.jsp";
//response.sendRedirect(url);
//RequestDispatcher dispatcher = getServletContext().getRequestDispatcher(url);
//dispatcher.forward(request, response);


try{


    //numMarkedIndividuals=myShepherd.getNumMarkedIndividuals();
    numMarkedIndividuals=qc.getQueryByName("numMarkedIndividuals").executeCountQuery(myShepherd).intValue();
    numEncounters=myShepherd.getNumEncounters();
    //numEncounters=qc.getQueryByName("numEncounters").executeCountQuery(myShepherd).intValue();
    //numDataContributors=myShepherd.getAllUsernamesWithRoles().size();
    numDataContributors=qc.getQueryByName("numUsersWithRoles").executeCountQuery(myShepherd).intValue();
    numUsers=qc.getQueryByName("numUsers").executeCountQuery(myShepherd).intValue();
    numUsersWithRoles = numUsers-numDataContributors;

	Iterator<Encounter> encs = myShepherd.getAllEncountersNoQuery();
	while (encs.hasNext()) {
		Encounter enc = encs.next();
		if (enc.getSpots()!=null&&!enc.getSpots().isEmpty()) {
			numEncLeftID++;
			if (enc.getIndividualID()!=null) {
				numIndyLeftID++;
			}
		}
		if (enc.getRightSpots()!=null&&!enc.getRightSpots().isEmpty()) {
			numEncRightID++;
			if (enc.getIndividualID()!=null) {
				numIndyRightID++;
			}
		}
	}
    numDataContributors=myShepherd.getAllUsers().size();
    //This should get the number of unique emails from encounter submissions for a ROUGH estimate of contributing individuals.
	numCitScientists=myShepherd.getUsersWithEmailAddresses().size();

} catch (Exception e){
	System.out.println("################# Exception retrieving numbers for index.jsp counters.");
    e.printStackTrace();
    System.out.println("INFO: *** If you are seeing an exception here (via index.jsp) your likely need to setup QueryCache");
    System.out.println("      *** This entails configuring a directory via cache.properties and running appadmin/testQueryCache.jsp");
} finally {
   myShepherd.rollbackDBTransaction();
}
%>

<style>




#fullScreenDiv{
    width:100%;
   /* Set the height to match that of the viewport. */

    width: auto;
    padding:0!important;
    margin: 0!important;
    position: relative;
}
#video{
    width: 100vw;
    height: auto;
    object-fit: cover;
    left: 0px;
    top: 0px;
    z-index: -1;
}

h2.vidcap {
	font-size: 2.4em;

	color: #fff;
	font-weight:300;
	text-shadow: 1px 2px 2px #333;
	margin-top: 35%;
}



/* The container for our text and stuff */
#messageBox{
    position: absolute;  top: 0;  left: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height:100%;
}

@media screen and (min-width: 851px) {
	h2.vidcap {
	    font-size: 3.3em;
	    margin-top: -45%;
	}
}

@media screen and (max-width: 850px) and (min-width: 551px) {


	#fullScreenDiv{
	    width:100%;
	   /* Set the height to match that of the viewport. */

	    width: auto;
	    padding-top:50px!important;
	    margin: 0!important;
	    position: relative;
	}

	h2.vidcap {
	    font-size: 2.4em;
	    margin-top: 55%;
	}

}
@media screen and (max-width: 550px) {


	#fullScreenDiv{
	    width:100%;
	   /* Set the height to match that of the viewport. */

	    width: auto;
	    padding-top:150px!important;
	    margin: 0!important;
	    position: relative;
	}

	h2.vidcap {
	    font-size: 1.8em;
	    margin-top: 100%;
	}

}


</style>
<section class="hero container-fluid main-section relative">
    <div class="container relative">
        <div class="col-xs-12 col-sm-10 col-md-8 col-lg-6">
            <h1 class="hidden">Wildbook</h1>

            <!-- Main Splash "Wildbook helps you identify..." -->
            <h2><%=props.getProperty("mainSplash") %></h2>
            <!--
            <button id="watch-movie" class="large light">
				Watch the movie
				<span class="button-icon" aria-hidden="true">
			</button>
			-->
            <a href="submit.jsp">
                <button class="large"><%= props.getProperty("reportEncounter") %><span class="button-icon" aria-hidden="true"></button>
            </a>
        </div>

	</div>
	<div id="image-credit">
		<p id="credit-text"><i style="color:white;"><%= props.getProperty("heroImageCredit") %></i></p>
	</div>


</section>

<section class="container text-center main-section">

	<h2 class="section-header"><%=props.getProperty("howItWorksH") %></h2>

  <!-- All carousel text can be modified in the index properties files -->

	<div id="howtocarousel" class="carousel slide" data-ride="carousel" data-interval="15000">
		<ol class="list-inline carousel-indicators slide-nav">
	        <li data-target="#howtocarousel" data-slide-to="0" class="active">1. <%=props.getProperty("carouselPhoto") %><span class="caret"></span></li>
	        <li data-target="#howtocarousel" data-slide-to="1" class="">2. <%=props.getProperty("carouselSubmit") %><span class="caret"></span></li>
	        <li data-target="#howtocarousel" data-slide-to="2" class="">3. <%=props.getProperty("carouselVerify") %><span class="caret"></span></li>
	        <li data-target="#howtocarousel" data-slide-to="3" class="">4. <%=props.getProperty("carouselMatching") %><span class="caret"></span></li>
	        <li data-target="#howtocarousel" data-slide-to="4" class="">5. <%=props.getProperty("carouselResult") %><span class="caret"></span></li>
	    </ol>
		<div class="carousel-inner text-left">
			<div class="item active">
				<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
					<h3><%=props.getProperty("innerPhotoH3") %></h3>
					<p class="lead">
						<%=props.getProperty("innerPhotoP") %>
						<br>
						<a href="photographing.jsp" title=""><%=props.getProperty("howItWorks-step1-link")%></a>
					</p>
				</div>
				<div class="col-xs-12 col-sm-4 col-sm-offset-2 col-md-4 col-md-offset-2 col-lg-4 col-lg-offset-2">
					<img class="pull-right" src="cust/mantamatcher/img/bass/how_it_works_photograph_gsb.png" alt=""  />
				</div>
			</div>
			<div class="item">
				<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
          <h3><%=props.getProperty("innerSubmitH3") %></h3>
          <p class="lead">
            <%=props.getProperty("innerSubmitP") %>
          </p>
				</div>
				<div class="col-xs-12 col-sm-4 col-sm-offset-2 col-md-4 col-md-offset-2 col-lg-4 col-lg-offset-2">
					<img class="pull-right" src="images/how_it_works_submit.jpg" alt=""  />
				</div>
			</div>
			<div class="item">
				<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
          <h3><%=props.getProperty("innerVerifyH3") %></h3>
          <p class="lead">
            <%=props.getProperty("innerVerifyP") %>
          </p>
				</div>
				<div class="col-xs-12 col-sm-4 col-sm-offset-2 col-md-4 col-md-offset-2 col-lg-4 col-lg-offset-2">
					<img class="pull-right" src="cust/mantamatcher/img/bass/how_it_works_researcher_verification.png" alt="researcher verfiying submission of giant sea bass encounter"  />
				</div>
			</div>
			<div class="item">
				<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
          <h3><%=props.getProperty("innerMatchingH3") %></h3>
          <p class="lead">
            <%=props.getProperty("innerMatchingP") %>
          </p>
				</div>
				<div class="col-xs-12 col-sm-4 col-sm-offset-2 col-md-4 col-md-offset-2 col-lg-4 col-lg-offset-2">
					<img class="pull-right" src="cust/mantamatcher/img/bass/how_it_works_matching_process.png" alt=""  />
				</div>
			</div>
			<div class="item">
				<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
          <h3><%=props.getProperty("innerResultH3") %></h3>
          <p class="lead">
            <%=props.getProperty("innerResultP") %>
          </p>
				</div>
				<div class="col-xs-12 col-sm-4 col-sm-offset-2 col-md-4 col-md-offset-2 col-lg-4 col-lg-offset-2">
					<img class="pull-right" src="cust/mantamatcher/img/bass/how_it_works_match_result.png" alt=""  />
				</div>
			</div>
		</div>
	</div>
</section>

<div class="container-fluid relative data-section">

    <aside class="container main-section">
        <div class="row">

            <!-- Random user profile to select -->
            <%
            //myShepherd.beginDBTransaction();
            try{
								User featuredUser=myShepherd.getRandomUserWithPhotoAndStatement();
            if(featuredUser!=null){
                String profilePhotoURL="images/user-profile-white-transparent.png";
                if(featuredUser.getUserImage()!=null){
                	profilePhotoURL="/"+CommonConfiguration.getDataDirectoryName(context)+"/users/"+featuredUser.getUsername()+"/"+featuredUser.getUserImage().getFilename();
                }

            %>
                <section class="col-xs-12 col-sm-6 col-md-4 col-lg-4 padding focusbox">
                    <div class="focusbox-inner opec">
                        <h2><%=props.getProperty("ourContributors") %></h2>
                        <div>
                            <img src="cust/mantamatcher/img/individual_placeholder_image.jpg" data-src="<%=profilePhotoURL %>" width="80px" height="*" alt="" class="pull-left lazyload" />
                            <p><%=featuredUser.getFullName() %>
                                <%
                                if(featuredUser.getAffiliation()!=null){
                                %>
                                <i><%=featuredUser.getAffiliation() %></i>
                                <%
                                }
                                %>
                            </p>
                            <p><%=featuredUser.getUserStatement() %></p>
                        </div>
                        <a href="whoAreWe.jsp" title="" class="cta"><%=props.getProperty("showContributors") %></a>
                    </div>
                </section>
            <%
            } // end if

            }
            catch(Exception e){e.printStackTrace();}
            finally{

            	//myShepherd.rollbackDBTransaction();
            }
            %>

			<section class="col-xs-12 col-sm-3 col-md-3 col-lg-3 padding focusbox">
			</section>
            <section class="col-xs-12 col-sm-6 col-md-6 col-lg-6 padding focusbox">
                <div class="focusbox-inner opec">
                    <h2><%=props.getProperty("latestAnimalEncounters") %></h2>
                    <ul class="encounter-list list-unstyled">

                       <%
                       List<Encounter> latestIndividuals=myShepherd.getMostRecentIdentifiedEncountersByDate(3);
                       int numResults=latestIndividuals.size();
                       try{
						   myShepherd.beginDBTransaction();
	                       for(int i=0;i<numResults;i++){
	                           Encounter thisEnc=latestIndividuals.get(i);
	                           %>
	                            <li>
	                                <img src="cust/mantamatcher/img/bass/gsb_sil.png" alt="" width="80px" height="38px" class="pull-left" />
	                                <small>
	                                    <time>
	                                        <%=thisEnc.getDate() %>
	                                        <%
	                                        if((thisEnc.getLocationID()!=null)&&(!thisEnc.getLocationID().trim().equals(""))){
	                                        %>/ <%=thisEnc.getLocationID() %>
	                                        <%
	                                           }
	                                        %>
	                                    </time>
	                                </small>
	                                <p><a href="encounters/encounter.jsp?number=<%=thisEnc.getCatalogNumber() %>" title=""><%=thisEnc.getDisplayName() %></a></p>


	                            </li>
	                        <%
	                        }
						} catch (Exception e){
							e.printStackTrace();
							//myShepherd.closeDBTransaction();
						} finally{
                    	   myShepherd.rollbackDBTransaction();
						   //myShepherd.closeDBTransaction();
                       }

                        %>

                    </ul>
                    <!-- <a href="encounters/searchResults.jsp?state=approved" title="" class="cta"><%=props.getProperty("seeMoreEncs") %></a> -->
                </div>
            </section>
            <!-- begin spotter switch -->
            <%
            boolean topSpotterSwitch = false;
            if (topSpotterSwitch == true) {
            %>
            <section class="col-xs-12 col-sm-6 col-md-4 col-lg-4 padding focusbox">


                <div class="focusbox-inner opec">
                    <h2><%=props.getProperty("topSpotters")%></h2>
                    <ul class="encounter-list list-unstyled">
                    <%
                    try{
						myShepherd.beginDBTransaction();
	                    //System.out.println("Date in millis is:"+(new org.joda.time.DateTime()).getMillis());
                            long startTime = System.currentTimeMillis() - Long.valueOf(1000L*60L*60L*24L*30L);

	                    System.out.println("  I think my startTime is: "+startTime);

	                    Map<String,Integer> spotters = myShepherd.getTopUsersSubmittingEncountersSinceTimeInDescendingOrder(startTime);
	                    int numUsersToDisplay=3;
	                    if(spotters.size()<numUsersToDisplay){numUsersToDisplay=spotters.size();}
	                    Iterator<String> keys=spotters.keySet().iterator();
	                    Iterator<Integer> values=spotters.values().iterator();
	                    while((keys.hasNext())&&(numUsersToDisplay>0)){
	                          String spotter=keys.next();
	                          int numUserEncs=values.next().intValue();
	                          if(!spotter.equals("siowamteam") && !spotter.equals("admin") && !spotter.equals("tomcat") && myShepherd.getUser(spotter)!=null){
	                        	  String profilePhotoURL="images/user-profile-white-transparent.png";
	                              User thisUser=myShepherd.getUser(spotter);
	                              if(thisUser.getUserImage()!=null){
	                              	profilePhotoURL="/"+CommonConfiguration.getDataDirectoryName(context)+"/users/"+thisUser.getUsername()+"/"+thisUser.getUserImage().getFilename();
	                              }
	                              //System.out.println(spotters.values().toString());
	                            Integer myInt=spotters.get(spotter);
	                            //System.out.println(spotters);

	                          %>
	                                <li>
	                                    <img src="cust/mantamatcher/img/individual_placeholder_image.jpg" data-src="<%=profilePhotoURL %>" width="80px" height="*" alt="" class="pull-left lazyload" />
	                                    <%
	                                    if(thisUser.getAffiliation()!=null){
	                                    %>
	                                    <small><%=thisUser.getAffiliation() %></small>
	                                    <%
	                                      }
	                                    %>
	                                    <p><a href="#" title=""><%=spotter %></a>, <span><%=numUserEncs %> <%=props.getProperty("encounters") %><span></p>
	                                </li>

	                           <%
	                           numUsersToDisplay--;
	                    }
	                   } //end while
                    } catch (Exception e){
						e.printStackTrace();
						//myShepherd.closeDBTransaction();
					} finally{
						myShepherd.rollbackDBTransaction();
						//myShepherd.closeDBTransaction();
					}

                   %>
                    </ul>
                    <a href="whoAreWe.jsp" title="" class="cta"><%=props.getProperty("allSpotters") %></a>
                </div>

            </section>
            <!-- end spotter switch -->
            <%}%>
        </div>
    </aside>
</div>

<div class="container-fluid">
    <section class="container text-center  main-section">
        <div class="row">

			<!-- add left and right side ID for encounters and Individuals - GSB branch -->

			<section class="col-xs-12 col-sm-4 col-md-4 col-lg-4 padding">
                <p class="indyCounter brand-primary"><i><span class="numSpotted"><%=numIndyLeftID%></span>&nbsp;&nbsp;<%=props.getProperty("leftIDIndNum") %></i></p>
                <p class="indyCounter brand-primary"><i><span class="numSpotted"><%=numIndyRightID%></span>&nbsp;&nbsp;<%=props.getProperty("rightIDIndNum") %></i></p>
            </section>

            <section class="col-xs-12 col-sm-4 col-md-4 col-lg-4 padding">
                <p class="brand-primary"><i><span class="massive"><%=numEncounters %></span> <%=props.getProperty("reportedEncs") %></i></p>
            </section>

			<section class="col-xs-12 col-sm-4 col-md-4 col-lg-4 padding">
				<p class="brand-primary"><i><span class="massive"><%=numCitScientists%></span> <%=props.getProperty("citScientists") %></i></p>
			</section>

			<section class="col-xs-12 col-sm-12 col-md-12 col-lg-12 counterSummary">
				<p class="brand-primary"><i><%=props.getProperty("counterSummary")%></i></p>
			</section>

        </div>

        <hr/>

        <main class="container">
            <article class="text-center">
                <div class="row">
                	<div class="pull-left col-xs-7 col-sm-4 col-md-4 col-lg-4 col-xs-offset-2 col-sm-offset-1 col-md-offset-1 col-lg-offset-1">
	                    <img src="cust/mantamatcher/img/bass/Ian_Uhalt.jpg" alt="" />
	          			<label class="image_label"><%=props.getProperty("quoteImageCaption") %></label>
                	</div>
                    <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6 text-left">
                        <h1><%=props.getProperty("whyWeDoThis") %></h1>
                        <p class="lead"><%=props.getProperty("inspiredQuote") %></p>
                        <a href="overview.jsp" title=""><%=props.getProperty("knowMore") %></a>
                    </div>
                </div>
            </article>
        <main>

    </section>
</div>

<div class="container main-section">
	<h2 class="section-header"><%= props.getProperty("gMapHeader") %></h2>
	<p class="gMapNote"><small><%= props.getProperty("gMapNote") %></small></p>

      <div id="map_canvas" style="width: 100% !important; height: 510px;"></div>
      
      </div>
      
      <div class="container main-section">
      
      
      <div class="row">
                    <div class="col-xs-3 col-sm-3 col-md-3" style="margin-top:10px;">
                      <a target="_blank" href="http://www.boi.ucsb.edu">
	                      <img class="img-responsive" alt="boi logo" src="//spottinggiantseabass.msi.ucsb.edu/cust/mantamatcher/img/bass/boi_logo.svg">
                      </a>
                    </div>
                    <div class="col-xs-2 col-sm-2 col-md-2" style="margin-top:10px;">
                      <a target="_blank" href="http://lovelab.msi.ucsb.edu/">
                        <img class="img-responsive" alt="love lab logo" src="//spottinggiantseabass.msi.ucsb.edu/cust/mantamatcher/img/bass/love_lab_logo-little.png">
                      </a>
                    </div>
                    <div class="col-xs-2 col-sm-2 col-md-2" style="margin-top:10px;">
                  	  <a target="_blank" href="http://www.aquariumofpacific.org/">
                        <img class="img-responsive" alt="aop logo" src="//spottinggiantseabass.msi.ucsb.edu/cust/mantamatcher/img/bass/Aop_logo.svg">
                      </a>
                    </div>
                  	<div class="col-xs-2 col-sm-2 col-md-2" style="margin-top:10px;">
                  	  <a target="_blank" href="http://msi.ucsb.edu/">
                        <img class="img-responsive" alt="msi logo" src="//spottinggiantseabass.msi.ucsb.edu/cust/mantamatcher/img/bass/msi_logo_centered.png">
                      </a>
                    </div>
                    <div class="col-xs-3 col-sm-3 col-md-3" style="margin-top:10px;">
											<a href="https://www.wildme.org/" class="col-sm-4" title="This site is Powered by Wildbook" style="width: 77.333333%">
	                      <img src="//spottinggiantseabass.msi.ucsb.edu/images/WildMe-Logo-04.png" alt=" logo" class="pull-right" style="height: auto; width: 180px">
	                    </a>
                    </div>
                 </div>

</div>



<jsp:include page="footer.jsp" flush="true"/>


<%
myShepherd.rollbackDBTransaction();
myShepherd.closeDBTransaction();
myShepherd=null;
%>
