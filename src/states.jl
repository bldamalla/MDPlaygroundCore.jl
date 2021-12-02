# states.jl -- for handling states and configurations

## TODO: is this even necessary???
abstract type AbstractState end

## PARTICLE DESCRIPTOR

abstract type AbstractParticle end

struct PointMass{T} <: AbstractParticle
    mass::T
end

struct ChargedPointMass{T} <: AbstractParticle
    mass::T
    charge::T
end

struct LennardJonesParticle{T} <: AbstractParticle
    mass::T
    σ::T
    ϵ::T
end

struct ChargedLennardJonesParticle{T} <: AbstractParticle
    mass::T
    σ::T
    ϵ::T
    charge::T
end

"""
    ischarged(typeof(::Particle))

Check if the particle is charged (has a field `charge`). This may be useful when
when there is a necessity to check whether an applicable routine applies to a
`Particle` subtype (namely charged particles).
"""
ischarged(T::Type{<:Particle}) = :charge in fieldnames(T)

"""
    islennardjones(typeof(::Particle))

Check if the particle has Lennard--Jones parameters ``σ`` and ``ϵ`` as fields.
This may be useful when it is necessary to check whether routines apply to
certain `Particle` subtypes (namely Lennard--Jones particles).
"""
islennardjones(T::Type{<:Particle}) = :σ in fieldnames(T) && :ϵ in fieldnames(T)

## TODO: handling promotion of the above common types ??

## TODO: define States and the actions on them

struct SimpleDynamicsState{P,S,N,T} <: AbstractState
    particles::Vector{P}    # constructor should restrict this to Particle types
    config::Vector{S}
    simbox::Box{N,T}
end

"""
    Operator <: Any

Convenience abstract type for defining operators. This may be for use only on
`AbstractState`s.
"""
abstract type Operator end

"""
    AdditiveOperator <: Operator

Operators that can be added but not composed. New additive operators can be
created from addition.
"""
abstract type AdditiveOperator <: Operator end

"""
    ComposableOperator <: Operator

Operators that can be composed but not added. New composable operators can be
created from composition.
"""
abstract type ComposableOperator <: Operator end

"""
    Potential <: AdditiveOperator

Operator representing a potential to be included a force field description.
"""
abstract type Potential <: AdditiveOperator end

"""
    Force <: AdditiveOperator

Operator representing a force to be included in a force field description.
"""
abstract type Force <: AdditiveOperator end

"""
    Integrator <: ComposableOperator

Operators acting on `AbstractStates` that can be composed, supposedly at least.
These act as propagators that can be looped.
"""
abstract type Integrator <: ComposableOperator end

