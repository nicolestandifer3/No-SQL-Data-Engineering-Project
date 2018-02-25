package es.um.nosql.s13e.db.gen.generator;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;

import es.um.nosql.s13e.NoSQLSchema.Aggregate;
import es.um.nosql.s13e.NoSQLSchema.EntityVersion;
import es.um.nosql.s13e.db.gen.generator.primitivetypes.NumberGen;
import es.um.nosql.s13e.db.gen.utils.Constants;

public class AggregateGen
{
  private NumberGen numGen;
  private JsonNodeFactory jsonFactory;

  public AggregateGen()
  {
    numGen = NumberGen.GET_INSTANCE();
    jsonFactory = JsonNodeFactory.instance;
  }

  public JsonNode genAggregate(Aggregate aggr, Map<EntityVersion, List<ObjectNode>> evMap)
  {
    JsonNode result = null;

    int lBound = aggr.getLowerBound() > 0 ? aggr.getLowerBound() : Constants.GET_AGGREGATE_MIN_ALLOWED();
    int uBound = aggr.getUpperBound() > 0 ? aggr.getUpperBound() : Constants.GET_AGGREGATE_MAX_ALLOWED();

    if (lBound == 1 && uBound == 1)
      result = this.getRandomAggrs(aggr.getRefTo().get(0), evMap, 1).get(0);
    else
    {
      ArrayNode aggrArray = jsonFactory.arrayNode();

      // TODO: This might aggregate the same object several times. It might be a problem.
      // For each aggregation we have to include, we select a random aggregated version and aggregate one object according to that version.
      aggrArray.addAll(this.getRandomAggrs(aggr.getRefTo().get(numGen.getExclusiveRandom(0,  aggr.getRefTo().size())), evMap, numGen.getInclusiveRandom(lBound, uBound)));

      result = aggrArray;
    }

    return result;
  }

  private List<JsonNode> getRandomAggrs(EntityVersion eVersion, Map<EntityVersion, List<ObjectNode>> evMap, int numElements)
  {
    List<JsonNode> result = new ArrayList<JsonNode>();

    for (int i = 0; i < numElements; i++)
      result.add(evMap.get(eVersion).get(numGen.getExclusiveRandom(0, evMap.get(eVersion).size())));

    return result;
  }
}