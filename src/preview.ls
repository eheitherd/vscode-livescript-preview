#------------------------------------------------------------------------------
# Previewer

require! {
  vscode: {workspace, Uri}
  './content-provider': {update-content-provider}
  './window': {get-active-editor, show-text-document}
  './meta': {language, uri}
}

export preview-document = ->
  editor = get-active-editor!
  if editor?.document?.language-id is language
    editor.document.fileName
    |> make-preview-uri
    |> open-text-document
    |> (.then show-text-document)
    # Updates the contents because the contents may be single space.
    # If event is fired before show, error occurs.
    |> (.then -> update-content-provider it.document.uri)

export on-change = (event) ->
  if is-valid event.document
    debounced delay, -> update-content event.document.file-name

make-preview-uri = -> it |> uri |> Uri.parse

open-text-document = workspace.open-text-document

is-valid = (document) ->
  document.language-id is language and
    document is (get-active-editor!)?.document

update-content = (file-name) ->
  file-name
  |> make-preview-uri
  |> update-content-provider

delay = 500
timeout = null
debounced = (delay, func) ->
  # Passing an invalid ID to clearTimeout does not have any effect.
  clear-timeout timeout
  timeout := set-timeout func, delay
