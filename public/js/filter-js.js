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

function unlockValueFilters() {
  const checkBox = _('value-checkbox');
  const filterMin = _('valueMinInput');
  const filterMax = _('valueMaxInput');

  if (checkBox.checked == true){
    filterMin.disabled = false;
    filterMax.disabled = false;
  } else {
    filterMin.value = '';
    filterMax.value = '';
    filterMin.disabled = true;
    filterMax.disabled = true;
  }
}
