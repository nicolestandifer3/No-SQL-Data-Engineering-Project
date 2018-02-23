package es.um.nosql.s13e.db.gen.generator;

import java.util.Arrays;
import java.util.List;

import org.bson.types.ObjectId;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;

import es.um.nosql.s13e.db.gen.utils.Constants;
import es.um.nosql.s13e.db.gen.generator.primitivetypes.BooleanGen;
import es.um.nosql.s13e.db.gen.generator.primitivetypes.NumberGen;
import es.um.nosql.s13e.db.gen.generator.primitivetypes.ObjectGen;
import es.um.nosql.s13e.db.gen.generator.primitivetypes.StringGen;

public class PrimitiveTypeGen
{
  private StringGen strGen;
  private NumberGen numGen;
  private BooleanGen boolGen;
  private ObjectGen objGen;
  private JsonNodeFactory jsonFactory;
  private List<String> definedTypes;

  public PrimitiveTypeGen()
  {
    strGen        = StringGen.GET_INSTANCE();
    numGen        = NumberGen.GET_INSTANCE();
    boolGen       = BooleanGen.GET_INSTANCE();
    objGen        = ObjectGen.GET_INSTANCE();
    jsonFactory   = JsonNodeFactory.instance;
    definedTypes  = Arrays.asList("string", "int", "double", "bool", "objectid");
  }

  public JsonNode genPrimitiveType(String type)
  {
    String theType = type;

    if (boolGen.thisHappens(Constants.GET_PRIMITIVE_TYPES_NULL_PROBABILITY()))
      theType = "null";

    if (boolGen.thisHappens(Constants.GET_PRIMITIVE_TYPES_STRANGE_TYPES_PROBABILITY()))
      theType = definedTypes.get(numGen.getExclusiveRandom(0, definedTypes.size()));

    return genTrustedPrimitiveType(theType);
  }

  public JsonNode genTrustedPrimitiveType(String type)
  {
    switch (type.toLowerCase())
    {
      case "string":                return jsonFactory.textNode(this.genRandomString());
      case "int": case "number":    return jsonFactory.numberNode(this.genRandomInt());
      case "double": case "float":  return jsonFactory.numberNode(this.genRandomDouble());
      case "bool": case "boolean":  return jsonFactory.booleanNode(this.genRandomBoolean());
      case "objectid":              return jsonFactory.objectNode().put("$oid", this.genRandomObjectId().toString());
      default:                      return jsonFactory.nullNode();
    }
  }

  public JsonNode genTrustedObjectId(String type)
  {
    switch (type.toLowerCase())
    {
      case "string":              return jsonFactory.textNode(this.genRandomObjectId().toString());
      case "objectid":            return jsonFactory.objectNode().put("$oid", this.genRandomObjectId().toString());
      case "int": case "number":  return jsonFactory.numberNode(this.genRandomObjectId().getCounter());
      default:                    return jsonFactory.nullNode();
    }
  }

  public String genRandomString()
  {
    switch (Constants.GET_PRIMITIVE_TYPES_STRING_TYPE())
    {
      case "random":        return strGen.getRandomString();
      case "large":         return strGen.getRandomLargeString();
      case "word":          return strGen.getRandomWord();
      case "phrase":        return strGen.getRandomPhrase();
      case "word_number":   return strGen.getRandomWordNumber();
      case "nonsense":      return strGen.getRandomNonsense();
      case "name":          return strGen.getRandomName();
      case "name_surname":  return strGen.getRandomFullname();
      default:              return null;
    }
  }

  public boolean genRandomBoolean()
  {
    return boolGen.getRandomBoolean();
  }

  public int genRandomInt()
  {
    return numGen.getRandomInteger();
  }

  public double genRandomDouble()
  {
    return numGen.getRandomDouble();
  }

  public ObjectId genRandomObjectId()
  {
    return objGen.getRandomObjectId();
  }

  public Object genNull()
  {
    return objGen.getNull();
  }
}