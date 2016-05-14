#------------------------------------------------------------------------------
# Provides functions for window

require! {
  vscode: {window, ViewColumn}
  'prelude-ls': {find}
  './meta': {title}
}

export get-active-editor = -> window.active-text-editor

export is-activated = -> !!get-preview!

export get-preview = ->
  window.visible-text-editors
  |> find (.document.uri.scheme is title)

export show-text-document = (text-doc) ->
  editor = get-active-editor!
  display-column = get-display-column editor.view-column
  window.show-text-document text-doc, display-column, true

get-display-column = ->
  # Uses it If preview pane already exists
  | preview = get-preview!   => preview.view-column
  | it is ViewColumn.Three   => ViewColumn.Two
  | otherwise                => it + 1
