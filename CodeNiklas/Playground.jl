#=
for i in 1:10
    display("iteation of $(i)")
end


["Iteration $(i)" for i in 1:10]

=#
#Functions
function g(x::Int64)
    x = x + 3
    return x
end

f(x::Int64) = x + 3

f(10)