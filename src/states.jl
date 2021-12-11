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
ischarged(T::Type{<:AbstractParticle}) = :charge in fieldnames(T)

"""
    islennardjones(typeof(::Particle))

Check if the particle has Lennard--Jones parameters ``σ`` and ``ϵ`` as fields.
This may be useful when it is necessary to check whether routines apply to
certain `Particle` subtypes (namely Lennard--Jones particles).
"""
islennardjones(T::Type{<:AbstractParticle}) = :σ in fieldnames(T) && :ϵ in fieldnames(T)

## TODO: handling promotion of the above common types ??

## TODO: define States and the actions on them

struct SimpleDynamicsState{P,S,N,T} <: AbstractState
    particles::Vector{P}    # constructor should restrict this to Particle types
    config::Vector{S}
    simbox::Box{N,T}
end

Base.length(state::AbstractState) = length(state.particles)
dim(state::AbstractState) = dim(eltype(config))

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
struct Potential <: AdditiveOperator
    action::F where F <: Function
end

"""
    Force <: AdditiveOperator

Operator representing a force to be included in a force field description.
"""
abstract type Force <: AdditiveOperator end

## TODO: Define addition of additive operators

"""
    OperatorSum <: AdditiveOperator

An operator representing the linear combination of other operators.
"""
struct OperatorSum{O,N} <: AdditiveOperator
    actions::NTuple{N,O}
    coefs::NTuple{N,<:Real}
end
Base.eltype(::OperatorSum{O}) where O = O
Base.length(::OperatorSum{O,N}) where {O,N} = N
function Base.:+(op1::OperatorSum{O}, op2::OperatorSum{O}) where O
    N = length(op1) + length(op2)
    collect_actions = tuple(op1.actions..., op2.actions...)
    collect_coefs = tuple(op1.coefs..., op2.coefs...)
    return OperatorSum{O,N}(collect_actions, collect_coefs)
end
function Base.:+(op1::OperatorSum{O}, op2::O) where O <: AdditiveOperator
    N = length(op1) + 1
    collect_actions = tuple(op1.actions..., op2.action)
    collect_coefs = tuple(op1.coefs..., op2.coef)
    return OperatorSum{O,N}(collect_actions, collect_coefs)
end
Base.:+(op1::O, op2::OperatorSum{O}) where O = op2 + op1
Base.:+(op1::O, op2::O) where O <: AdditiveOperator = 
    OperatorSum{O,2}((op1.action, op2.action), (op1.coef, op2.coef))

"""
    Integrator <: ComposableOperator

Operators acting on `AbstractStates` that can be composed, supposedly at least.
These act as propagators that can be looped.
"""
abstract type Integrator <: ComposableOperator end

struct KineticEnergy <: AdditiveOperator end
const kineticenergy = KineticEnergy()
function (::KineticEnergy)(state::AbstractState)
    momenta = (conf[:p] for conf in state.config)
    masses = (particle.mass for particle in state.particles)

    return sum(zip(momenta, masses)) do (p, m)
        dot(p, p) / 2 / m
    end
end

