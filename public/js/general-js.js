"use strict";

var pedoCounter = 0;

function _(el){
 return document.getElementById(el);
}

function showMenu(){
  const menuButton = $('#menu-icon');
  pedoCounter++;
  if (pedoCounter >= 3){
    callForPedobear();
  }
  _('menu-div').style.transform = 'rotate(-15deg)';
  menuButton.attr('onclick', 'hideMenu()');
}

function hideMenu(){
  const menuButton = $('#menu-icon');
  _('menu-div').style.transform = 'rotate(0deg)';
  _('pedoEasterEgg').style.transform = 'rotate(0deg)';
  _('micheEasterEgg').style.transform = 'rotate(0deg)';
  menuButton.attr('onclick', 'showMenu()');
}

function callForPedobear(){
  _('pedoEasterEgg').style.transform = 'rotate(50deg)';
  _('second-egg').style.display = 'block';
  _('second-egg').style.top = '80vh';
}

function showMiche(){
  _('pedoEasterEgg').style.transform = 'rotate(0deg)';
  _('micheEasterEgg').style.transform = 'rotate(80deg)';
}
