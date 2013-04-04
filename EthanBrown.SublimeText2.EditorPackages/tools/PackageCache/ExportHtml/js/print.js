/*jshint globalstrict: true*/
"use strict";

function page_print() {
    var element = document.getElementById("toolbarhide");
    if (element != null) {
        element.style.display = "none";
    }
    if (window.print) {
        window.print();
    }
    if (element != null) {
        element.style.display = "block";
    }
}
