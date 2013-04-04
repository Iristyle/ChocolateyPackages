/*jshint globalstrict: true*/
"use strict";

var win_attr = {
    get_center : function (dim) {
        var c = {
            'x' : (win_attr.get_size('x')/2),
            'y' : (win_attr.get_size('y')/2)
        };
        return ((dim) ? c[dim] : c);
    },

    get_size : function(dir) {
        dir = (dir === 'x') ? 'Width' : 'Height';
        return ((window['inner'+dir]) ?
            window['inner'+dir] :
            ((window.document.documentElement && window.document.documentElement['client'+dir]) ?
                window.document.documentElement['client'+dir] :
                window.document.body['client'+dir]
            )
        );
    }
},

position_el = {
    center : function (el, dim) {
        var c = win_attr.get_center(),
            top    = (c.y - (el.offsetHeight/2)),
            left   = (c.x - (el.offsetWidth/2));
        if (dim == null || dim === 'y') el.style.top  = (top < 0)  ? 0 + 'px' : top  + 'px';
        if (dim == null || dim === 'x') el.style.left = (left < 0) ? 0 + 'px' : left + 'px';
    },

    set : function (el, x, y) {
        var left, top;

        if (typeof x === "undefined") x = null;
        if (typeof y === "undefined") y = null;

        if (y === 'center') {
            position_el.center(el, 'y');
        } else if (y === 'top') {
            el.style.top = 0 + 'px';
        } else if (y === 'bottom') {
            top = (win_attr.get_size('y') - (el.offsetHeight));
            el.style.top = (top < 0) ? 0 + 'px' : top + 'px';
        } else if (y.match(/^[\d]+(%|px|em|mm|cm|in|pt|pc)$/) != null) {
            el.style.top = y;
        }

        if (x === "center") {
            position_el.center(el, 'x');
        } else if (x === 'left') {
            el.style.left = 0 + 'px';
        } else if (x === 'right') {
            left = (win_attr.get_size('x') - (el.offsetWidth));
            el.style.left = (left < 0) ? 0 + 'px' : left + 'px';
        } else if (x.match(/^[\d]+(%|px|em|mm|cm|in|pt|pc)$/) != null) {
            el.style.left = x;
        }
    }
};

function position_table(el) {
    var x, y,
        sel = document.getElementById('dock'),
        option = sel.options[sel.selectedIndex].value;
    switch(option) {
        case "0": x = 'center'; y = 'center';  break;
        case "1": x = 'center'; y = 'top';     break;
        case "2": x = 'center'; y = 'bottom';  break;
        case "3": x = 'left';   y = 'center';  break;
        case "4": x = 'right';  y = 'center';  break;
        case "5": x = 'left';   y = 'top';     break;
        case "6": x = 'right';  y = 'top';     break;
        case "7": x = 'left';   y = 'bottom';  break;
        case "8": x = 'right';  y = 'bottom';  break;
        default: break;
    }
    setTimeout(function () {position_el.set(el, x, y); el.style.visibility = 'visible';}, 300);
}

function toggle_annotations() {
    var comments_div = document.getElementById('comment_list'),
        mode = comments_div.style.display;
    if (mode == 'none') {
        comments_div.style.display = 'block';
        position_table(comments_div);
    } else {
        comments_div.style.visibility = 'hidden';
        comments_div.style.display = 'none';
    }
}

function dock_table() {
    var comments_div = document.getElementById('comment_list');
    position_table(comments_div);
}

function scroll_to_line(value) {
    var pos = 0,
        el = document.getElementById(value);
    window.scrollTo(0, 0);
    while(el) {
        pos += el.offsetTop;
        el = el.offsetParent;
    }
    pos -= win_attr.get_center('y');
    if (pos < 0) {
        pos = 0;
    }
    window.scrollTo(0, pos);
}

// Tooltips from http://www.scriptiny.com/2008/06/javascript-tooltip/
var tooltip = function() {
    var id = 'tooltip',
        top = 3,
        left = 3,
        maxw = 300,
        speed = 10,
        timer = 20,
        endalpha = 95,
        alpha = 0,
        ie = document.all ? true : false,
        tt, t, c, b, h;
    return{
        annotation_list: {},
        init: function() {
            var i, comment, comments, len;
            comments = document.querySelectorAll("div.annotation_comment");
            len = comments.length;
            for (i = 0; i < len; i++) {
                comment = comments[i];
                if ("textContent" in comment) {
                    tooltip.annotation_list[i] = comment.textContent;
                } else {
                    tooltip.annotation_list[i] = comment.innerText;
                }
            }
        },
        show:function(v, w) {
            if(tt == null) {
                tt = document.createElement('div');
                tt.setAttribute('id', id);
                document.body.appendChild(tt);
                tt.style.opacity = 0;
                tt.style.filter = 'alpha(opacity=0)';
                document.onmousemove = this.pos;
            }
            tt.style.display = 'block';
            tt.innerHTML = v in tooltip.annotation_list ? tooltip.annotation_list[v] : '?';
            tt.style.width = w ? w + 'px' : 'auto';
            if(!w && ie){
                tt.style.width = tt.offsetWidth;
            }
            if(tt.offsetWidth > maxw){
                tt.style.width = maxw + 'px';
            }
            h = parseInt(tt.offsetHeight, 10) + top;
            clearInterval(tt.timer);
            tooltip.instantshow(true);
            // tt.timer = setInterval(function(){tooltip.fade(1);}, timer);
        },
        pos:function(e) {
            var u = ie ? event.clientY + document.documentElement.scrollTop : e.pageY,
                l = ie ? event.clientX + document.documentElement.scrollLeft : e.pageX;
            tt.style.top = (u - h) + 'px';
            tt.style.left = (l + left) + 'px';
        },
        instantshow: function(show) {
            if (show === true) {
                tt.style.opacity = endalpha * 0.01;
                tt.style.filter = 'alpha(opacity=' + endalpha + ')';
            } else {
                tt.style.display = 'none';
            }
        },
        fade:function(d) {
            var a = alpha, i;
            if((a != endalpha && d == 1) || (a !== 0 && d == -1)){
                i = speed;
                if(endalpha - a < speed && d == 1){
                    i = endalpha - a;
                }else if(alpha < speed && d == -1){
                    i = a;
                }
                alpha = a + (i * d);
                tt.style.opacity = alpha * 0.01;
                tt.style.filter = 'alpha(opacity=' + alpha + ')';
            }else{
                clearInterval(tt.timer);
                if(d == -1){
                    tt.style.display = 'none';
                }
            }
        },
        hide:function() {
            clearInterval(tt.timer);
            tooltip.instantshow(false);
            // tt.timer = setInterval(function(){tooltip.fade(-1);},timer);
        }
    };
}();

tooltip.init();
