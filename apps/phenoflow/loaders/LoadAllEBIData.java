package loaders;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.molgenis.Molgenis;
import org.molgenis.framework.db.Database;
import org.molgenis.framework.db.Database.DatabaseAction;

import app.DatabaseFactory;
import app.EntitiesImporterImpl;

public class LoadAllEBIData
{
	public static void main(String[] args) throws Exception
	{

		new Molgenis("apps/phenoflow/phenoflow.properties").updateDb(true);

		// recreate database
		Database db = DatabaseFactory.create("apps/phenoflow/phenoflow.properties");
		String directory;

		// Load dbGaP
		LoadDbGapDownloads.loadDbGaPData(db);

		// Europhenome
		directory = "../pheno_data/Europhenome2";

		new EntitiesImporterImpl(db).importEntities(Arrays.asList(new File(directory).listFiles()),
				DatabaseAction.ADD_IGNORE_EXISTING);

		// MPD

		// need to preload measurements first, otherwise protocol
		// will complain it's missing them due to incorrect
		// autogenerated order

		List<String> list = new ArrayList<String>();
		list.add("investigation");
		list.add("ontologyterm");
		list.add("measurement");
		directory = "../pheno_data/MPD";
		new EntitiesImporterImpl(db).importEntities(Arrays.asList(new File(directory).listFiles()),
				DatabaseAction.ADD_IGNORE_EXISTING);

		System.out.println("Done");
	}
}
