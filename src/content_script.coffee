url = location.href

if /redmine/.test(url) and (/\/edit$/.test(url) or /\/edit\?.+$/.test(url))
  # post message to background
  chrome.extension.sendRequest {}, (response) ->

  do (document = this.document, xhr = new XMLHttpRequest()) ->
    styleSheet = document.createElement "style"
    inlineCSS  = ".jstEditor { overflow: hidden; }
  #content_text, #preview { width: 49.5%; max-width: 50%; }
  #content_text { box-sizing: border-box; position: relative; float: left; }
  #preview { float: right; }
  #preview fieldset { margin-top: 0; }
  #preview legend { display: none; }"

    class LiveEdit
      constructor: ->
        @form        = document.getElementById "wiki_form"
        @editor      = document.getElementById "content_text"
        @origPreview = document.getElementById "preview"
        @preview     = @origPreview.cloneNode()
        @keyTimerId  = null
        @origValues  = do (p = @form.getElementsByTagName "p") =>
          target  = p[p.length - 1].getElementsByTagName("a")[0]
          params  = target.getAttribute "onclick"

          # ~ Redmine 2.0
          if /^new\sajax\.updater/i.test params
            regex   = /\(\'\w+\',\s\'(.+\/preview)\',\s.+encodeURIComponent\(\'(.+)\'\)/g
            excuted = regex.exec params

            return {
              url   : excuted[1]
              token : encodeURIComponent excuted[2]
            }
          # Redmine 2.1 ~
          else
            regex   = /\w+\(\"(.+\/preview)\"\,\s/g
            excuted = regex.exec params

            return {
              url   : excuted[1]
              token : @form.authenticity_token["value"]
            }

        @baseParams = do (i = 0) =>
          input  = @form.getElementsByTagName "input"
          params = []

          while i < input.length
            params.push @serializer(input[i])
            i++

          params.push "authenticity_token=#{@origValues.token}"
          return params.join "&"

        @initElement()
        @observeKeyEvent()

      initElement: ->
        @editor.parentNode.appendChild @preview
        @origPreview.parentNode.removeChild @origPreview

        styleSheet.innerText = inlineCSS
        document.body.appendChild styleSheet

        @updatePreview()

      observeKeyEvent: ->
        @editor.addEventListener "keyup", =>
          clearTimeout @keyTimerId
          @keyTimerId = setTimeout =>
            @updatePreview()
          , 1000
        , false

      serializer: (element) ->
        key = encodeURIComponent(element["name"]).replace /%20/g, "+"
        val = element["value"].replace /(\r)?\n/g, "\r\n"
        val = encodeURIComponent(val).replace /%20/g, "+"

        return "#{key}=#{val}"

      updatePreview: ->
        loader   = document.getElementById "ajax-indicator"
        callback = =>
          @editor.style.minHeight = "#{@preview.offsetHeight}px"
          loader.style.display    = "none"

        do (textContent = @serializer @editor) =>
          xhr.onreadystatechange = =>
            if xhr.readyState is 4 and xhr.status is 200
              @preview.innerHTML = xhr.responseText
              callback()
            else
              loader.style.display = "block"

          xhr.open "post", @origValues.url, true
          xhr.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
          xhr.setRequestHeader "X-CSRF-Token", @origValues.token
          xhr.send "#{@baseParams}&#{textContent}"

    liveEdit = new LiveEdit()
