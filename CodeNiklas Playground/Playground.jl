#=
for i in 1:10
    display("iteation of $(i)")
end


["Iteration $(i)" for i in 1:10]



#Functions
function g(x::Int64)
    x = x + 3
    return x
end

f(x::Int64) = x + 3

f(10)


#Arrays
a = [1, 2, 3]
push!(a,2)

mat = [1 2 3 
        4 5 6]
println(typeof(mat))
=#

#Tuples
##Tuples are immutable vs arrays where push etc works
t1 = (1,2,3,4)
a1 = [1,2,3,4]
a1[4] = 0
a1
#t1[4] = 0
#t1

##2 dimensional tuple and accessing the elements
t2 = ((1,2),(3,4))
#t2[1][2]

marks1 = (Science = (90,100), 
        Maths = (95,100), 
        English = (75/100))

marks2 = (Sport = (80,100), 
         History = (85,100))

marksmergerd = merge(marks1,marks2)
marksmergerd

#Dictionaries
#This makes the key a string
cars1 = Dict("Car1" => 100000, 
            "Car2" => 200000,
            "Car3" => 300000 )
cars1["Car1"]

#This makes the key a symbol
cars2 = Dict(:Car1 => 100000,
            :Car2 => 2000000,
            :Car3 => 300000)
cars2[:Car1]

#println(haskey(cars2, :Car1))
#println(cars2)
#println("____________")
#delete!(cars2, :Car1)
#println(cars2)
#println(haskey(cars2, :Car1))

#Showing all keys or values in a dict
keys(cars1)
values(cars1)

carsMerged = merge(cars1, cars2)

#Sets
#does not have duplicates, no order
sportsBrands = Set(["Adidas", "Nike", "Puma", "Rebook"])
in("Puma", sportsBrands)
sportsBrandsIndia = Set(["Adidas", "Nike", "HRX"])
#Union works like merge jsut that it doesnt copy duplicates
union(sportsBrands, sportsBrandsIndia)
#Intersect does well, what it says
intersect(sportsBrands, sportsBrandsIndia)
#List of items from the first list not present in 2nd set
setdiff(sportsBrands, sportsBrandsIndia)
#Adds element
push!(sportsBrands, "HRX")

#Working with date and time
using Dates
now()
today()
birthdate = Date(2000,5,1) #YYYY, MM, DD
birthdate = DateTime(2000,5,1,10,15,25) #Date format with time in hour minute second
now(UTC)

year(birthdate)
year(now())
hour(now())

dayofweek(birthdate)
dayname(birthdate)
dayofquarter(birthdate)
daysinmonth(birthdate)

#today() - birthdate
today() + Day(5)

dateFormat = DateFormat("dd-mm-yyyy")
Dates.format(birthdate,dateFormat)


#Conditional Statements
a = 10
b = 20
a >= 10 || b < 20 # || is or

a >= 10 && b < 20 # && is the and operator

if a > 10
    print("a is greater than 10")
elseif a < 10
    print("a is less than ten")
else
    print("a is 10")
end



