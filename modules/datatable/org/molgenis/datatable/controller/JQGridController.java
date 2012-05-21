package org.molgenis.datatable.controller;

import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.molgenis.datatable.model.JdbcTable;
import org.molgenis.datatable.model.TableException;
import org.molgenis.datatable.model.TupleTable;
import org.molgenis.framework.db.Database;
import org.molgenis.framework.db.DatabaseException;
import org.molgenis.framework.db.QueryRule;
import org.molgenis.framework.db.QueryRule.Operator;
import org.molgenis.framework.server.MolgenisContext;
import org.molgenis.framework.server.MolgenisRequest;
import org.molgenis.framework.server.MolgenisResponse;
import org.molgenis.framework.server.MolgenisService;
import org.molgenis.util.Tuple;

import com.google.gson.Gson;

public class JQGridController implements MolgenisService
{
	class JQGridResult {
		private String page;
		private String total;
		private String records;
		
		private ArrayList<LinkedHashMap<String,String>> rows = new ArrayList<LinkedHashMap<String, String>>();
		
		public JQGridResult(String page, String total, String records) {
			this.page = page;
			this.total = total;
			this.records = records; 
		}
	}
	
	private final MolgenisContext context;

	public JQGridController(MolgenisContext context)
	{
		this.context = context;
	}

	private final static String SQL_START = "SELECT %1$s FROM %2$s ";
	
	@Override
	public void handleRequest(MolgenisRequest request, MolgenisResponse response) throws ParseException,
			DatabaseException, IOException
	{
		int page = request.getInt("page");
		int limit = request.getInt("rows");
		String sidx = request.getString("sidx");
		String sord = request.getString("sord");
		
		String[] columnNames = new Gson().fromJson(request.getString("colNames"), String[].class);
		
		String tableName = "Country"; //can be retrieved from request (put in post data)
		String sqlCount = String.format(SQL_START, "COUNT(*)", tableName );
		String sqlSelect = String.format(SQL_START, StringUtils.join(columnNames, ","), tableName );
		
		final Database db = request.getDatabase();
		int rowCount = db.sql(sqlCount).get(0).getInt(0); //should go to method of interface or 
		int totalPages = 0;
		if( rowCount > 0 ) {
			totalPages = (int) Math.ceil(rowCount/limit);
		} 
		
		if (page > totalPages) { 
			page= totalPages; 
		}
		
		int offset = limit * page - limit; 		

		final List<QueryRule> rules = Arrays.asList(new QueryRule(Operator.LIMIT, limit), new QueryRule(Operator.OFFSET, offset));
		try
		{			

			final TupleTable jdbcTable = new JdbcTable(sqlSelect, db.getConnection());
			final JQGridResult result = new JQGridResult("1", "1", "4");
			
			for(final Tuple row : jdbcTable.getRows()) {
				final LinkedHashMap<String, String> rowMap = new LinkedHashMap<String, String>();
				
				final List<String> fieldNames = row.getFieldNames();
				for(final String fieldName : fieldNames) {
					final String rowValue = !row.isNull(fieldName) ? row.getString(fieldName) : "null";
					rowMap.put(fieldName, rowValue);
				}
				result.rows.add(rowMap);
			}
			jdbcTable.close();
			
			response.getResponse().getWriter().print(new Gson().toJson(result));
		}
		catch (TableException e)
		{
			throw new DatabaseException(e);
		}
	}
}