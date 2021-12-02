# callbacks.jl -- for definition of typed callbacks
# to limit input behavior for use in thermostats/boundary conditions?

## TODO: define behavior of a callback

abstract type PredicateCallback end
abstract type StochasticCallback <: PredicateCallback end

struct ContinuousStochasticCallback{F,A,C} <: StochasticCallback
    predicate::F
    action::A
    callback::C
end

function (csc::ContinuousStochasticCallback)(tval, x...)
    if csc.predicate(tval)
        csc.action(x)
        csc.callback(x) ## TODO: figure this out soon
    end
end

"""
    IdentityCallback

A singleton representing an identity callback. Should return the arguments.
Predicate evaluates to true. Can be used to retrieve the arguments after series
of callbacks. Note that this stops callback messaging.
"""
struct IdentityCallback <: PredicateCallback end
const IdentityCB = IdentityCallback()
(::IdentityCallback)(x...) = identity(x)

"""
    NullCallback

A singleton representing a null callback. Should return `nothing`.
Predicate evaluates to true. Can be used to stop callback messaging.
"""
struct NullCallBack <: PredicateCallback end
const NullCB = NullCallback()
(::NullCallback)(x...) = nothing

