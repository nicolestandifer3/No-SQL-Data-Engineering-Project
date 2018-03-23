package es.um.nosql.s13e.db.gen.config;

import es.um.nosql.s13e.db.gen.utils.constants.ConfigConstants;

public class EntityOptions
{
  private VersionOptions versions;
  public void setVersions(VersionOptions versions) {this.versions = versions;}
  public VersionOptions getVersions() {return this.versions;}

  private Boolean includeType;
  public void setIncludeType(Boolean includeType) {this.includeType = includeType;}
  public Boolean getIncludeType() {return this.includeType;}

  public String toString()
  {
    StringBuilder result = new StringBuilder();

    if (this.getVersions() != null)     result.append(ConfigConstants.GET_TABS(this.getClass()) + "-Versions:\n" + this.getVersions());
    if (this.getIncludeType() != null)  result.append(ConfigConstants.GET_TABS(this.getClass()) + "-Include type: " + this.getIncludeType() + "\n");

    return result.toString();
  }

  public boolean doCheck()
  {
    if (this.getVersions() != null)
      this.getVersions().doCheck();

    return true;
  }
}