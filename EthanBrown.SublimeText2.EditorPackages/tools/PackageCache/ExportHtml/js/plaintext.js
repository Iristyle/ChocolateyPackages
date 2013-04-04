/*jshint globalstrict: true*/
"use strict";

var plain_text_clone = null;

function toggle_plain_text() {
    var lines = document.querySelectorAll("td.code_line"),
        line_len = lines.length,
        text = "",
        plain_pre = document.querySelectorAll("pre.simple_code_page"),
        orig_pre, pre, i, j, spans, span_len, span;
    if (plain_pre.length > 0) {
        document.body.removeChild(plain_pre[0]);
        document.body.appendChild(plain_text_clone);
        document.body.className = "code_page";
    } else {
        for (i = 0; i < line_len; i++) {
            spans = lines[i].querySelectorAll("span.real_text");
            span_len = spans.length;
            for (j = 0; j < span_len; j++) {
                span = spans[j];
                if ("textContent" in span) {
                    text += span.textContent;
                } else {
                    text += span.innerText;
                }
            }
            text += "\n";
        }
        orig_pre = document.querySelectorAll("pre.code_page")[0];
        plain_text_clone = orig_pre.cloneNode(true);
        pre = document.createElement('pre');
        pre.className = "simple_code_page";
        pre.appendChild(document.createTextNode(text));
        document.body.removeChild(orig_pre);
        document.body.appendChild(pre);
        document.body.className = "simple_code_page";
    }
}
