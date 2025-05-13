<%@ page contentType="text/html; charset=utf-8" language="java"
         import="org.ecocean.CommonConfiguration,java.util.Properties, org.ecocean.servlet.ServletUtilities" %>
<%

  //setup our Properties object to hold all properties

  String langCode = ServletUtilities.getLanguageCode(request);

  //set up the file input stream
  //FileInputStream propsInputStream=new FileInputStream(new File((new File(".")).getCanonicalPath()+"/webapps/ROOT/WEB-INF/classes/bundles/"+langCode+"/submit.properties"));
  //props.load(propsInputStream);

  String context=ServletUtilities.getContext(request);

%>
<jsp:include page="header.jsp" flush="true"/>
<div class="container maincontent">


<h2 class="intro">Contact us </h2>

<p><strong>For more information, contact us:</strong></p>

<p><a href="mailto: info@tech4conservation.org">info@tech4conservation.org</a></p>


<h3>Wild Me</h3>

<p><a href="https://www.wildme.org/"><img src="images/WildMe-Logo-04.png" width="200px" height="*" /></a></p>

<h3>Wildbook</h3>

<p><a href="https://www.wildbook.org/"><img src="images/WildBook_logo_300dpi-04.png" width="200px" height="*" /></a></p>


<!-- end maintext -->
</div>
