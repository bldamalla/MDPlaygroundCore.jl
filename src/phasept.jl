# phasept.jl -- for phase space points and other important constructs

"""
    dim(::Phase)
    dim(::Region)

Return the dimensionality of a `Phase` or a `Region` if it is defined.
"""
function dim end

## Phase space points definition

mutable struct Phase2D{T}
    x::T
    y::T
    px::T
    py::T
end
dim(::Phase2D) = 2

mutable struct Phase3D{T}
    x::T
    y::T
    z::T
    px::T
    py::T
    pz::T
end
dim(::Phase3D) = 3

## TODO: set up constructors here

function Phase2D(x, y, px, py)
    T = promote_type(typeof(x), typeof(y),
                     typeof(px), typeof(py))
    @assert T <: Real ### make sure there are no units
    return Phase2D{T}(convert(T, x), convert(T, y),
                      convert(T, px), convert(T, py))
end

function Phase3D(x, y, z, px, py, pz)
    T = promote_type(typeof(x), typeof(y), typeof(z),
                     typeof(px), typeof(py), typeof(pz))
    @assert T <: Real ### make sure there are no units
    return Phase3D{T}(convert(T, x), convert(T, y), convert(T, z),
                      convert(T, px), convert(T, py), convert(T, pz))
end

## accessors and mutators

const Phase{T} = Union{Phase2D{T}, Phase3D{T}}

function Base.getindex(phase::Phase{T}, s::Symbol) where T
    d = dim(phase)
    if s == :q || s == :x
        return d == 2 ? SVector{d,T}(phase.x, phase.y) : 
            SVector{d,T}(phase.x, phase.y, phase.z)
    elseif s == :p
        return d == 2 ? SVector{d,T}(phase.px, phase.py) : 
            SVector{d,T}(phase.px, phase.py, phase.pz)
    else
        throw(ArgumentError("Symbol $s cannot be accessed."))
    end
end

function Base.setindex!(phase::Phase{T}, val, s::Symbol) where T
    @assert dim(phase) == length(val)
    d = dim(phase)
    if s == :q || s == :x
        phase.x = convert(T, val[1])
        phase.y = convert(T, val[2])
        if d == 3 phase.z = convert(T, val[3]) end
    elseif s == :p
        phase.px = convert(T, val[1])
        phase.py = convert(T, val[2])
        if d == 3 phase.pz = convert(T, val[3]) end
    else
        throw(ArgumentError("Symbol $s cannot be accessed."))
    end
    return nothing
end

