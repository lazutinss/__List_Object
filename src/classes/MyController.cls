public with sharing class MyController {
    public String                   selectedObject      {get;set;} // OBJECT NAME
    public String                   clickedFieldName    {get;set;}//FIELD NAME ONCLICK
    public String                   fieldLabel          {get;set;}//FIELD LABEL ONCLICK
    public String                   fieldName           {get;set;}//NAME NEW FIELD
    public Boolean                   showBlockAddField  {get; set;}//FLAG SHOW ADD FIELD
    public String                   selectedDeleteField {get; set;}//SELECTED DELETE CUSTOM FIELD
    public Schema.DisplayType       fieldType {get;set;}//FIELD TYPE ONCLICK
    public List<String>             fieldsNameList {get;set;}//LIST OF left OBJECT FIELDS
    public List<String>             customFieldsNameList {get;set;}//LIST OF OBJECT CUSTOM FIELDS
    public List<fieldParamClass>    fieldNameClickList{get;set;}//LIST OF OBJECT FIELD PARAM
    public List<fieldParamClass>    fieldsParamList{get;set;}//LIST OF ADDING SELECTED FIELD PARAM

    public List<String>             leftFieldSelected{get; set;}//LIST SELECTED FIELDS LEFT BLOCK
    public List<string>             rightFieldSelected{get;set;}//LIST SELECTED FIELDS RIGHT BLOCK
    public Set<string>              leftValues = new Set<string>();//VALUES FORMED IN LEFT BLOCK
    public Set<string>              rightValues = new Set<string>();//VALUES FORMED IN LEFT BLOCK

    public MyController(){
        fieldsParamList         = new List<fieldParamClass>();
        System.debug('fieldsParamList in contr' + fieldsParamList);
        showBlockAddField       = false;
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
        fieldsParamList.clear();
        rightValues.clear();
        leftValues.clear();
        fieldsNameList = new List<String>();
        customFieldsNameList = new List<String>();

        Map<String, Schema.SObjectType> globalDescription   = Schema.getGlobalDescribe();
        Schema.sObjectType objType                          = globalDescription.get(selectedObject);
        Schema.DescribeSObjectResult r1                     = objType.getDescribe();
        Map<String , Schema.SObjectField> mapFieldList      = r1.fields.getMap();

        for(Schema.SObjectField field : mapFieldList.values()){

            Schema.DescribeFieldResult fieldResult = field.getDescribe();

                if(String.valueOf(fieldResult.getName()).endsWith('__c')){
                    customFieldsNameList.add(fieldResult.getName());//заменить на метож custom
                }
            fieldsNameList.add(fieldResult.getName());
        }

        for (Schema.SObjectField leftField : mapFieldList.values()) {

            Schema.DescribeFieldResult fieldResult = leftField.getDescribe();
            leftValues.add(fieldResult.getName());
        }
    }

//SHOW FIELD PARAMERTRES
    public void showFieldParam() {
        clickedFieldName = ApexPages.CurrentPage().getParameters().get('clickedFieldName');
        Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(selectedObject, clickedFieldName);
        fieldLabel = fieldDescribe.getLabel();
        fieldType = fieldDescribe.getType();

        fieldNameClickList = new List<fieldParamClass>();
        fieldNameClickList.add(new fieldParamClass(clickedFieldName, fieldLabel, fieldType));

        for (fieldParamClass key : fieldNameClickList){
            fieldsParamList.add(key);
            System.debug('fieldsParamList in showFieldParam' + fieldsParamList);
        }

    }

    public Schema.DescribeFieldResult getFieldDescribe(String objectName, String field){
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        return  fMap.get(field).getDescribe();
    }
    //FLAG TO RENDERED TABLE OF FIELDS PARAM
    public Boolean getFieldParamListNotEmpty() {

        return fieldsParamList.size() > 0;
    }
//SHOW ADDFIELDBLOCK
    public void showCreateBlock(){
        showBlockAddField = true;
    }

//CREATE NEW FIELD
    public void createField(){
        //System.debug('имя объекта  '+selectedObject+'; имя поля '+fieldName);
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();

        service.SessionHeader           = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();

        List<MetadataService.Metadata>  fields      = new List<MetadataService.Metadata>();
        MetadataService.CustomField     customField = new MetadataService.CustomField();

        customField.fullName        = selectedObject + '.' + fieldName + '__c';
        customField.label           = fieldName;
        customField.defaultValue    = 'false';
        customField.type_x          = 'Checkbox';

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
        service.deleteMetadata('CustomField', new String[] { selectedObject + '.' + selectedDeleteField });

    }
//WRAPPER FOR FIELD LIST PARAM
         public class fieldParamClass{

             public String               clickedFieldName {get;set;}//FIELD NAME ONCLICK
             public String               fieldLabel {get;set;}//FIELD LABEL ONCLICK
             public Schema.DisplayType   fieldType {get;set;}//FIELD TYPE ONCLICK

            public fieldParamClass(String clickedFieldName, String fieldLabel, Schema.DisplayType fieldType){
               this.clickedFieldName    = clickedFieldName;
               this.fieldLabel          = fieldLabel;
               this.fieldType           = fieldType;
            }
         }


//================================TAB 2==============================================
    public PageReference selectClick() {
        rightFieldSelected.clear();
        for(String leftSelectList : leftFieldSelected){
            leftValues.remove(leftSelectList);
            rightValues.add(leftSelectList);
        }
        return null;
    }

    public PageReference selectAllClick() {
        rightFieldSelected.clear();
        rightValues.addAll(leftvalues);
        leftvalues.clear();
        return null;
    }

    public PageReference unSelectClick() {
        leftFieldSelected.clear();
        for (String rightSelectList : rightFieldSelected  ) {
            rightValues.remove(rightSelectList);
            leftValues.add(rightSelectList);
        }
        return null;
    }

    public PageReference unSelectAllClick() {
        leftFieldSelected.clear();
        leftValues.addAll(rightValues);
        rightValues.clear();
        return null;
    }

   // LIST OF SELECTED OBJECT FIELDS - LEFT BLOCK
    public List<SelectOption> getLeftBlockFields(){

        List<SelectOption> leftValues =  makeValueOfFieldsList(leftValues);
        return leftValues;
    }
    // LIST OF SELECTED OBJECT FIELDS - RIGHT BLOCK
    public List<SelectOption> getRightBlockFields(){

        List<SelectOption> leftValues =  makeValueOfFieldsList(rightValues);
        return leftValues;
    }

    //COMMON METHOD TO GET VALUE OF LEFT AND RIGHT COLUMN OF FIELDS
    public List<SelectOption> makeValueOfFieldsList(Set<string> valueOfColumn){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();

        tempList.addAll(valueOfColumn);
        tempList.sort();

        for(String fieldItem : tempList){
            options.add(new SelectOption(fieldItem, fieldItem));
        }

        return options;
    }


}