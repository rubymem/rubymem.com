//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require vendor/validator


$(document).ready(function () {
  $('#advisory-form').validator();

  $("#submit-review-link").on("click", function(e) {
    e.preventDefault();

    $("#submit-review").trigger("click");
  });
});

