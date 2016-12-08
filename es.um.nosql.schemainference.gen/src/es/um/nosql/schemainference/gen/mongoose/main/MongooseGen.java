package es.um.nosql.schemainference.gen.mongoose.main;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintStream;
import org.eclipse.emf.ecore.resource.Resource;
import es.um.nosql.schemainference.NoSQLSchema.NoSQLSchema;
import es.um.nosql.schemainference.NoSQLSchema.NoSQLSchemaPackage;
import es.um.nosql.schemainference.gen.mongoose.xtend.MongooseGenerator;
import es.um.nosql.schemainference.util.emf.ResourceManager;

public class MongooseGen {

	/**
	 * Main method used to parse the given arguments, inject classes and execute the main.execute call.
	 * @param args The arguments given by command line.
	 * @throws IOException In case any of the .box files given doesn't exist.
	 */
	public static void main(String[] args) throws IOException
	{
		(new MongooseGen()).execute(args);
	}

	/**
	 * Execute method used to register input models and call the code generator.
	 * @param args The argument boxes to be processed in a string list.
	 * @throws FileNotFoundException
	 */
	protected void execute(String[] args) throws FileNotFoundException
	{
		if (args.length < 1)
		{
			System.out.println("Syntax: Gen Model.xmi [outdir]");
			System.exit(-1);
		}

		PrintStream outFileWriter = System.out;
		if (args.length > 1)
		{
			File outputDir = new File(args[1]);
			outputDir.mkdirs();

			// FIXME: Cambiar "salida.js" por el fichero de salida
			File outFile = outputDir.toPath().resolve("mongooseSchema.js").toFile();
			outFileWriter = new PrintStream(outFile);
		}

		ResourceManager rm = new ResourceManager(NoSQLSchemaPackage.eINSTANCE);
		rm.loadResourcesAsStrings(args[0]);

		MongooseGenerator gen = new MongooseGenerator();

		for (Resource r : rm.getResources())
			outFileWriter.print(gen.generate((NoSQLSchema) r.getContents().get(0)));
	}
}
