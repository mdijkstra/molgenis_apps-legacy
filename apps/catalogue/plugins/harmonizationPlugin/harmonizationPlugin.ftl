<#macro plugins_harmonizationPlugin_harmonizationPlugin screen>
<style type="text/css">
.insertTable{
	background-color:#d0e4fe;
}

.HighLightTR.highlight {
	margin: 0px;
	border: 0px;
	padding: 0px;
	background-image: none;
	background-color: transparent;
	padding-left: 3px;
}

</style>


<script type="text/javascript">
function addingTable(tableId){
	
	if(map.get(tableId) != "null"){
		document.getElementById('details').innerHTML += map.get(tableId);
		document.getElementById(tableId + " table").style.display = "none";		
	}
}

function insertTable(tableId){
	
	var table = document.getElementById(tableId);
	
	if(table.style.display == "none") {
    		table.style.display = "inline";
  	} else {
		table.style.display = "none";
	}
	
}

function refreshByHits(){
	
	var hits = document.getElementById('changeHits').value;
	var divForTable = document.getElementById('details');
	var tables = divForTable.getElementsByTagName('table');	
	
	for(var i = 0; i < tables.length; i++){
		
		var eachTable = tables[i];
		
		var rowElements = eachTable.getElementsByTagName('tr');
		
		for(var j = 0; j < rowElements.length; j++){
			
			if(j < hits){
				rowElements[j].style.display = "table-row";
			}else{
				rowElements[j].style.display = "none";
			}
		}
	}
}

function setValidationStudy(validationStudyName){
	
	var dropBox = document.getElementById("validationStudy");
	
	var options = dropBox.getElementsByTagName("option");
	
	for(var i = 0; i < options.length; i++){
		
		if(options[i].value == validationStudyName){
			
			dropBox.selectedIndex = i;
		}
	}
}

function checkFileExisting(){

	if(!document.getElementById("ontologyFileForAlgorithm").value){
    	alert("No file selected");
    	 return false;
    }else{
    	 return true;
    }
}

</script>
<!-- normally you make one big form for the whole plugin-->
<form method="post" enctype="multipart/form-data" id="plugins_catalogueTree_catalogueTreePlugin" name="${screen.name}" action="">
	<!--needed in every form: to redirect the request to the right screen-->
	<input type="hidden" name="__target" value="${screen.name}">
	<!--needed in every form: to define the action. This can be set by the submit button-->
	<input type="hidden" name="__action" id="test" value="">
	<!-- hidden input for measurementId -->
	<input type="hidden" name="measurementId" id="measureId" value="">
	<input type="hidden" name="DemoName" id="DemoName" value="%= demoName %">
	
