ef<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page contentType="text/html; charset=utf-8" language="java" import="org.joda.time.LocalDateTime,
org.joda.time.format.DateTimeFormatter,
org.joda.time.format.ISODateTimeFormat,java.net.*,
org.ecocean.grid.*,org.ecocean.media.*,org.ecocean.Util,
java.io.*,java.util.*, java.io.FileInputStream, java.io.File, java.io.FileNotFoundException, org.datanucleus.api.rest.orgjson.JSONObject, org.ecocean.*,org.ecocean.servlet.*,javax.jdo.*, java.lang.StringBuffer, java.util.Vector, java.util.Iterator, java.lang.NumberFormatException"%>


<%!

public static String standardizedEncounterSex(Encounter enc) {

  if (enc.getSex() == null) return null;

  String sex = enc.getSex().trim().toLowerCase();

  if (sex.equals("") || sex.equals(" ") || sex.trim() == "") {
    return null;
  }
  else if (sex.equals("indeterminado") || sex.equals("?") || sex.equals("unknown") || sex.equals("¿?")) {
    return "unknown";
  }
  else if (sex.equals("hembra") || sex.equals("h")) {
    return "female";
  }
  else if (sex.equals("macho") || sex.equals("m")) {
    return "male";
  }
  else if (sex.contains("macho?")) {
    return "male?";
  }
  else if (sex.contains("hembra?")) {
    return "female?";
  }
  else {
    return "parse error!";
  }

}

%>

<%

String context="context0";
context=ServletUtilities.getContext(request);

Shepherd myShepherd=new Shepherd(context);



%>

<html>
<head>
<title>Fix Some Fields</title>

</head>


<body>
<h1>Modifying encounters</h1>

<ul>
<%


myShepherd.beginDBTransaction();

List<String> badEncIDs = new ArrayList<String>();
List<String> badSexStrings = new ArrayList<String>();

int numFixes=0;
int numAnnots=0;
boolean committing=true;

int numHuntingStateFixes = 0;
int numTrappingStationFixes = 0;

int numMas = 0;
int maxMas = 0;
String bestEncID = "none";


%><h3>committing = <%=committing%></h3><%


try {

	String rootDir = getServletContext().getRealPath("/");
	String baseDir = ServletUtilities.dataDir(context, rootDir).replaceAll("dev_data_dir", "caribwhale_data_dir");

	Iterator allEncs=myShepherd.getAllEncountersNoQuery();

  int count = 0;
  int maxCount = 100;


	while(allEncs.hasNext()){

    count++;

		Encounter enc = (Encounter) allEncs.next();


		// try to get newHuntState 2 diff ways
		String newHuntState=enc.getLocation(); // this appears as "description" on an encounter's page
		if (!Util.stringExists(newHuntState)) newHuntState = enc.getCountry();
		if (Util.stringExists(newHuntState)) {
			String oldHuntState=enc.getHuntingState();
			String oldLocation = enc.getLocation();
			String oldCountry = enc.getCountry();
			enc.setHuntingState(newHuntState);
			enc.setLocation(null);
			enc.setCountry(null); // these previously duplicated the huntingState values
			boolean huntChanged = !Util.stringsEqual(oldHuntState, enc.getHuntingState());
			boolean locaChanged = !Util.stringsEqual(oldLocation,  enc.getLocation());
			boolean counChanged = !Util.stringsEqual(oldCountry, enc.getCountry());
			if (huntChanged || locaChanged || counChanged) numHuntingStatesFixed++;
		}

		String newTrappingStation = enc.getLocationID();

    numFixes++;
    if (committing) {
      myShepherd.commitDBTransaction();
      myShepherd.beginDBTransaction();
    }
    %></ul><%

	}

  //Iterator allAnns=myShepherd.getAllAnnotationsNoQuery();
/*
  while(allAnns.hasNext()){

    Annotation ann = (Annotation) allAnns.next();
    numAnnots++;
    if (committing) {
      myShepherd.commitDBTransaction();
      myShepherd.beginDBTransaction();
    }

  }
*/
}
catch(Exception e){
	myShepherd.rollbackDBTransaction();
}
finally{
	myShepherd.closeDBTransaction();

}

%>

</ul>
<p>Num Encounters: <%=numFixes %></p>
<p>Num MediaAssets: <%=numMas%></p>
<p>Best encounter = <%=bestEncID%> with <%=maxMas%> mas. <ul>
</ul></p>

</body>
</html>
