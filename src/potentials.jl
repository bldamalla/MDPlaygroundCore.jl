# potentials.jl -- simple potential implementations
# along with corresponding forces in cartesian coordinates

module Potentials

using StaticArrays
using LinearAlgebra

## TODO: something about neighborfinders
import ..MDPlaygroundCore: AbstractState
import ..MDPlaygroundCore: islennardjones, ischarged

include("potentials/lennardjones.jl")

end ## submodule end

