#------------------------------------------------------------------------------
# LiveScript Preview.

require! {
  vscode: {
    workspace, ExtensionContext, commands, window, Uri, ViewColumn,
    EventEmitter}
  livescript: lsc
  'prelude-ls': {map, any}
}

language = \livescript
title = "#{language}-preview"
delay = 500

# main
export activate = (context) ->
  provider-reg = register-provider title, content-provider
  command-reg = register-command "extension.#{title}" preview-document
  change-reg = register-on-change on-change

  context.subscriptions.push provider-reg, command-reg, change-reg

# from class CoffeeScriptPreview
on-change = (event) ->
  if is-valid event.document
    debounced delay, -> update-content event.document.file-name

update-content = (file-name) ->
  file-name
  |> make-preview-uri
  |> update-content-provider

is-valid = (document) ->
  document.language-id is language and
    document is active-text-editor?.document

preview-document = ->
  if (editor = active-text-editor) and editor.document.language-id is language
    editor.document.fileName
    |> make-preview-uri
    |> open-text-document
    |> (.then show-text-document)
    # Updates the contents because the contents may be single space.
    # If event is fired before show, error occurs.
    |> (.then -> update-content-provider it.document.uri)

show-text-document = (text-doc) ->
  display-column = get-display-column active-text-editor.view-column
  window.show-text-document text-doc, display-column, true

make-preview-uri = -> Uri.parse "#{title}:///#{it}.js"

get-display-column = ->
  | it is ViewColumn.Three   => ViewColumn.Two
  | otherwise                => it + 1

# class CoffeeScriptPreviewContentProvider
event-emitter = new EventEmitter
update-content-provider = -> event-emitter.fire it
content-provider =
  on-did-change:~ -> event-emitter.event
  provide-text-document-content: (uri) ->
    ret = active-text-editor and get-display-contents active-text-editor
    # Avoid 'open error' caused by null string
    ret or if is-activated uri then ret else ' '

is-activated = ->
  window.visibleTextEditors
  |> map (.document.uri.scheme)
  |> any (is title)

get-display-contents = (editor) ->
  try
    editor.document.get-text!
    |> lsc.compile _, bare: true header: false
  catch e
    e.message

# from class WorkspaceService
open-text-document = workspace.open-text-document
register-on-change = workspace.on-did-change-text-document

# from class WindowService
active-text-editor = window.active-text-editor

# from utility
timeout = null
debounced = (delay, func) ->
  # Passing an invalid ID to clearTimeout does not have any effect.
  clear-timeout timeout
  timeout := set-timeout func, delay

# alias
register-command = commands.register-command
register-provider = workspace.register-text-document-content-provider
