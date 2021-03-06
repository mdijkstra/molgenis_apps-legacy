<#macro PhenotypeViewer screen>
<script src="jqGrid/grid.locale-en.js" type="text/javascript"></script>
<script src="jqGrid/jquery.jqGrid.min.js" type="text/javascript"></script>
<script src="jqGrid/jquery.jqGrid.src.js" type="text/javascript"></script>
<script src="jqGrid/jquery.json-2.3.min.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {
		
		$('#createNewInvest').click(function(){
		
			//It was not checked before, now it is checked
			if($(this).attr('checked') == "checked"){
				$('#newInvestigation').attr('disabled', false);
				$('#project').attr('disabled', true);
			}else{
				$('#newInvestigation').attr('disabled', true);
				$('#project').attr('disabled', false);
			}
		});
		
		$('#uploadFileForm').dialog({ 
			autoOpen: false, 
			width:400,
			height:300,
			title:"upload a csv file",
			modal:true
		});
		
		$('#uploadFileForm').parent().appendTo($('form[name="${screen.name}"]'));
		
		$('#previousStepSummary').button();
		$('#importUploadFile').button();
		$('#preview').button();
		$('#uploadNewFile').button();
		$('#uploadNewFileSecond').button();
		$('#fileUploadNext').button();
		$('#fileUploadCancel').button();
		$('#uploadFileButton').button();
		
		$('#fileUploadCancel').click(function(){
			$('#uploadFileForm').dialog('close');
		});
		
		$('#previousStepSummary').click(function(){
			$('#showPreviewedTable').fadeOut();
			$('#summaryPage').fadeIn();
		});
		
		$('#preview').click(function(){
			
			if($('#previewedTable').children().length == 0){
				$.ajax("${screen.getUrl()}&__action=download_json_loadPreview").done(function(status) {
					previewTable = status["result"];
					$('#previewedTable').append(previewTable);
				});
			}
			$('#summaryPage').fadeOut();
			$('#showPreviewedTable').fadeIn();
		});
		
		$('#uploadFileButton').click(function(){
			$('#uploadFileForm').dialog('open');
		});
		
		$('#fileUploadNext').click(function(){
			
			if($('#uploadFileName').val() != ""){
				fileNameComponent = $('#uploadFileName').val().split(".");
				numOfComponent = fileNameComponent.length;
				areEqual = fileNameComponent[numOfComponent - 1].toUpperCase() === ("csv").toUpperCase();
				if(!areEqual){
					alert("please upload a csv file");
				}else{
					$('#uploadFileForm').dialog('close');
					$('input[name="__action"]').val('uploadFile');
					$('form[name="${screen.name}"]').submit();

				}
			}else{
				alert("Please upload a file!");
			}
		});
	});
	
	function generateReport(reportObject){
		
		existingColumns = reportObject['colHeaders'];
		newColumns = reportObject['newFeatures'];
		existingRowRecords = reportObject['rowHeaders'];
		newRowRecords = reportObject['newTargets'];
		$('#reportForm').prepend("<h3>Summary of upload file:</h3></br>");
		$('#existingColHeaders').append("Existing columns: " + existingColumns.length);
		$('#newColHeaders').append("New columns: " + newColumns.length);
		$('#existingRowRecords').append("Existing records: " + existingRowRecords.length);
		$('#newRowRecords').append("New records: " + newRowRecords.length);
		
		if(newColumns.length > 0 && $('#newColumnsMapping').children().length == 0){
			
			var molgenisDataOptions;
			
			var protocolTables;
			
			<#list screen.getFeatureDataTypes() as dataType>
				<#if dataType == "string">
					molgenisDataOptions += "<option value=\"${dataType}\" selected=\"selected\">${dataType}</option>";
				<#else>
					molgenisDataOptions += "<option value=\"${dataType}\">${dataType}</option>";
				</#if>
			</#list>
			<#list screen.getProtocolTables() as table>
				<#if table == "NotClassified">
					protocolTables += "<option value=\"${table}\" selected=\"selected\">${table}</option>";
				<#else>
					protocolTables += "<option value=\"${table}\">${table}</option>";
				</#if>
			</#list>
			
			mappingTable = "<table id=\"mappingTable\" style=\"border:1px\"><tr><th>Variable</th><th>Data type</th><th>Category</th><th>Table</th><th>Import</th></tr>";
			
			for(var i = 0; i < newColumns.length; i++ ){
				
				identifier = newColumns[i].replace(" ","_");
				
				selectDataTypes = "<select id=\"" + identifier + "_dataType\" name=\"" + identifier + "_dataType\">" + molgenisDataOptions + "</select>";
				
				categories = "<div id=\"" + identifier + "_categoriesControl\" style=\"display:none\"><select id=\"" + identifier + "_categories\" name=\"" + identifier + "_categories\"></select>"
					+ "<input type=\"button\" id=\"" + identifier + "_editCategory\" style=\"font-size:0.7em\" value=\"edit\" /></div>";
				
				tables = "<select id=\"" + identifier + "_protocolTable\" name=\"" + identifier + "_protocolTable\">" + protocolTables + "</select>";
				
				checkBox = "<input type=\"checkbox\" id=\"" + identifier + "_check\" name=\"" + identifier + "_check\" checked=\"checked\" value=\"yes\"> yes";
				
				mappingTable += "<tr id=\"" + identifier + "_mapping\"><td>" + newColumns[i] + "</td><td>" 
					+ selectDataTypes + "</td><td>" + categories + "</td><td>" + tables + "</td><td>" + checkBox + "</td></tr>";
	
			} 
			
			mappingTable += "</table>";
			
			mappingHeader = "Please specify the type of the new columns. The data type is by default string. </br></br>";
			
			mappingHeader += "<fieldset>Upload your mapping file <input type=\"file\" id=\"mappingForColumns\" name=\"mappingForColumns\" />";
			
			mappingHeader += "<input type=\"button\" id=\"uploadMapping\" name=\"uploadMapping\""+
				"style=\"font-size:0.6em;color:#03406A\" value=\"upload\">";
			
			mappingHeader += "<input type=\"submit\" id=\"downloadTemplate\" name=\"downloadTemplate\""+
				"style=\"font-size:0.6em;color:#03406A\" value=\"download template\" onclick=\"__action.value='downloadTemplate';return true;\"></fieldset>";
			
			$('#newColumnsMapping').append(mappingTable);
			$('#newColumnsMapping').prepend(mappingHeader);
			$('#newColumnsMapping').append("</br><input type=\"button\" id=\"previousFromMapping\" style=\"font-size:0.6em;color:#03406A\" value=\"Previous\"/>");
			
			
			$('#previousFromMapping').button();
			$('#downloadTemplate').button();
			$('#uploadMapping').button();
			
			$('#mappingTable th').width(700);
			$('#mappingTable td').css('text-align','center');
			$('#mappingTable th').css('background','#65A5D1');
			$('#mappingTable tr').css('border-bottom','1px dotted');
			
			<#if screen.getJsonForMapping()??>
				
				mappingResult = eval(${screen.getJsonForMapping()});
				
				for(var index = 0; index < mappingResult.length; index++){
					eachMapping = mappingResult[index];
					identifier = eachMapping["variableName"].replace(" ","_");
					$('#' + identifier + '_dataType').val(eachMapping["dataType"]);
					if(eachMapping["dataType"] == "categorical"){
						$('#' + identifier + '_categoriesControl').show();
					}
					
					listOfCategories = eachMapping["listOfCategories"];
					
					for (var key in listOfCategories) {
						newCategory = key + "=" + listOfCategories[key];
						$('#' + identifier + '_categories').append("<option>" + newCategory + "</option>");
						addNewCategory = "<input type=\"hidden\" id=\"" + identifier + "_categoryString\" name=\"" + identifier 
							+ "_categoryString\" value=\"" + newCategory + "\"/>";
						$('#' + identifier + '_categoriesControl').append(addNewCategory);
						
					}
					
					$('#' + identifier + '_protocolTable').val(eachMapping["table"]);
				}
			</#if>
			
			<#if screen.getMappingMessage()??>
				$('#newColumnsMapping').prepend("<p style=\"color:red\"><i>There are errors in your mapping file, please check before upload!</i></p>");
			</#if>
			
			$('#previousFromMapping').click(function(){
				$('#newColumnsMapping').hide();
				$('#reportForm').fadeIn();
			});
			
			$('#uploadMapping').click(function(){
				
				fileNameComponent = $('#mappingForColumns').val().split(".");
				numOfComponent = fileNameComponent.length;
				areEqual = fileNameComponent[numOfComponent - 1].toUpperCase() === ("csv").toUpperCase();
				if(!areEqual){
					alert("please upload a csv file");
				}else{
					$('input[name="__action"]').val('uploadMapping');
					$('form[name="${screen.name}"]').submit();
				}
				
			});
			
			$('#mappingTable tr:gt(0)').each(function(){
				
				$(this).find('select').eq(0).change(function(){
					
					identifier = $(this).parents('tr:first').attr('id').replace("_mapping","");
					
					if($(this).val() == "categorical"){
						$('#' + identifier + '_categoriesControl').show();
					}else{
						$('#' + identifier + '_categoriesControl').hide();
					}
				});
				
				$(this).find('td:eq(2) input').click(function(){
					
					identifier = $(this).parents('tr:first').attr('id').replace("_mapping","");
					
					variableName = $(this).parents('tr:first').find('td:first').html();
					
					if($('#' + identifier + '_dialog').length == 0){
					
						select = "<select id=\"" + identifier + "_dialogSelect\">";
						
						$('#' + identifier + '_categories option').each(function(){
							select += "<option>" + $(this).html() + "</option>";
						});
						
						select += "</select>";
						
						removeButton = "<input type=\"button\" id=\"" + identifier + "_dialogRemove\" value=\"remove\"/>";
						
						addCategoryInput = "<div id=\"" + identifier + "_dialogInput\"></div>";
						
						addCategoryInput += "Code:&nbsp;<input type=\"text\" id=\"" + identifier + "_dialogCode\" size=\"15\"></br></br>"
							+ "String:<input type=\"text\" id=\"" + identifier + "_dialogString\" size=\"15\">"	
							+ "  <input type=\"button\" id=\"" + identifier + "_dialogAdd\" value=\"add\" /></div>";
						
						removePanel = "<fieldset><b><i>Remove existing category:</b></i></br></br>" + select + "&nbsp;&nbsp;" + removeButton + "</fieldset>";
						
						addPanel = "<fieldset> <b><i>Please input your category:</b></i></br></br>" +  addCategoryInput + "</fieldset>";
						
						dialogPanel = "<div id=\"" + identifier + "_dialog\"><fieldset><b><i>Variable name: </i></b>" 
							+ variableName + "</fieldset>" + removePanel + addPanel + "</div>";
						
						$('#' + identifier + '_categoriesControl').append(dialogPanel);
						
						$('#' + identifier + '_dialog').dialog({ buttons: [
						    {
						        text: "Close",
						        click: function() { $(this).dialog("close"); }
						    }],
						    title: "Edit the category",
						    width:400,
						});
						
						$('#' + identifier + '_dialog').css('font-size', 15);					
						$('#' + identifier + '_dialogAdd').button();
						$('#' + identifier + '_dialogRemove').button();
						
						$('#' + identifier + '_dialogAdd').click(function(){
							codeString = $('#' +  identifier + '_dialogString').val();
							code = $('#' +  identifier + '_dialogCode').val();
							if(code == "" || codeString == ""){
								alert("Please specify the code and corresponding label");
							}else{
								newCategory = "<option>"+ code + "=" + codeString + "</option>";
								$('#' + identifier + '_categories').append(newCategory);
								$('#' + identifier + '_dialogSelect').append(newCategory);
								
								addNewCategory = "<input type=\"hidden\" id=\"" + identifier + "_categoryString\" name=\"" + identifier 
												+ "_categoryString\" value=\"" + code + "=" + codeString + "\"/>";
								$('#' + identifier + '_categoriesControl').append(addNewCategory);
								
								lastOption = $('#' + identifier + '_dialogSelect option:last').val();
								$('#' + identifier + '_dialogSelect').val(lastOption);
								
								$('#' +  identifier + '_dialogString').val("");
								$('#' +  identifier + '_dialogCode').val("");
							}
						});
														
						$('#' + identifier + '_dialogRemove').click(function(){
							$('#' + identifier + '_categories option:selected').remove();
							$('#' + identifier + '_dialogSelect option:selected').remove();
						});
						
					}else{
						$('#' + identifier + '_dialog').dialog('open');
					}
				});
			});
		}
		
		
		$('#reportForm div').each(function(){
			hoverOver(this);
		});
		
		$('#newColHeaders').click(function(){
			
			if(newColumns.length > 0){
				
				$('#reportForm').hide();
					
				$('#newColumnsMapping').fadeIn(1000);
				
			}else{
				alert("There are no new columns in the file!");
			}
		});
		
		//Submit the form and reload page to show the new records only
		$('#newRowRecords').click(function(){
			if(newRowRecords.length > 0){
				$('input[name="__action"]').val('showNewRecordsOnly');
				$('form[name="${screen.name}"]').submit();
			}else{
				alert("There are no new records!");
			}
		});
	}

	function hoverOver(element){
	
		$(element).hover(
		  function () {
		  	font = 	parseInt($(this).css('font-size'));
		    $(this).css('font-size', font + 2);
		    $(this).css('color', 'grey');
		    $('#notification').append("Click to see " + $(this).attr('id'));
		  }, 
		  function () {
		    font = parseInt($(this).css('font-size'));
		    $(this).css('font-size', font - 2);
		    $(this).css('color', 'black');
		    $('#notification').empty();
		  }
		);
	}
	
	function updateInvestigation(){
		
		$.ajax(
			{
				url:"${screen.getUrl()}&__action=download_json_reloadGridByInves&investigation=" 
				+ $('#selectInvestigation').val(),
				async:false
			}
			).done(function(status) {
			updatedTable = status["result"];
		});
		$('#tableViewer').empty();
		$('#tableViewer').append(updatedTable);
	}
	
