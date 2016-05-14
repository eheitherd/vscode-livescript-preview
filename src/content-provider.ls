#------------------------------------------------------------------------------
# Implements TextDocumentContentProvider

require! {
  vscode: {EventEmitter}
  livescript: lsc
  './window': {get-active-editor, is-activated}
}

export content-provider =
  on-did-change:~ -> event-emitter.event

  provide-text-document-content: (uri) ->
    editor = get-active-editor!
    ret = editor and get-display-contents editor
    # Avoid 'open error' caused by null string
    ret or if is-activated! then ret else ' '

export update-content-provider = -> event-emitter.fire it

event-emitter = new EventEmitter

get-display-contents = (editor) ->
  try
    editor.document.get-text!
    |> lsc.compile _, bare: true header: false
  catch e
    e.message
