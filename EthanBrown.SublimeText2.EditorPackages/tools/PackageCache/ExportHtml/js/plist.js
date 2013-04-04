/*jshint globalstrict: true*/
"use strict";

var plist = {
    color_scheme: {},
    content: "",
    indentlevel: 0,

    get: function(file_name) {
        this.content = '<?xml version="1.0" encoding="UTF-8"?>\n' +
                        '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n' +
                        '<plist version="1.0">\n' +
                        '<!-- ' + file_name + ' -->\n';
        this.parsedict(this.color_scheme);
        this.content += '</plist>\n';
        return this.content;
    },

    isinstance: function(obj, s) {
        return ({}).toString.call(obj).match(/\s([a-zA-Z]+)/)[1].toLowerCase() === s;
    },

    sortkeys: function(obj) {
        var sorted = {},
            keys = [],
            key;

        for (key in obj) {
            if (obj.hasOwnProperty(key)) {
                keys.push(key);
            }
        }
        keys.sort();
        return keys;
    },

    indent: function() {
        var i;
        for (i = 0; i < this.indentlevel; i++) {
            this.content += "    ";
        }
    },

    parsekey: function(k) {
        this.indent();
        this.content += '<key>' + k + '</key>\n';
    },

    parseitem: function(obj) {
        if (this.isinstance(obj, "string")) {
            this.parsestring(obj);
        } else if (this.isinstance(obj, "array")) {
            this.parsearray(obj);
        } else if (this.isinstance(obj, "object")) {
            this.parsedict(obj);
        }
    },

    parsearray: function(obj) {
        var i, len = obj.length;
        this.indent();
        this.content += '<array>\n';
        this.indentlevel++;
        for (i = 0; i < len; i++) {
            this.parseitem(obj[i]);
        }
        this.indentlevel--;
        this.indent();
        this.content += '</array>\n';
    },

    parsestring: function(s) {
        this.indent();
        this.content += '<string>' + s + '</string>\n';
    },

    parsedict: function(obj) {
        var keys = this.sortkeys(obj),
            len = keys.length,
            k, i;

        this.indent();
        this.content += '<dict>\n';
        this.indentlevel++;
        for (i = 0; i < len; i++)
        {
            k = keys[i];
            this.parsekey(k);
            this.parseitem(obj[k]);
        }
        this.indentlevel--;
        this.indent();
        this.content += '</dict>\n';
    }
},

escape_html = {
    safe_chars: {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': '&quot;',
        "'": '&#39;',
        "/": '&#x2F;'
    },
    escape: function (s) {
        return String(s).replace(/[&<>"'\/]/g, function (c) {return escape_html.safe_chars[c];});
    }
};

function extract_theme(name) {
    var text, wnd, doc,
        a = document.createElement('a');
    window.URL = window.URL || window.webkitURL;

    if (window.Blob != null && a.download != null) {
        text = new Blob([plist.get(name)], {'type':'application/octet-stream'});
        a.href = window.URL.createObjectURL(text);
        a.download = name;
        a.click();
    } else {
        text = '<pre>' + escape_html.escape(plist.get(name)) + '</pre>',
        wnd  = window.open('', '_blank', "status=1,toolbar=0,scrollbars=1"),
        doc  = wnd.document;
        doc.write(text);
        doc.close();
        wnd.focus();
    }
}