</script>

<form method="post" enctype="multipart/form-data" name="${screen.name}" action="">
	<!--needed in every form: to redirect the request to the right screen-->
	<input type="hidden" name="__target" value="${screen.name}">
	<!--needed in every form: to define the action. This can be set by the submit button-->
	<input type="hidden" name="__action">
	
	<div class="formscreen">	
		
		<div class="form_header" id="${screen.getName()}">
			${screen.label}
		</div>
		
		<#if screen.getSTATUS() == "showMatrix" >
			<div id="messageForm"></div>
			<div id="tableViewer">
				<#if screen.getTableView()??>
					${screen.getTableView()}
				</#if>
			</div>
			<input type="button" id="uploadFileButton" style="font-size:0.6em;color:#03406A;" value="upload" />
			<div id="uploadFileForm" style="display:none">
				<fieldset style="border-radius:0.2em;width:90%;font-size:12px">
		        	<label for="project"> Select the project:&nbsp;&nbsp;</label>
						<select name="project" id="project" style="margin-right:5px"> 
						<option value=""/>
							<#list screen.projects as project>
							<option value="${project}">${project}</option>			
							</#list>
						</select>
					<br />
		        	<input style="font-size:10px" id="createNewInvest" type="checkbox" name="createNewInvest">Create new project
	           		<input type="text" id="newInvestigation" name="newInvestigation" disabled="disabled"/>
	            </fieldset>
			    <fieldset style="border-radius:0.2em;width:90%;font-size:12px">
					<label >Upload a csv file</label><br>
			    	<input type="file" id="uploadFileName" name="uploadFileName" style="font-size:12px"/> 
			    </fieldset>
	            <fieldset style="border-radius:0.2em;width:300px;">
		            <input id="fileUploadNext" type="button" style="font-size:0.5em;color:#03406A" value="Next" />
		            <input id="fileUploadCancel" type="button" style="font-size:0.5em;color:#03406A" value="Cancel"/>
	            </fieldset>
			    	
		    	<#if screen.getUploadFileErrorMessage()??>
					<script>
						$('#messageForm').empty();
						errorMessage = "<p style=\"color:red\"><i>${screen.getUploadFileErrorMessage()}  " + 
							"<input type=\"button\" id=\"closeErrorMessage\" value=\"Close\" /></i></p>";
						$('#messageForm').append(errorMessage);
						$('#closeErrorMessage').click(function(){$('#messageForm').empty();});
					</script>
				</#if>
				<#if screen.getImportMessage()??>
					<script>
						$('#messageForm').empty();
						if("${screen.getImportMessage()}" == "success"){
							errorMessage = "<p style=\"color:green\"><i>Your import has been successful! You can now upload a new file</br>"
						}else{
							errorMessage = "<p style=\"color:red\"><i>${screen.getImportMessage()}</br>"
						}
						
						errorMessage += "<input type=\"button\" id=\"closeErrorMessage\" value=\"Close\" /></i></p>";
						$('#messageForm').append(errorMessage);
						$('#closeErrorMessage').click(function(){
							$('#messageForm').empty();
							$.ajax("${screen.getUrl()}&__action=download_json_removeMessage").done();
						});
					</script>
				</#if>
			</div>
    	<#elseif screen.getSTATUS() == "CheckFile">
    		<div id="summaryPage">
	    		<div id="newColumnsMapping" style="display:none"></div>
	    		<div id="reportForm">
	    			<fieldset>
	    				<table style="width:100%;">
		    				<tr><td id="reportContent" style="width:50%;font-size:22px">
				    			<div id="existingColHeaders" style="cursor:pointer" value="existing columns"></div>
				    			<div id="newColHeaders" style="cursor:pointer" value="new columns"></div>
				    			<div id="existingRowRecords" style="cursor:pointer" value="existing records"></div>
				    			<div id="newRowRecords" style="cursor:pointer" value="new records"></div>
				    		</td><td id="notification" style="width:50%;font-size:22px"></td></tr>
		    			</table>
	    			</fieldset>
	    			<fieldset id="controlPanel">
	    				<input type="button" name="preview" id="preview" value="Preview"  
	    					style="font-size:0.6em;color:#03406A"/>
						<input type="submit" name="importUploadFile" id="importUploadFile" value="Next"  
							style="font-size:0.6em;color:#03406A" onclick="__action.value='importUploadFile';return true;"/>
	    				<input type="submit" name="uploadNewFile" id="uploadNewFile" value="Upload a new file" 
	    					style="font-size:0.6em;color:#03406A" onclick="__action.value='showMatrix';return true;"/>
	    			</fieldset>
	    			<script>
	    				<#if screen.getReport()??>
	    					generateReport(${screen.getReport()});
	    				</#if>
	    				<#if screen.getJsonForMapping()??>
							$('#newColHeaders').trigger('click');
						</#if>
						<#if screen.getMappingMessage()??>
							$('#newColHeaders').trigger('click');
						</#if>
	    			</script>
	    		</div>
    		</div>
    		<div id="showPreviewedTable" style="display:none">
    			<div id="previewedTable"></div>
    			<fieldset id="controlPanelForImporting">
					<input type="button" name="previousStepSummary" id="previousStepSummary" value="Previous"  
	    					style="font-size:0.6em;color:#03406A"/>
					<input type="submit" name="uploadNewFileSecond" id="uploadNewFileSecond" value="Upload a new file" 
						style="font-size:0.6em;color:#03406A" onclick="__action.value='showMatrix';return true;"/>
				</fieldset>
    		</div>
    	<#elseif screen.getSTATUS() == "previewFile">
    		<#if screen.getTableView()??>${screen.getTableView()}</#if>
    		<fieldset id="controlPanelForImporting">
				<input type="submit" name="previousStepSummary" id="previousStepSummary" value="Previous"  
    					style="font-size:0.6em;color:#03406A" onclick="__action.value='previousStepSummary';return true;"/>
				<input type="submit" name="uploadNewFile" id="uploadNewFile" value="Upload a new file" 
					style="font-size:0.6em;color:#03406A" onclick="__action.value='uploadNewFile';return true;"/>
			</fieldset>
    	<#elseif screen.getSTATUS() == "mappingVariables">
    		<div id="newColumnsMapping" style="display:none"></div>
    	</#if>
	</div>
</form>
</#macro>