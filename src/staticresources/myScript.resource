
    function showFieldList(objectName){
        //console.log(document.getElementById('{!$Component.pageBlock}'));
        // console.log(objectName);
        showFields(objectName);
        return false;
    }
    function showFieldParamList (fieldName) {
        console.log(fieldName);
        showFieldParams(fieldName);
        return false;
    }

    //select tab onclick
    var $ = jQuery.noConflict();

    $(document).ready(function(){

        $('.tabs_menu li').click(function(){
            if($('.tabs_menu li').hasClass('slds-is-active')){
                $('.tabs_menu li').removeClass('slds-is-active');
                $(this).addClass('slds-is-active');
            }
            var i = $(this).index(); // get number selected tab

            var tab = $(".tabs").children(".slds-tabs_default__content")[i];//select div for clicked tab
            if($(tab).hasClass('slds-hide')){
                $($(".tabs").children(".slds-tabs_default__content")).removeClass('slds-show').addClass('slds-hide');
                $(tab).addClass('slds-show').removeClass('slds-hide');
            }
        });
    });
//SECOND TAB, SCRIPT MOVE SELECTED FIELDS

    var arrayOfSelectedLeftFieldsOnClick        = [];//array of clicked field in left column
    var arrayOfSelectedRightFieldsOnClick       = [];//array of clicked field in right column
    var arrayOfInnerLeftValues                  = []; //Array of inner value li
    var arrayOfInnerRightValues                 = []; //Array of inner value li
    var arrayOfLeftIndex                        = [];//index of element in left column array
    var arrayOfRightIndex                       = [];//index of element in right column array
    var leftColumnValues;
    var rightColumnValues;

    //GET ARRAY OF SELECTED FIELDS IN LEFT COLUMN
    // createLeftValueArray();

    //GET ARRAY OF SELECTED FIELDS IN LEFT COLUMN
    function createLeftValueArray() {

        leftColumnValues = document.querySelectorAll('#leftColumn .slds-listbox__item');
        sortByName();
        for (var i = 0; i<leftColumnValues.length; i++){

            arrayOfInnerLeftValues.push(leftColumnValues[i].innerHTML);

            leftColumnValues[i].onclick = function () {
                //ADD STYLE TO SELECTED FIELD
                if(this.style.fontWeight !== "bold") {
                    this.style.fontWeight = "bold";
                    arrayOfSelectedLeftFieldsOnClick.push(this.innerHTML);
                    arrayOfLeftIndex.push(arrayOfInnerLeftValues.indexOf(this.innerHTML));
                } else {
                    this.style.fontWeight = "normal";
                    arrayOfSelectedLeftFieldsOnClick.pop(this.innerHTML);
                    arrayOfLeftIndex.pop(arrayOfInnerLeftValues.indexOf(this.innerHTML));
                }
            }
        }
    }

    //GET ARRAY OF SELECTED FIELDS IN RIGHT COLUMN
    function createRightValueArray() {

        rightColumnValues = document.querySelectorAll('#rightColumn .slds-listbox__item');
        sortByName();
        for (var i = 0; i<rightColumnValues.length; i++){

            arrayOfInnerRightValues.push(rightColumnValues[i].innerHTML);

            rightColumnValues[i].onclick = function () {
                //ADD STYLE TO SELECTED FIELD
                if(this.style.fontWeight !== "bold") {
                    this.style.fontWeight = "bold";
                    arrayOfSelectedRightFieldsOnClick.push(this.innerHTML);
                    arrayOfRightIndex.push(arrayOfInnerRightValues.indexOf(this.innerHTML));
                } else {
                    this.style.fontWeight = "normal";
                    arrayOfSelectedRightFieldsOnClick.pop(this.innerHTML);
                    arrayOfRightIndex.pop(arrayOfInnerRightValues.indexOf(this.innerHTML));
                }
            }
        }
    }


    //MOVE SELECTED VALUE FROM LEFT COLUMN TO RIGHT COLUMN
    function moveToRight() {

        for (var i = 0; i<arrayOfSelectedLeftFieldsOnClick.length; i++){

            var li              = document.createElement('li');
            li.className        = "slds-listbox__item";
            li.innerHTML        = arrayOfSelectedLeftFieldsOnClick[i];
            rightColumn.appendChild(li);
        }
        arrayOfSelectedLeftFieldsOnClick = [];

        for (var i = 0; i<arrayOfLeftIndex.length; i++){

            leftColumnValues[arrayOfLeftIndex[i]].parentNode.removeChild(leftColumnValues[arrayOfLeftIndex[i]]);
        }

        arrayOfLeftIndex = [];
        arrayOfInnerLeftValues = [];
        arrayOfInnerRightValues = [];

        createLeftValueArray();
        createRightValueArray();
    }

    //MOVE ALL VALUE FROM LEFT COLUMN TO RIGHT COLUMN
    function moveAllToRight() {

        leftColumnValues  = document.querySelectorAll('#leftColumn .slds-listbox__item');

        for (var i = 0; i<leftColumnValues.length; i++){

            var li              = document.createElement('li');
            li.className        = "slds-listbox__item";
            li.innerHTML        = leftColumnValues[i].innerHTML;
            rightColumn.appendChild(li);

        }

        for (var i = 0; i<leftColumnValues.length; i++){
            leftColumnValues[i].parentNode.removeChild(leftColumnValues[i]);
        }

        arrayOfInnerRightValues = [];

        createRightValueArray();
    }


    //MOVE SELECTED VALUE FROM RIGHT COLUMN TO LEFT COLUMN
    function moveToLeft() {

        for (var i = 0; i<arrayOfSelectedRightFieldsOnClick.length; i++){

            var li              = document.createElement('li');
            li.className        = "slds-listbox__item";
            li.innerHTML        = arrayOfSelectedRightFieldsOnClick[i];
            leftColumn.appendChild(li);

        }

        arrayOfSelectedRightFieldsOnClick = [];

        for (var i = 0; i<arrayOfRightIndex.length; i++){

            rightColumnValues[arrayOfRightIndex[i]].parentNode.removeChild(rightColumnValues[arrayOfRightIndex[i]]);

        }

        arrayOfRightIndex = [];
        arrayOfInnerRightValues = [];
        arrayOfInnerLeftValues = [];

        createLeftValueArray();
        createRightValueArray();
    }

    //REMOVE ALL VALUE FROM RIGHT COLUMN TO LEFT COLUMN
    function moveAllToLeft() {

        rightColumnValues = document.querySelectorAll('#lrightColumn .slds-listbox__item');

        for (var i = 0; i<rightColumnValues.length; i++){

            var li              = document.createElement('li');
            li.className        = "slds-listbox__item";
            li.innerHTML        = rightColumnValues[i].innerHTML;
            leftColumn.appendChild(li);

        }

        for (var i = 0; i<rightColumnValues.length; i++){
            rightColumnValues[i].parentNode.removeChild(rightColumnValues[i]);
        }
        arrayOfInnerLeftValues = [];

        createLeftValueArray();
    }
    function sortByName(){
        var leftLiValues    = [];
        var leftLi          = document.getElementById('leftColumn').getElementsByClassName('slds-truncate');

        var rightLiValues    = [];
        var rightLi          = document.getElementById('rightColumn').getElementsByClassName('slds-truncate');

//SORTING LEFT UL

        for (var i=0; i<leftLi.length; i++){
            leftLiValues[i] = leftLi[i].innerHTML;
        }

        leftLiValues.sort();

        for (var i=0; i < leftLi.length; i++){
            leftLi[i].innerHTML = leftLiValues[i];
        }
//SORTING RIGHT UL

        for (var i=0; i<rightLi.length; i++){
            rightLiValues[i] = rightLi[i].innerHTML;
        }

        rightLiValues.sort();

        for (var i=0; i < rightLi.length; i++){
            rightLi[i].innerHTML = rightLiValues[i];
        }
    }
