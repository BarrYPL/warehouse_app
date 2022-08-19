"use strict";

function _(el){
 return document.getElementById(el);
}

function showMenu(){
  const menuButton = $('#menu-icon');
  console.log("show menu");
  _('menu-div').style.transform = 'rotate(-15deg)';
  menuButton.attr('onclick', 'hideMenu()');
}

function hideMenu(){
  const menuButton = $('#menu-icon');
  console.log("hide menu");
  _('menu-div').style.transform = 'rotate(0deg)';
  menuButton.attr('onclick', 'showMenu()');
}
