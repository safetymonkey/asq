var gon = gon;
var wordArray;
if (typeof gon !== 'undefined' && gon.view === 'static_pages#tag_cloud') {
  wordArray = gon.tag_array;
  $(function initCloud() {
    // When DOM is ready, select the container element and call the jQCloud
    // method, passing the array of words as the first argument.
    $('#tagcloud').jQCloud(wordArray);
  });
}
