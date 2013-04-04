/*jshint globalstrict: true*/
"use strict";

var page_line_info = {
        wrap:      false,
        ranges:    null,
        wrap_size: null,
        tables:    null,
        header:    null,
        gutter:    false
    };

function wrap_code() {
    var start, end, i, j, mode, idx,
        width = 0, el;
    if (page_line_info.header) {
        document.getElementById("file_info").style.width = page_line_info.wrap_size + "px";
    }
    for (i = 1; i <= page_line_info.tables; i++) {
        idx = i - 1;
        start = page_line_info.ranges[idx][0];
        end = page_line_info.ranges[idx][1];
        for(j = start; j < end; j++) {
            if (mode == null) {
                mode = true;
                if (page_line_info.gutter) {
                    width = document.getElementById("L_" + idx + "_" + j).offsetWidth;
                }
            }
            el = document.getElementById("C_" + idx + "_" + j);
            el.style.width = (page_line_info.wrap_size - width) + "px";
            el.className = "wrap";
        }
    }
}

function toggle_gutter() {
    var i, j, mode, rows, r, tbls, cells;
    tbls  = document.getElementsByTagName('table');
    for (i = 1; i <= page_line_info.tables; i++) {
        rows = tbls[i].getElementsByTagName('tr');
        r = rows.length;
        for (j = 0; j < r; j++) {
            cells = rows[j].getElementsByTagName('td');
            if (mode == null) {
                if (page_line_info.gutter) {
                    mode = 'none';
                    page_line_info.gutter = false;
                } else {
                    mode = 'table-cell';
                    page_line_info.gutter = true;
                }
            }
            cells[0].style.display = mode;
        }
    }
    if (page_line_info.wrap && mode != null) {
        setTimeout(function() {wrap_code();}, 500);
    }
}

function unwrap_code() {
    var i, j, idx, start, end, el;
    if (page_line_info.header) {
        document.getElementById("file_info").style.width = "100%";
    }
    for (i = 1; i <= page_line_info.tables; i++) {
        idx = i - 1;
        start = page_line_info.ranges[idx][0];
        end = page_line_info.ranges[idx][1];
        for(j = start; j < end; j++) {
            el = document.getElementById("C_" + idx + "_" + j);
            el.style.width = "100%";
            el.className = "";
        }
    }
}

function toggle_wrapping() {
    if (page_line_info.wrap) {
        page_line_info.wrap = false;
        unwrap_code();
    } else {
        page_line_info.wrap = true;
        wrap_code();
    }
}
