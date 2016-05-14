#------------------------------------------------------------------------------
# Previewer

require! {
  vscode: {workspace, Uri}
  'prelude-ls': {Str}
  './content-provider': {update-content-provider}
  './window': {get-active-editor, show-text-document, get-preview}
  './meta': {language, uri}
  './debounced': Debounced
}

export preview-document = ->
  editor = get-active-editor!
  if editor?.document?.language-id is language
    editor.document.file-name
    |> make-preview-uri
    |> open-text-document
    |> (.then show-text-document)
    # Updates the contents because the contents may be single space.
    # If event is fired before show, error occurs.
    |> (.then -> update-content-provider it.document.uri)

export on-change = (event) ->
  delayed-update event.document

export on-select = (event) ->
  delayed-update event.text-editor.document

delayed-update = (document) ->
  if is-target document
    debounced.time-out recompile-delay, -> update-content document.file-name

make-preview-uri = -> it |> uri |> Uri.parse

open-text-document = workspace.open-text-document

is-target = (document) ->
  preview-filename = (get-preview!)?.document?.file-name ? '' |> drop-root
  doc-filename = document.file-name |> make-preview-uri |> (.path) |> drop-root
  preview-filename is doc-filename

drop-root = Str.drop-while (is /[\/\.\\]/)

update-content = (file-name) ->
  file-name
  |> make-preview-uri
  |> update-content-provider

recompile-delay = 500
debounced = new Debounced
