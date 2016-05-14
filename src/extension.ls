#------------------------------------------------------------------------------
# LiveScript Preview

require! {
  vscode: {workspace, commands}
  './preview': {preview-document, on-change}
  './content-provider': {content-provider, update-content-provider}
  './window': {get-active-editor}
  './meta': {title}
}

export activate = (context) ->
  provider-reg = register-provider title, content-provider
  command-reg = register-command "extension.#{title}" preview-document
  change-reg = register-on-change on-change

  context.subscriptions.push provider-reg, command-reg, change-reg

register-provider = workspace.register-text-document-content-provider
register-command = commands.register-command
register-on-change = workspace.on-did-change-text-document
