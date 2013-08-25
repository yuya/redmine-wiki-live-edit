(function(document, xhr) {
  var LiveEdit, inlineCSS, liveEdit, styleSheet;
  styleSheet = document.createElement("style");
  inlineCSS = ".jstEditor { overflow: hidden; }#content_text, #preview { width: 49.5%; max-width: 50%; }#content_text { box-sizing: border-box; float: left; }#preview { float: right; }#preview fieldset { margin-top: 0; }#preview legend { display: none; }";
  LiveEdit = (function() {
    function LiveEdit() {
      var _this = this;
      this.form = document.getElementById("wiki_form");
      this.editor = document.getElementById("content_text");
      this.origPreview = document.getElementById("preview");
      this.preview = this.origPreview.cloneNode();
      this.keyTimerId = null;
      this.origValues = (function(p) {
        var excuted, params, regex, target;
        target = p[p.length - 1].getElementsByTagName("a")[0];
        params = target.getAttribute("onclick");
        regex = /\(\'\w+\',\s\'(.+\/preview)\',\s.+encodeURIComponent\(\'(.+)\'\)/g;
        excuted = regex.exec(params);
        return {
          url: excuted[1],
          token: encodeURIComponent(excuted[2])
        };
      })(this.form.getElementsByTagName("p"));
      this.baseParams = (function(i) {
        var input, params;
        input = _this.form.getElementsByTagName("input");
        params = [];
        while (i < input.length) {
          params.push(_this.serializer(input[i]));
          i++;
        }
        params.push("authenticity_token=" + _this.origValues.token);
        return params.join("&");
      })(0);
      this.initElement();
      this.observeKeyEvent();
    }

    LiveEdit.prototype.initElement = function() {
      this.editor.parentNode.appendChild(this.preview);
      this.origPreview.parentNode.removeChild(this.origPreview);
      styleSheet.innerText = inlineCSS;
      document.body.appendChild(styleSheet);
      return this.updatePreview();
    };

    LiveEdit.prototype.observeKeyEvent = function() {
      var _this = this;
      return this.editor.addEventListener("keyup", function() {
        console.log("@@@ keyuped");
        clearTimeout(_this.keyTimerId);
        return _this.keyTimerId = setTimeout(function() {
          return _this.updatePreview();
        }, 1000);
      }, false);
    };

    LiveEdit.prototype.serializer = function(element) {
      var key, val;
      key = encodeURIComponent(element["name"]).replace(/%20/g, "+");
      val = element["value"].replace(/(\r)?\n/g, "\r\n");
      val = encodeURIComponent(val).replace(/%20/g, "+");
      return "" + key + "=" + val;
    };

    LiveEdit.prototype.updatePreview = function() {
      var callback, loader,
        _this = this;
      loader = document.getElementById("ajax-indicator");
      callback = function() {
        _this.editor.style.minHeight = "" + _this.preview.offsetHeight + "px";
        return loader.style.display = "none";
      };
      return (function(textContent) {
        xhr.onreadystatechange = function() {
          if (xhr.readyState === 4 && xhr.status === 200) {
            _this.preview.innerHTML = xhr.responseText;
            return callback();
          } else {
            return loader.style.display = "block";
          }
        };
        xhr.open("post", _this.origValues.url, true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        return xhr.send("" + _this.baseParams + "&" + textContent);
      })(this.serializer(this.editor));
    };

    return LiveEdit;

  })();
  return liveEdit = new LiveEdit();
})(this.document, new XMLHttpRequest());
