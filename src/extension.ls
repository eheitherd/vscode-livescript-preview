#------------------------------------------------------------------------------
# LiveScript Preview

require! {
  vscode: {window, workspace, commands}
  './preview': {toggle-preview, on-change, on-select}
  './content-provider': {content-provider, update-content-provider}
  './window': {get-active-editor}
  './meta': {title}
}

export activate = (context) ->
  provider-reg = register-provider title, content-provider
  command-reg = register-command "extension.#{title}" toggle-preview
  change-reg = register-on-change on-change
  select-reg = register-on-select on-select

  context.subscriptions.push provider-reg, command-reg, change-reg, on-select

register-provider = workspace.register-text-document-content-provider
register-command = commands.register-command
register-on-change = workspace.on-did-change-text-document
register-on-select = window.on-did-change-text-editor-selection
