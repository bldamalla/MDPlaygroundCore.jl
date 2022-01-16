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

abstract type FixedIntervalCallback <: AbstractCallback end

struct COMCallback <: FixedIntervalCallback
    steps::Int
    uniform::Bool
end
function (cb::COMCallback)(currstep, st)
    # get average momentum and get rid of it
    # so that center of mass does not move
    currstep % cb.steps == 0 && return

    if cb.uniform
        _uniformCOM!(st)
    else
        _nonuniformCOM!(st)
    end
end
function _uniformCOM!(st::AbstractState)
    ## get mean momentum
    ## subtract from everything
    len = length(st)
    μmom = sum(conf->conf[:p], config) / len

    for i in eachindex(st.config)
        @inbounds st.config[i][:p] = st.config[i][:p] .- μmom
    end
end
function _nonuniformCOM!(st::AbstractState)
    # get mean velocity (not weighted)
    # subtract mass * velocity from current momenta
    len = length(st)
    ps = (conf[:p] for conf in st.config)
    masses = (particle.mass for particle in st.particles)
    
    μv = sum(zip(ps, masses)) do (p, m)
        p / m
    end / len

    for (i, m) in enumerate(masses)
        @inbounds st.config[i][:p] = st.config[i][:p] .- μv * m
    end
end

end ### module

