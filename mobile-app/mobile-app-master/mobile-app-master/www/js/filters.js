angular.module('appFilters', [])

    .filter('listFilter', function() {
        return function(list,filters) {

            var tempList =[];
            if(list.length>0){
                angular.forEach(list,function(item){
                    angular.forEach(filters,function(fItem){
                        if(fItem.label===item.name && fItem.val){
                            tempList.push(item);
                        }
                    })
                })
            }

            return tempList.length===0?list:tempList;
        }

});