<!-- this shows a title and border -->


	<div class="formscreen">
		<div class="form_header" id="${screen.getName()}">
			${screen.label}
		</div>
		
		<#--optional: mechanism to show messages-->
		<#list screen.getMessages() as message>
			<#if message.success>
		<p class="successmessage">${message.text}</p>
			<#else>
		<p class="errormessage">${message.text}</p>
			</#if>
		</#list>
		
		<div class="screenbody">
			<div class="screenpadding">
				
				<#if screen.getDevelopingAlgorithm() == true>
					
					Please choose an ontology file and algorithm will be automatically generated </br></br>
					
					<table width="100%">
						<tr>
							<td class="box-body" style="width:50%;">
								1. Choose a validation study
								<select name="validationStudy" id="validationStudy"> 
									<#list screen.arrayInvestigations as inv>
										<#assign invName = inv.name>
											<option value="${invName}" <#if screen.selectedInvestigation??><#if screen.selectedInvestigation == invName>selected="selected"</#if></#if> >${invName}</option>			
									</#list>
								</select></br></br>
								<script>
									setValidationStudy('${screen.getValidationStudyName()}');
									$('#validationStudy').chosen();
								</script>
								2. Please upload your ontology (compulsory)</br></br>
								<input type="file" id = "ontologyFileForAlgorithm" name = "ontologyFileForAlgorithm"/></br></br>
								
								<input type="submit" value="generate algorithm" id="continue" name="continue" onclick="__action.value='generateAlgorithm';return checkFileExisting();" />
								
								<input type="submit" value="back to mapping" id="backToMapping" name="backToMapping" onclick="__action.value='backToMapping';" />
							</td>
							<td class="box-body" style="width:50%;">
								<p align="justify" style="font-family:arial;margin-left:20px;font-size:12px;">${screen.getMessageForAlgorithm()}</p>
							</td>
						</tr>
					</table>
					
					
					
				<#else>
				
					<#if screen.isSelectedInv() == true>
						<table class="box" width="100%" cellpadding="0" cellspacing="0">
							<tr><td class="box-header" colspan="1">  
									<label>Choose a prediction model:
									<select name="investigation" id="investigation"> 
										<#list screen.arrayInvestigations as inv>
											<#assign invName = inv.name>
												<option value="${invName}" <#if screen.selectedInvestigation??><#if screen.selectedInvestigation == invName>selected="selected"</#if></#if> >${invName}</option>			
										</#list>
									</select>
									<script>$('#investigation').chosen();</script>
									<!--input type="submit" name="chooseInvestigation" value="refresh tree" onclick="__action.value='chooseInvestigation';"></input-->
									<input type="image" src="res/img/refresh.png" alt="Submit" 
										name="chooseInvestigation" style="vertical-align: middle;" 
										value="refresh tree" onclick="__action.value='chooseInvestigation';DownloadMeasurementsSubmit.style.display='inline'; 
										DownloadMeasurementsSubmit.style.display='inline';" title="load another study"	/>	
									</label>
									<div id="masstoggler"> 	
										<label>Browse protocols and their variables '${screen.selectedInvestigation}':click to expand, collapse or show details</label>
								 			<a title="Collapse entire tree" href="#"><img src="res/img/toggle_collapse_tiny.png"  style="vertical-align: bottom;"></a> 
								 			<a title="Expand entire tree" href="#"><img src="res/img/toggle_expand_tiny.png"  style="vertical-align: bottom;"></a> 
					 				</div>
								</td>
						    	<td class="box-header" colspan="2">
						    		<label>Choose a validation study:
									<select name="validationStudy" id="validationStudy"> 
										<#list screen.arrayInvestigations as inv>
											<#assign invName = inv.name>
											<option value="${invName}" <#if screen.selectedInvestigation??><#if screen.selectedInvestigation == invName>selected="selected"</#if></#if> >${invName}</option>			
										</#list>
									</select></br></br>
									<script>
										setValidationStudy('${screen.getValidationStudyName()}');
										$('#validationStudy').chosen();
									</script>
									</br>
									Tick the box if this is baseline data<input type="checkbox" name="baseline" id="baseline"/>
						    	</td>
						    </tr>
						    <tr>
						    	<td class="box-body" style="width:50%;">
							
									Please upload your ontology file to extend your query (optional)<br/><br/>
									<input type="file" name = "ontologyFile"/>	    
						    
						    	</td>
						    	<td class="box-body" style="width: 50%;">
								</td>
							</tr>
						    <tr>
						    	<td class="box-body">
									<div id="leftSideTree">  
										${screen.getTreeView()}
									</div><br/>
							    </td>
							    
							    <td class="box-body">
							    	<!--div id="scrollingDiv"--> 
	      								<div id="details">
	      									
	      									${screen.getHitSizeOption()}
	      									
	      								</div><br/><br/>
	      							<!--/div-->
	
							   </td>
							</tr>
							<tr>
								<td class="box-body">
									<input class="saveSubmit" type="submit" id="startMatching" name="startMatching" value="Matching" 
										onclick="__action.value='startMatching';" 
										style="color: #000; background: #8EC7DE;
											   border: 2px outset #d7b9c9;
											   font-size:15px;
											   font-weight:bold;"/>
									<input type="submit" value="Algorithm" id="switchToAlgorithm" name="switchToAlgorithm" 
										onclick="__action.value='switchToAlgorithm';" 
										style="color: #000; background: #8EC7DE;
											   border: 2px outset #d7b9c9;
											   font-size:15px;
											   font-weight:bold;"/>	
								</td>
								<td class="box-body">
								<input class="saveMapping" type="submit" id="saveMapping" name="saveMapping" value="save Mapping" 
										onclick="__action.value='saveMapping';" 
										style="color: #000; background: #8EC7DE;
											   border: 2px outset #d7b9c9;
											   font-size:15px;
											   font-weight:bold;"/></td>
								
							</tr>
						</table>
						
						<#list screen.getListOfParameters() as parameter>
							<script>
								addingTable('${parameter}');
							</script>
						</#list>
						<script>
							refreshByHits();
						</script>
						<#list screen.getExecutiveScript() as executiveScript>
								${executiveScript}
							</#list>
				   </#if>
			   </#if>	
			</div>
		</div>
	</div>
</form>
</#macro>
