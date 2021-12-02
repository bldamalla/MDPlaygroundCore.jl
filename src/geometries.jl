# geometry.jl -- for common geometries to be used
# also probably define behavior for callbacks

## Geometry definitions

abstract type Region end

struct Box{N,T} <: Region
    start::SVector{N,T}
    stop::SVector{N,T}
end
dim(::Box{N}) where N = N
Base.size(box::Box) = box.stop .- box.start
volume(box::Box) = prod(size(box))
centroid(box::Box) = @. (box.start + box.stop) / 2

function Box(pt1::NTuple{N}, pt2::NTuple{N}) where N
    T = promote_type(eltype(pt1), eltype(pt2))
    mnmx = minmax.(pt1, pt2)
    start = SVector{N,T}(mn for (mn, _) in mnmx)
    stop = SVector{N,T}(mx for (_, mx) in mnmx)
    return Box{N,T}(start, stop)
end
Box(pt1, pt2) = begin
    @assert length(pt1) == length(pt2)
    return Box(tuple(pt1...), tuple(pt2...))
end

const unitsquare = Box(zeros(2), ones(2))
const unitcube = Box(zeros(3), ones(3))

struct Ball{N,T} <: Region
    center::SVector{N,T}
    radius::T
end
dim(::Ball{N}) where N = N
volume(ball::Ball) = 4π/3 * ball.radius^3
centroid(ball::Ball) = ball.center

function Ball(center::NTuple{N}, radius) where N
    T = promote_type(eltype(center), typeof(radius))
    return Ball{N,T}(SVector(center), radius)
end
Ball(center, radius) = Ball(tuple(center...), radius)

const unitcircle = Ball(zeros(2), one(AbstractFloat))
const unitsphere = Ball(zeros(3), one(AbstractFloat))

struct Grid{N,T} <: Region
    start::SVector{N,T}
    spacing::SVector{N,T}
    dims::NTuple{N,Int}
end
dim(grid::Grid{N}) where N = N
centroid(grid::Grid) = fma.(spacing ./ 2, dims, start)

function Grid(start::NTuple{N}, spacing::NTuple{N}, dims::NTuple{N,Int}) where N
    T = promote_type(eltype(start), eltype(spacing))
    return Grid{N,T}(SVector(start), SVector(spacing), dims)
end
Grid(start, spacing, dims) = Grid(tuple(start...), tuple(spacing...), dims)

### TODO: INCLUDE GEOM TRANSFORMATIONS ??

