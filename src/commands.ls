#------------------------------------------------------------------------------
# Provides functions for commands

require! {
  vscode: {commands}
  './window': {get-active-editor}
}

export close-editor = (editor) ->
  active-editor = get-active-editor!
  if active-editor is editor
    close-active-editor!
  else
    focus editor
      .then close-active-editor, ->
      .then (-> focus active-editor), ->

focus = (editor) ->
  if editor.viewColumn
    command = "workbench.action.focus#{column editor.viewColumn}EditorGroup"
    commands.execute-command command
  else
    Promise.reject!

close-active-editor = ->
  commands.execute-command 'workbench.action.closeActiveEditor'

column = -> <[ Zero First Second Third ]>[it]
