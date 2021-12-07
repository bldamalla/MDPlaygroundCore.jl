# potentials/lennardjones.jl -- for definitions using the
# lennard jones potential

function lennardjones(state::AbstractState)
    ## calculate lennard jones potential from the state
    ## first is get the configurations, σ, ϵ
    @assert islennardjones(eltype(state.particles))
    positions = [conf[:x] for conf in state.config]
    param_tuples = [(part.σ, part.ϵ) for part in state.particles]

    N = length(state); T = eltype(σs)
    acc = zero(T)

    @inbounds for i in 1:N-1
        for j in i+1:N
            tmpΔr = position[i] .- position[j]
            r2 = dot(tmpΔr, tmpΔr)
            σ1, ϵ1 = param_tuples[i]; σ2, ϵ2 = param_tuples[j]
            σ, ϵ = ljmix(σ1, σ2, ϵ1, ϵ2)
            σ2r2 = σ^2 * r2
            acc += ϵ * (σ2r2^6 - σ2r2^3)
        end
    end

    return acc * 4
end

function lennardjones!(forces::Vector{SVector{N}}, state::AbstractState) where N
    @assert islennardjones(eltype(state.particles))
    positions = [conf[:x] for conf in state.config]
    param_tuples = [(part.σ, part.ϵ) for part in state.particles]

    @assert N == dim(eltype(config))
    len = length(positions)

    @inbounds for i in 1:len-1
        for j in i+1:len
            tmpΔr .= positions[i] .- positions[j]
            r2 = dot(tmpΔr, tmpΔr)
            σ1, ϵ1 = param_tuples[i]; σ2, ϵ2 = param_tuples[j]
            σ, ϵ = ljmix(σ1, σ2, ϵ1, ϵ2)
            σr6 = σ^6 / r2^3
            prefac = 24 * ϵ / r2 * σr6 * (1 - 2*σr6)
            forces[i] .+= prefac .* tmpΔr
            forces[j] .-= prefac .* tmpΔr
        end
    end

    return forces
end

function ljmix(σ1, σ2, ϵ1, ϵ2; mix=:lb)
    ## for now only implement Lorentz--Berthelot mixing rule
    if mix == :lb
        σ = σ1 == σ2 ? σ1 : (σ1 + σ2)/2
        ϵ = ϵ1 == ϵ2 ? ϵ1 : sqrt(ϵ1 * ϵ2)
    end
    return σ, ϵ
end

