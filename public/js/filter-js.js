"use strict";

function loadFilters(){
  let filtersDiv = _('filters-div');
  const filtersButton = $('.filter-button');
  filtersDiv.style.display = 'block';
  filtersButton.attr('onclick', 'hideFilters()');
}

function hideFilters(){
  let filtersDiv = _('filters-div');
  const filtersButton = $('.filter-button');
  filtersDiv.style.display = 'none';
  filtersButton.attr('onclick', 'loadFilters()');
}

function updateFilter(e){
  let eventCause = document.querySelectorAll('.' + e.target.className + ' input');
  if(e.target.checked){
    eventCause.forEach(item => {
      item.disabled = false;
      if (item.value == "others"){
        item.disabled = true;
      }
    })
  } else {
    eventCause.forEach(item => {
      item.disabled = true;
      if (item.type == "text"){
        item.value = '';
      }
      if (item.value == "others"){
        item.disabled = true;
      }
    })
  }
}

window.onload = function () {
  document.querySelectorAll('legend input').forEach(item => {
    item.addEventListener('change', updateFilter);
  })
}
