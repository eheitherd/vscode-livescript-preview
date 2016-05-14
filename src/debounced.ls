#------------------------------------------------------------------------------
# A class which provides debounced timeout function

module.exports = class
  -> @timeout-id = 0

  time-out: (delay, func) ->
    # Passing an invalid ID to clearTimeout does not have any effect.
    clear-timeout @timeout-id
    @timeout-id = set-timeout func, delay
