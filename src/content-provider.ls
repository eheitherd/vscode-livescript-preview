#------------------------------------------------------------------------------
# Implements TextDocumentContentProvider

require! {
  vscode: {EventEmitter, Range}
  livescript: lsc
  './window': {get-active-editor, is-activated}
  './debounced': Debounced
}

export content-provider =
  on-did-change:~ -> event-emitter.event

  provide-text-document-content: (uri) ->
    # Avoid 'open error' caused by null string
    uri.result ? ' '

export update-content-provider = (uri) ->
  editor = get-active-editor!
  if editor
    err, data <- get-display-contents editor
    [result, delay] = if err then [err.message, error-delay] else [data, 0]
    <- debounced.time-out delay
    event-emitter.fire uri with {result}
  # Returns a value
  #   to avoid warning 'rejected promise not handled with 1 second'
  uri

get-display-contents = (editor, func) ->
  selected = editor.selection.with!
  src =
    | selected.is-empty => editor.document.get-text!
    | otherwise         => editor.document.get-text selected
  try
    src
    |> lsc.compile _, bare: true header: false
    |> func null, _
  catch
    func e

error-delay = 1000
debounced = new Debounced

event-emitter = new EventEmitter
