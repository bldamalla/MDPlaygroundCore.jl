# callbacks.jl -- for definition of typed callbacks
# to limit input behavior for use in thermostats/boundary conditions?

## TODO: define behavior of a callback

"""
    AbstractCallback

A supertype for implementing callbacks after operations.
"""
abstract type AbstractCallback end

### TODO: I guess, define all callbacks first before using typeunions

module Callbacks

import ..MDPlaygroundCore: AbstractCallback, AbstractState

end ### module

