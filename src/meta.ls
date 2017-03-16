#------------------------------------------------------------------------------
# Meta data

export language = \livescript
export title = "#{language}-preview"
export uri = -> "#title://#{make-path it} LiveScript Preview"

make-path = -> if it.0 is \/ then it else "/#it"
