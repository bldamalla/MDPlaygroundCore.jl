# phasept.jl -- for phase space points and other important constructs

### TODO: CHANGE THE MODEL ALTOGETHER

"""
    dim(::Phase)
    dim(::Region)

Return the dimensionality of a `Phase` or a `Region` if it is defined.
"""
function dim end

## Phase space points definition

mutable struct Phase2D{T} <: FieldVector{4,T}
    x::T
    y::T
    px::T
    py::T
end
dim(::Type{Phase2D}) = 2
dim(p::Phase2D) = dim(typeof(p))

mutable struct Phase3D{T} <: FieldVector{6,T}
    x::T
    y::T
    z::T
    px::T
    py::T
    pz::T
end
dim(::Type{Phase3D}) = 3
dim(p::Phase3D) = dim(typeof(p))

## TODO: set up constructors here

function Phase2D(x, y, px, py)
    T = promote_type(typeof(x), typeof(y),
                     typeof(px), typeof(py))
    @assert T <: Real ### make sure there are no units
    return Phase2D{T}(x, y, px, py)
end

function Phase3D(x, y, z, px, py, pz)
    T = promote_type(typeof(x), typeof(y), typeof(z),
                     typeof(px), typeof(py), typeof(pz))
    @assert T <: Real ### make sure there are no units
    return Phase3D{T}(x, y, z, px, py, pz)
end

## accessors and mutators

const Phase{T} = Union{Phase2D{T}, Phase3D{T}}

@generated function Base.getindex(phase::Phase{T}, s::Symbol) where T
    d = phase <: Phase2D ? 2 : 3
    return quote
        offset = _getpartition($d, s)
        return SVector{$d,T}(_solvepartition(phase, offset))
    end
end
@generated function Base.setindex(phase::Phase{T}, s::Symbol) where T
    d = phase <: Phase2D ? 2 : 3
    return quote
        offset = _getpartition($d, s)
        phase[offset+1:$d+offset] = val
    end
end

function _solvepartition(phase::Phase, offset)
    ntuple(i->phase[i+offset], dim(phase))
end
function _getpartition(d, s)
    (s == :x || s == :q) && return 0
    s == :p || throw(ArgumentError("Cannot access symbol $s."))
    return d
end

