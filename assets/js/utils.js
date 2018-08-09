export const Utils = {
  select_if_checked: function () {
    let overlays = document.querySelectorAll(".overlayable");

    overlays.forEach((item) => {
      let checkbox = item.querySelector("input[type='checkbox']");
      let overlay = item.querySelector(".overlay");
      if (checkbox.checked) {
        overlay.classList.add("selected");
      }
      else {
        overlay.classList.remove("selected");
      }
    });
  }
};