$(function() {
  $(window).scroll(function() {
    if ($(this).scrollTop() > 1) $('.container').addClass("sticky");
    else $('.container').removeClass("sticky");
  });
});