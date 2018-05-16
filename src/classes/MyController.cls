public with sharing class MyController {
    public String               selectedObj{get;set;} // OBJECT NAME
    public String               clickedFieldName {get;set;}//FIELD NAME ONCLICK
    public String               fieldLabel {get;set;}//FIELD LABEL ONCLICK
    public String               fieldName{get;set;}//NAME NEW FIELD
    public Boolean              showFields{get; set;}//FLAG SHOW FIELDS
    public String               showBlockFieldParam{get; set;}//FLAG SHOW FIELD PARAM
    public String               showBlockAddField{get; set;}//FLAG SHOW ADD FIELD
    public String               selectedDeleteField{get; set;}//SELECTED DELETE CUSTOM FIELD
    public Schema.DisplayType   fieldType {get;set;}//FIELD TYPE ONCLICK
    public List<String>         fieldsNameList {get;set;}//LIST OF left OBJECT FIELDS
    public List<String>         customFieldsNameList {get;set;}//LIST OF OBJECT CUSTOM FIELDS
    public List<String>         fieldNameClickList{get;set;}//LIST OF OBJECT FIELD PARAM
    public List<List<String>>   FieldsParamList{get;set;}//LIST OF LIST fieldNameClickList - поменять название

    public List<String>         leftFieldSelected{get; set;}//LIST SELECTED FIELDS LEFT BLOCK
    public List<string>         rightFieldSelected{get;set;}//LIST SELECTED FIELDS RIGHT BLOCK
    Set<string>                 leftValues = new Set<string>();//VALUES FORMED IN LEFT BLOCK
    Set<string>                 rightValues = new Set<string>();//VALUES FORMED IN LEFT BLOCK

    public MyController(){
        FieldsParamList         = new List<List<String>>();
        showFields              = false;
        showBlockFieldParam     = 'No';
        showBlockAddField       = 'No';
    }


    //LIST OF OBJECTS
    public List<SelectOption> getObjects(){
        List<Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe().Values();
        List<SelectOption> listOfObject = new List<SelectOption>();

            for(Schema.SObjectType keyListName : globalDescribe){
                listOfObject.add(new SelectOption(keyListName.getDescribe().getName(),keyListName.getDescribe().getName()));
            }
        return listOfObject;
    }

//===============================================TAB1=========================

//LIST OF OBJECT FIELDS
    public void showListFields(){
        showFields = true;
        FieldsParamList.clear();
        rightValues.clear();
        leftValues.clear();
        fieldsNameList = new List<String>();
        customFieldsNameList = new List<String>();
        Map<String, Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        //System.debug('Selected Object is ' + obj);
        Schema.sObjectType objType = globalDescription.get(selectedObj);
        //System.debug('Выбранный объект ' + objType);
        Schema.DescribeSObjectResult r1 = objType.getDescribe();
        Map<String , Schema.SObjectField> mapFieldList = r1.fields.getMap();
        //System.debug(mapFieldList);
            for(Schema.SObjectField field : mapFieldList.values()){

                Schema.DescribeFieldResult fieldResult = field.getDescribe();
                if(String.valueOf(fieldResult.getName()).endsWith('__c')){
                    //System.debug(fieldResult.getName());
                    customFieldsNameList.add(fieldResult.getName());//заменить на метож custom
                }
                fieldsNameList.add(fieldResult.getName());
            }
            for (Schema.SObjectField leftField : mapFieldList.values()) {

                Schema.DescribeFieldResult fieldResult2 = leftField.getDescribe();
                leftValues.add(fieldResult2.getName());
            }

    }

//SHOW FIELD PARAMERTRES
    public void showFieldParam() {
        fieldNameClickList = new List<String>();
        showBlockFieldParam = 'Yes';
        clickedFieldName = ApexPages.CurrentPage().getParameters().get('clickedFieldName');
        Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(selectedObj, clickedFieldName);
        fieldLabel = fieldDescribe.getLabel();
        fieldType = fieldDescribe.getType();
        fieldNameClickList.add(clickedFieldName);
        fieldNameClickList.add(fieldLabel);
        fieldNameClickList.add(String.valueOf(fieldType));
        FieldsParamList.add(fieldNameClickList);
    }

    public Schema.DescribeFieldResult getFieldDescribe(String objectName, String field){
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        return  fMap.get(field).getDescribe();
    }
//SHOW ADDFIELDBLOCK
    public void showCreateBlock(){
        showBlockAddField = 'Yes';
    }

//CREATE NEW FIELD
    public void createField(){
        //System.debug('имя объекта  '+selectedObj+'; имя поля '+fieldName);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        List<MetadataService.Metadata> fields = new List<MetadataService.Metadata>();
        MetadataService.CustomField customField = new MetadataService.CustomField();
        //customField.fullName = 'Account.myCustomField__c';
        customField.fullName = selectedObj + '.' + fieldName + '__c';
        //customField.label = 'MyTestField2';
        customField.label = fieldName;
        customField.defaultvalue = 'false';
        //customField.sharingModel = 'ReadWrite';
        customField.type_x = 'Checkbox';
        fields.add(customField);
        List<MetadataService.SaveResult> results = service.createMetadata(new MetadataService.Metadata[] { customField });

    }
//DELETE FIELD
    public void deleteField()
    {
        //System.debug(selectedDeleteField);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        List<MetadataService.DeleteResult> results =
        service.deleteMetadata('CustomField', new String[] { selectedObj + '.' + selectedDeleteField });

    }

//================================TAB 2==============================================
    public PageReference selectClick() {
        rightFieldSelected.clear();
        for(String leftSelectList : leftFieldSelected){
            leftvalues.remove(leftSelectList);
            rightvalues.add(leftSelectList);
        }
        return null;
    }

    public PageReference unselectClick() {
        leftFieldSelected.clear();
        for (String rightSelectList : rightFieldSelected  ) {
            rightvalues.remove(rightSelectList);
            leftvalues.add(rightSelectList);
        }
        return null;
    }

   // LIST OF SELECTED OBJECT FIELDS - LEFT BLOCK
    public List<SelectOption> getleftBlockFields(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftValues);
        tempList.sort();
            for (String key : tempList) {
                options.add(new SelectOption(key, key));
            }
        return options;
    }

    public List<SelectOption> getRightBlockFields(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightValues);
        tempList.sort();
            for(String s : tempList){
                options1.add(new SelectOption(s,s));
            }
        return options1;
    }
}