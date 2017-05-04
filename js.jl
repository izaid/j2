module JavaScript
    macro NODE_FILE()
        path = joinpath(dirname(@__FILE__), "julia.node")
        return :($path)
    end

    type Value
        id::UInt64

        function Value(id)
            res = new(id)
            finalizer(res, test_fin)
            res
        end
    end

    function test_fin(x::Value)
        ccall((:j2_pop_value, @NODE_FILE), Void, (UInt64,), x.id)
    end

    const SHARED = Dict()

    function catch_message(e)
        sprint(showerror, e, catch_backtrace())
    end

    function convert(::Type{Array}, x::Value)
        ccall((:ToJuliaArray, @NODE_FILE), Any, (Any,), x)
    end
end

function js(src)
    ccall((:JSEval, @JavaScript.NODE_FILE), Any, (Cstring,), src)
end

macro js_str(src)
    js(src)
end
