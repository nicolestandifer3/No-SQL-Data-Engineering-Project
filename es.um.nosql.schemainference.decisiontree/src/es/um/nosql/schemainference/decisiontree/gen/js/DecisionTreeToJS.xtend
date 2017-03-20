package es.um.nosql.schemainference.decisiontree.gen.js

import es.um.nosql.schemainference.util.emf.ResourceManager
import es.um.nosql.schemainference.NoSQLSchema.NoSQLSchemaPackage
import java.io.File
import es.um.nosql.schemainference.entitydifferentiation.EntityDiffSpec
import java.util.List
import es.um.nosql.schemainference.entitydifferentiation.EntityVersionProp
import java.io.PrintStream
import es.um.nosql.schemainference.entitydifferentiation.PropertySpec
import es.um.nosql.schemainference.NoSQLSchema.Property
import es.um.nosql.schemainference.NoSQLSchema.PrimitiveType
import es.um.nosql.schemainference.NoSQLSchema.Attribute
import es.um.nosql.schemainference.NoSQLSchema.Type
import es.um.nosql.schemainference.NoSQLSchema.Tuple
import es.um.nosql.schemainference.NoSQLSchema.Reference
import es.um.nosql.schemainference.NoSQLSchema.Aggregate
import es.um.nosql.schemainference.NoSQLSchema.Entity
import es.um.nosql.schemainference.decisiontree.DecisiontreePackage
import es.um.nosql.schemainference.decisiontree.DecisionTrees

class DecisionTreeToJS
{
	var modelName = "";

	final val SPECIAL_TYPE_IDENTIFIER = "type"

	def static void main(String[] args)
    {
		if (args.length < 1)
		{
			System.out.println("Usage: DiffToJS model [outdir]")
			System.exit(-1)
		}

        val inputModel = new File(args.head)
        val ResourceManager rm = new ResourceManager(DecisiontreePackage.eINSTANCE,
        	NoSQLSchemaPackage.eINSTANCE)
        rm.loadResourcesAsStrings(inputModel.getPath())
        val DecisionTrees trees = rm.resources.head.contents.head as DecisionTrees

		val outputDir = new File(if (args.length > 1) args.get(1) else ".")
								.toPath().resolve(trees.name).toFile()
		// Create destination directory if it does not exist
		outputDir.mkdirs()
        System.out.println("Generating Javascript for "
        					+ inputModel.getPath()
        					+ " in "
        					+ outputDir.getPath())

//        val NoSQLDifferences dataModelObject = M2M.getInstance().transform(modelObject)
//

		val dt_to_js = new DecisionTreeToJS()
		val outFile = outputDir.toPath().resolve(trees.name + ".js").toFile()
		val outFileWriter = new PrintStream(outFile)

        outFileWriter.println(dt_to_js.generate(trees))
        outFileWriter.close()

        System.exit(0)
    }

	/**
	 * Method used to generate an Inclusive/Exclusive differences file for a NoSQLDifferences object.
	 */
	def generate(DecisionTrees dt)
	{
		modelName = dt.name;

		'''
		'use strict'

		var «dt.name» = {

			name: "«dt.name»",
			«genSpecs(diff.entityDiffSpecs)»
		}

		module.exports = «dt.name»;
		'''
	}

	def genSpecs(List<EntityDiffSpec> list) '''
		«FOR EntityDiffSpec de : list SEPARATOR ','»
			«genEntityDiffs(de)»
		«ENDFOR»
	'''

	def genEntityDiffs(EntityDiffSpec spec) '''
		«FOR evp : spec.entityVersionProps SEPARATOR ','»
			«genEntityVersionDiff(evp, spec)»
		«ENDFOR»
	'''

	def genEntityVersionDiff(EntityVersionProp evp, EntityDiffSpec spec) {
		val entityVersionName = spec.entity.name.toFirstUpper + "_" + evp.entityVersion.versionId

		'''
		«entityVersionName»: {
			name: "«entityVersionName»",
			isOfType: function (obj)
			{
			    var b = true;
				«generateHints(evp, spec, DUCK_TYPE)»
		        return b;
			}
		}'''
	}

	def generateHints(EntityVersionProp evp, EntityDiffSpec spec, boolean exact) {
		'''
			b = b && «genProp(p)»;
			b = b && «genNotPropForPropName(p)»;
		'''
    }

    def genProp(PropertySpec p)
    {
		if (p.needsTypeCheck)
			'''("«p.property.name»" in obj) && «genTypeCheck(p.property)»'''
		else
			'''("«p.property.name»" in obj)'''
	}

    def genNotPropForPropName(String p)
		'''!("«p»" in obj)'''

	def dispatch genTypeCheck(Property p) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	def dispatch genTypeCheck(Aggregate a) '''
		«IF a.lowerBound == 0»
		(obj.«a.name».constructor === Array) &&
		    obj.«a.name».every(function(e)
		        { return (typeof e === 'object') && !(e.constructor === Array)
		            && («FOR rt : a.refTo SEPARATOR " || "»
		            «modelName».«(rt.eContainer as Entity).name»_«rt.versionId».isOfExactType(e)
		            «ENDFOR»);
		        })
		«ELSE»
		«var refToEV = a.refTo.get(0)»
		(typeof obj.«a.name» === 'object') && !(obj.«a.name».constructor === Array)
		    && «modelName».«(refToEV.eContainer as Entity).name»_«refToEV.versionId».isOfExactType(obj.«a.name»)
		«ENDIF»
	'''

	def dispatch genTypeCheck(Reference r) '''
		«IF r.lowerBound == 0»
		(obj.«r.name».constructor === Array) &&
		    (obj.«r.name».every(function(e) { return typeof e === "number";})
		     ||
		     obj.«r.name».every(function(e) { return typeof e === "string";}))
		«ELSE»
		((typeof obj.«r.name» === "number") || (typeof obj.«r.name» === "string"))
		«ENDIF»
	'''


	def dispatch genTypeCheck(Attribute a) {
		genTypeCheckLowLevel(a.type, "obj." + a.name);
	}

	def dispatch genTypeCheckLowLevel(Type type, String name) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}

	private def isInt(String type) { #["int", "integer", "number"].contains(type) }
	private def isFloat(String type) { #["float", "double"].contains(type) }
	private def isBoolean(String type) { #["boolean", "bool"].contains(type) }

	def dispatch CharSequence genTypeCheckLowLevel(PrimitiveType type, String name) {
		switch typeName : type.name.toLowerCase {
			case "string" : '''(typeof «name» === "string")'''
			case typeName.isInt : '''(typeof «name» === "number") && («name» % 1 === 0)'''
			case typeName.isFloat :  '''(typeof «name» === "number") && !(«name» % 1 === 0)'''
			case typeName.isBoolean : '''(typeof «name» === "boolean")'''
			default: ''''''
		}
	}

	def dispatch CharSequence genTypeCheckLowLevel(Tuple type, String name) {
	    '''(«name».constructor === Array) && («name».length === «type.elements.size»)
	    «IF type.elements.size != 0»
	    &&
	    «var i = 0»
	    «FOR t : type.elements SEPARATOR " && "»
	    «genTypeCheckLowLevel(t, name + '[' + i++ + ']')»
	    «ENDFOR»
	    «ENDIF»'''
	}
}
