# integrators.jl -- for integrators within core

module Integrators

using StaticArrays

import ..MDPlaygroundCore: Force, Integrator
import ..MDPlaygroundCore: AbstractState

### TODO: include simple RESPA implementations
### along with velocity (momentum in this case) Verlet

abstract type RESPAPropagator <: Integrator

struct RESPAMomentumPropagator{N} <: RESPAPropagator
    forces::Vector{<:MVector{N,<:Real}}
    action!::Force
    timestep::T where T<:Real
    inside::O where O<:RESPAPropagator
    in_rep::Int
end

function (pp::RESPAMomentumPropagator{N})(st::AbstractState) where N
    # start with updating momenta from current force
    # update at half time step (impulse)
    @assert N == dim(st)
    loc_frc = pp.forces
    Δt = pp.timestep
    impulses = (force .* Δt ./ 2 for force in loc_frc)

    conf = st.config
    for (i, Δp) in enumerate(impulses)
        @inbounds conf[i][:p] = conf[i][:p] .+ Δp
    end

    if pp.inside isa RESPAPositionPropagator
        pp.inside(st)
    else
        for _ in 1:pp.in_rep
            pp.inside(st)
        end
    end

    action!(loc_frc, st)
    impulses2 = (force .* Δt ./ 2 for force in loc_frc)

    for (i, Δp) in enumerate(impulses2)
        @inbounds conf[i][:p] = conf[i][:p] .+ Δp
    end
end

struct RESPAPositionPropagator <: RESPAPropagator
    timestep::T where T<:Real
end

function (xp::RESPAPositionPropagator)(st::AbstractState)
    conf = st.config
    Δt = xp.timestep
    for i in 1:length(conf)
        @inbounds conf[i][:x] = fma.(conf[i][:p], Δt, conf[i][:x])
    end
end

end ## module

