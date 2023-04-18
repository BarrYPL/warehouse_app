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
  menuButton.attr('onclick', 'showMenu()');
}

function callForPedobear(){
  _('pedoEasterEgg').style.transform = 'rotate(50deg)';
}

var inactivityTime = function () {
  var time;
  window.onload = resetTimer;
  document.onmousemove = resetTimer;
  document.onkeydown = resetTimer;
  document.onscroll = resetTimer;

  function showMiche(){
    _('pedoEasterEgg').style.transform = 'rotate(0deg)';
    _('micheEasterEgg').style.transform = 'rotate(80deg)';
  }

  function hideMiche(){
    _('micheEasterEgg').style.transform = 'rotate(0deg)';
  }

  function resetTimer() {
    clearTimeout(time);
    hideMiche();
    time = setTimeout(showMiche, 20000);
  }
};

window.addEventListener("load", function(evt){
  inactivityTime();
  document.onclick = function(e){
    if (!((e.target.id == 'menu-icon') || (e.target.className == 'menu-block'))){
      hideMenu();
    }
  }
})
