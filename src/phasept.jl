# phasept.jl -- for phase space points and other important constructs

### TODO: CHANGE THE MODEL ALTOGETHER

"""
    dim(::Phase)
    dim(::Region)

Return the dimensionality of a `Phase` or a `Region` if it is defined.
"""
function dim end

## Phase space points definition

"""
    PhasePartition{N,Tx,Tp}

A representation of phase space points. `:x` contains position, while `:p`
contains momentum for a particle. Contains SVectors for both fields of the
same length `N`. Position has `eltype` `Tx` and momentum has `eltype` `Tp`.
Units can be supported (note operator output dimensions).
"""
mutable struct PhasePartition{N,Tx,Tp}
    x::SVector{N,Tx}
    p::SVector{N,Tp}
end

dim(::Type{PhasePartition{N}}) where N = N
dim(ppart::PhasePartition) = dim(typeof(ppart))

## accessors and mutators

Base.getindex(ppart::PhasePartition, s::Symbol) = getfield(ppart, s)
function Base.setindex!(ppart::PhasePartition{N}, val, s::Symbol)
    setfield!(ppart, s, SVector{N}(val))
end

