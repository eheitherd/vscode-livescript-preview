#------------------------------------------------------------------------------
# Previewer

require! {
  vscode: {workspace, Uri}
  'prelude-ls': {Str}
  './content-provider': {update-content-provider}
  './commands': {close-editor}
  './window': {get-active-editor, get-preview, show-text-document, nullable}
  './meta': {language, uri}
  './debounced': Debounced
}

export toggle-preview = ->
  document = (nullable get-active-editor!).document
  preview = nullable get-preview!
  if is-required-to-open document, preview
    open-preview document
  else
    close-editor preview

export on-change = (event) ->
  delayed-update event.document

export on-select = (event) ->
  delayed-update event.text-editor.document

is-required-to-open = (document, preview) ->
  document.language-id is language and
  document isnt preview.document and
  not document `is-targeted-by` preview

open-preview = (document) ->
  document.file-name
  |> make-preview-uri
  |> open-text-document
  |> (.then show-text-document)
  # Updates the contents because the contents may be single space.
  # If event is fired before show, error occurs.
  |> (.then -> update-content-provider it.document.uri)

delayed-update = (document) ->
  if document `is-targeted-by` (nullable get-preview!)
    debounced.time-out recompile-delay, -> update-content document.file-name

update-content = (file-name) ->
  file-name
  |> make-preview-uri
  |> update-content-provider

is-targeted-by = (document, preview) ->
  preview-filename = preview.document.file-name |> drop-root
  doc-filename = document.file-name |> make-preview-uri |> (.path) |> drop-root
  preview-filename is doc-filename

make-preview-uri = -> it |> uri |> Uri.parse

open-text-document = workspace.open-text-document

drop-root = Str.drop-while (is /[\/\.\\]/)

recompile-delay = 500
debounced = new Debounced
