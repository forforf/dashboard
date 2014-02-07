var myApp = angular.module('myApp',[ 'RepoFetcherRatings']);

//myApp.directive('myDirective', function() {});
//myApp.factory('myService', function() {});

function RepoCtrl($scope, Repo) {

  $scope.graphConfig = {
  };

  function slicerFn(start, stop){
    return function(repos){
      console.log('slicey dicey');
      return(repos.slice(start, stop+1));
    };
  }

  $scope.name = 'Superhero';

  var initFilters = [
    {sort: 'name', per_page: 20}
  ];
  //var initFilters = [];

  var baseFilters = [
    slicerFn(8,12)
  ];

  var allFilters = initFilters.concat(baseFilters);

  initFromRepo = Repo.getBaseModel('forforf', allFilters, {init: true});

  function setSelectedRepos(repos){
    $scope.selectedRepos = repos;
    console.log(repos);
    return repos;
  }

  initFromRepo
    .then(setSelectedRepos);
}
