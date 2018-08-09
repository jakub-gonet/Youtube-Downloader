export const EventListeners = {
  add_event_listeners: function () {
    add_overlayable_onclicks();
    add_select_all_onclick();
  }
};

function add_overlayable_onclicks() {
  let overlayables = document.querySelectorAll(".overlayable");
  overlayables.forEach(function (item) {
    item.addEventListener('click', function () {
      toggle_selected(item);
    });
  });
}

function add_select_all_onclick() {
  let select = document.querySelector("#selectAll");
  let overlayables = document.querySelectorAll(".overlayable");

  select.addEventListener('click', function () {
    overlayables.forEach(function (item) {
      toggle_selected(item);
    });
  });
}

function toggle_selected(overlayable) {
  overlayable.querySelector(".overlay").classList.toggle("selected");
  let selected = overlayable.querySelector("input[type='checkbox']")
  selected.checked = selected.checked ? false : true;
}