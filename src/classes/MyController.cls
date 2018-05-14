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
    public List<String>         fieldsNameList {get;set;}//LIST OF OBJECT FIELDS
    public List<String>         customFieldsNameList {get;set;}//LIST OF OBJECT CUSTOM FIELDS
    public List<String>         fieldNameClickList{get;set;}//LIST OF OBJECT FIELD PARAM
    public List<List<String>>   allFieldsList{get;set;}//LIST OF LIST fieldNameClickList

    public MyController(){
        allFieldsList       = new List<List<String>>();
        showFields          = false;
        showBlockFieldParam = 'No';
        showBlockAddField   = 'No';
        //System.debug(showFields);
    }

//    public String getobj(){
//        return obj;
//    }
//    public void                 setobj(String obj){
//        this.obj = obj;
//    }
    //LIST OF OBJECTS
    public List<SelectOption> getObjects(){
        List<Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe().Values();
        List<SelectOption> listOfObject = new List<SelectOption>();

        for(Schema.SObjectType keyListName : globalDescribe){
            listOfObject.add(new SelectOption(keyListName.getDescribe().getName(),keyListName.getDescribe().getName()));
        }
        return listOfObject;
    }

//LIST OF OBJECT FIELDS
    public void showListFields(){
        showFields = true;
        allFieldsList.clear();
        //System.debug(showFields);
        fieldsNameList = new List<String>();
        customFieldsNameList = new List<String>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        //System.debug('Selected Object is ' + obj);
        Schema.sObjectType objType = globalDescription.get(selectedObj);
        //System.debug('Выбранный объект ' + objType);
        Schema.DescribeSObjectResult r1 = objType.getDescribe();
        Map<String , Schema.SObjectField> mapFieldList = r1.fields.getMap();
        //System.debug(mapFieldList);
        for(Schema.SObjectField field : mapFieldList.values())
        {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            if(String.valueOf(fieldResult.getName()).endsWith('__c')){
                //System.debug(fieldResult.getName());
                customFieldsNameList.add(fieldResult.getName());
            }
            fieldsNameList.add(fieldResult.getName());
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
        allFieldsList.add(fieldNameClickList);
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
        System.debug(selectedDeleteField);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        List<MetadataService.DeleteResult> results =
        service.deleteMetadata('CustomField', new String[] { selectedObj + '.' + selectedDeleteField });

    }
}