package org.ecocean;


import java.util.List;
import java.util.ArrayList;

import java.io.IOException;

import org.ecocean.datacollection.*;
import org.ecocean.Util;

public class Nest implements java.io.Serializable {
  private static final long serialVersionUID = 1L;

  private String id;
  private String name;
  private List<DataSheet> dataSheets = new ArrayList<DataSheet>();

  private String locationID;
  private String locationNote;
  private Double latitude;
  private Double longitude;

  private Integer year;
  private String species;
  private String country;
  private String province;
  private String organization;
  private String beachName;



  //private User owner;
  //private List<User> contributors;

  /**
   * empty constructor required by the JDO Enhancer 
   */
  public Nest() {
  }

  public Nest(String id) {
    this.dataSheets = new ArrayList<DataSheet>();
    this.id = id;
  }

  public Nest(DataSheet sheet) {
    try {
      this.dataSheets = new ArrayList<DataSheet>();
    } catch (Exception e) {
      e.printStackTrace();
    }
    this.id = Util.generateUUID();
    this.record(sheet);
    System.out.println("===============================>   Recorded sheet!!");
  }

  public String getID() {
    return id;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  /*
  public User getOwner() {
    return owner;
  }

  public void setOwner(User owner) {
    this.owner = owner;
  }

  public List<User> getContributors() {
    return contributors;
  }

  public void addContributor(User contributor) {
    if (this.contributors == null) this.contributors = new ArrayList<User>();
    this.contributors.add(contributor);
  }

  public void removeContributor(User contributor) {
    this.contributors.remove(contributor);
  }
  */



  // the goal here is to offer a quick hook to a "null nest",
  // that is a nest that has a datasheet with fields but no values.
  public static Nest nestWithConfigDataSheet(String context) throws IOException {
    return new Nest(DataSheet.fromCommonConfig("nest", context));
  }

  public void record(DataSheet datasheet) {
    try {
      this.dataSheets.add(datasheet);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public void addConfigDataSheet(String context) throws IOException {
    this.record(DataSheet.fromCommonConfig("nest", context));
  }

  public void addConfigDataSheet(String context, String subname) throws IOException {
    //DataSheet sheetie = DataSheet.fromCommonConfig("nest", context);
    DataSheet sheetie = DataSheet.fromCommonConfig(subname, context);
    sheetie.setName(subname);
    System.out.println();
    System.out.println("Just made a named config data sheet, "+sheetie.getName());
    this.record(sheetie);
  }



  public List<DataSheet> getDataSheets() {
    if (this.dataSheets==null) {
      System.out.println("Sheets null in getDataSheets()!");
      this.dataSheets = new ArrayList<DataSheet>();
    }
    return this.dataSheets;
  }

  public DataSheet getDataSheet(int i) {
    return dataSheets.get(i);
  }

  public boolean remove(DataSheet datasheet) {
    return this.dataSheets.remove(datasheet);
  }

  public void remove(int i) {
    this.dataSheets.remove(i);
  }

  public int countSheets() {
    int num = 0;
    System.out.println("A. Is null in countSheets()??? "+this.dataSheets);
    //System.out.println("Is THIS null??? "+this.dataSheets);
    //System.out.println("AS A STRING! "+dataSheets.toString());
    try {
      num = getDataSheets().size();
    } catch (Exception e) {
      e.printStackTrace();
    }
    return num;
  }

  public void setLocationID(String locationID) {
    this.locationID = locationID;
  }
  public String getLocationID() {
    return locationID;
  }

  public void setLocationNote(String locationNote) {
    this.locationNote = locationNote;
  }
  public String getLocationNote() {
    return locationNote;
  }

  public void setLatitude(Double latitude) {
    this.latitude = latitude;
  }
  public Double getLatitude() {
    return latitude;
  }

  public void setLongitude(Double longitude) {
    this.longitude = longitude;
  }
  public Double getLongitude() {
    return longitude;
  }

  public void setYear(Integer year) {
    this.year = year;
  }
  public Integer getYear() {
    return year;
  }

  public void setSpecies(String species) {
    this.species = species;
  }

  public String getSpecies() {
    return species;
  }
  public void setCountry(String country) {
    this.country = country;
  }
  public String getCountry() {
    return country;
  }


 public String getProvince() {
   return province;
 }
 public void setProvince(String province) {
   this.province = province;
 }
 public String getOrganization() {
   return organization;
 }
 public void setOrganization(String organization) {
   this.organization = organization;
 }
 public String getBeachName() {
   return beachName;
 }
 public void setBeachName(String beachName) {
   this.beachName = beachName;
 }





// following functions are largely on DataSheets,
  // but live in this class because they only make
  // sense in the nest context

  // eggs: on some datasheets, researchers will want to record info
  // about N eggs. This is stored by reserving the end of the datapoint
  // array for only egg measurements
  public int getEggCount(int sheetNo) {
    DataSheet ds = getDataSheet(sheetNo);
    if (ds.size()>0) {
      DataPoint lastDP = ds.get(ds.size()-1);
      String lastName = lastDP.getNumberedName();
      System.out.println("   lastName = "+lastName);
      System.out.println("   indexOfEgg = " + lastName.toLowerCase().indexOf("egg"));
      System.out.println("   indexOfHam = " + lastName.toLowerCase().indexOf("ham"));
      boolean lastDPAnEgg = (lastName.toLowerCase().indexOf("egg") > -1);
  
      String intFromLastName = lastName.replaceAll("[^-?0-9]+", "");
      System.out.println("   intFromLastName = "+intFromLastName);
  
      if (!lastDPAnEgg) return 0;
      int ans = Integer.parseInt(intFromLastName);
      int otherAttempt = getDataSheet(sheetNo).getLastNumber("egg");
      System.out.println("first answer = "+ans+" and second answer = "+otherAttempt);
  
      return (Integer.parseInt(intFromLastName) + 1);
    }
    return 0;
  }

  public void addNewEgg(int sheetNo) {
    DataSheet ds = getDataSheet(sheetNo);
    int eggNo = getEggCount(sheetNo);
    DataPoint eggDiameter = new Amount("egg "+eggNo+" diam.", (Double) null, "cm");
    DataPoint eggWeight = new Amount("egg "+eggNo+" weight", (Double) null, "g");
    ds.add(eggDiameter);
    ds.add(eggWeight);
  }


}
