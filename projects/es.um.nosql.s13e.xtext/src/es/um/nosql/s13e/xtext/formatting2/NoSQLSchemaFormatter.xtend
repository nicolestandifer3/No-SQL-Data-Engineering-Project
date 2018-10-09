package es.um.nosql.s13e.xtext.formatting2

import com.google.inject.Inject
import es.um.nosql.s13e.NoSQLSchema.NoSQLSchema
import es.um.nosql.s13e.xtext.services.NoSQLSchemaGrammarAccess
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import es.um.nosql.s13e.NoSQLSchema.StructuralVariation
import es.um.nosql.s13e.NoSQLSchema.Classifier
import es.um.nosql.s13e.NoSQLSchema.Reference

class NoSQLSchemaFormatter extends AbstractFormatter2
{
  @Inject extension NoSQLSchemaGrammarAccess

  def dispatch void format(NoSQLSchema schema, extension IFormattableDocument document)
  {
    interior(schema.regionFor.keyword("{"), schema.regionFor.keyword("}"))[indent]
    schema.regionFor.keywords("{").head.prepend[newLine].append[newLine]
    schema.regionFor.keywords("}").last.prepend[newLine].append[newLine]
    schema.regionFor.keywords(",").forEach[prepend[noSpace].append[newLine]]

    schema.entities.forEach[format]
    schema.refClasses.forEach[format]
  }

  def dispatch void format(Classifier classifier, extension IFormattableDocument document)
  {
    interior(classifier.regionFor.keyword("{"), classifier.regionFor.keyword("}"))[indent]
    classifier.regionFor.keywords("{").head.prepend[newLine].append[newLine]
    classifier.regionFor.keywords("}").last.prepend[newLine]
    classifier.regionFor.keywords(",").forEach[prepend[noSpace].append[newLine]]

    classifier.variations.forEach[format]
  }

  def dispatch void format(StructuralVariation variation, extension IFormattableDocument document)
  {
    interior(variation.regionFor.keyword("{"), variation.regionFor.keyword("}"))[indent]
    variation.regionFor.keywords("{").head.prepend[newLine].append[newLine]
    variation.regionFor.keywords("}").last.prepend[newLine]
    variation.regionFor.keywords(",").forEach[prepend[noSpace].append[newLine]]

    variation.regionFor.keyword("properties").prepend[newLine]
    set(variation.properties.head.regionForEObject.previousHiddenRegion, variation.properties.last.regionForEObject.nextHiddenRegion)[indent]
    variation.regionFor.keyword("properties").nextSemanticRegion.prepend[newLine].append[newLine]

    variation.properties.forEach[format]
  }

  def dispatch void format(Reference ref, extension IFormattableDocument document)
  {
    interior(ref.regionFor.keyword("{"), ref.regionFor.keyword("}"))[indent]
    ref.regionFor.keywords("{").head.prepend[newLine].append[newLine]
    ref.regionFor.keywords("}").last.prepend[newLine]
  }
}