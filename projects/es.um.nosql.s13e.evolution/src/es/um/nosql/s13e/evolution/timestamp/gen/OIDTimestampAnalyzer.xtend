package es.um.nosql.s13e.evolution.timestamp.gen


class OIDTimestampAnalyzer extends TimestampAnalyzer
{
  String attrName;

  new()
  {
    this("_id");
  }

  new(String attrName)
  {
    this.attrName = attrName;
  }

  override toString()
  '''
  // This OID TimestampAnalyzer looks for an attribute with a given name,
  // and tries to decode it as if it was a MongoDB ObjectId Object, and so
  // some bytes may be decoded to obtain a timestamp.
  var TimestampAnalyzer =
  {
    _attrName: "«attrName»",
    _value: "",

    getAttrValue: function()
    {
      if (this._value === "")
        return 0;
      else
        return this._value;
    },
    analyzeAttribute: function(attrName, attrValue)
    {
      if (attrName === this._attrName)
      {
        if (attrValue instanceof ObjectId)
          this._value = Date.parse(attrValue.getTimestamp());
        else if (((typeof attrValue) == 'number') || ((typeof attrValue) == 'string'))
          this._value = Date.parse((new ObjectId(attrValue)).getTimestamp());
      }
    }
  };
  '''
}
