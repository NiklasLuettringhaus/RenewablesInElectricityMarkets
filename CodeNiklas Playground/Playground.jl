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


a > 5 ? "Yes" : "No"

letter = 0
for brand in sportsBrands
    for letter in brand
        #print(letter, " ")
    end
    #print("\n")
end

for d in carsMerged
   # println(d, " ")
end

for x in 1:10
    if x % 2 == 0
        print(x)
    end
end

# 2 is a special case, just print it
println(2)

for num in 3:2:100  # step sizes of 2 starting from 3, only need to check odd numbers now
    prime_candidate = true  # consider everything prime until proven otherwise
    for i in 3:2:floor(Int,sqrt(num))  # no need to check 1, num itself, or even numbers
        if (num % i) == 0   # divisible by a smaller number?
            prime_candidate = false # mark it not prime...
            break   # ...and we're outta here!
        end
    end
    if prime_candidate  # if the boolean hasn't been flipped by now, it's prime
        println(num)
    end
end


alphabet = Dict(string(Char(x1 + 65))=> x1 for x1 in 1:26)


[(x,y) for x in 1:3, y in 1:2]


a = [11,22,33,44,55,66,77]
a[1:2]

a[[2,5,6]]

[x for x in 1:10 if x%2 == 0]

[x for x in 1:10 if x%2 ==1]

# Working with string

string1 = "I love Julia"
lastindex(string1)
string1[lastindex(string1)]

isascii(string1)
"Love" * "Julia"

string("love " , "julia")

split(string1," ")

split(string1, "")


parse(Float64, "100")

in("I", string1)

occursin("love", string1)

findfirst("l", string1)
findfirst("love", string1)

replace(string1, "love" => "adore")

#Functions
f(x) = x + x
f(2)

f(x,y) = x * 2 - y
f(2,3)

function multiply(x,y)
    return x * y
end
 
multiply(1,2)

function metersToInches(val, name = "Patron")
    if name == "Patron"
        println("Value for name is not supplied")
    else
        println("Hi,", name, ". The conversion value is")
    end
        return val * 39.37
end

metersToInches(1.5)


function bmiMetric(weight, height)
    return weight/height^2
end

bmiMetric(72, 170)

metersToInches(2.3, "Niklas")

#Formatting numbers and strings
using Printf

name = "Niklas";
number = 7
@printf("Hello %s number is %i", name, number)

@sprintf("hello %s", name)

ch = 'i'

@printf("%c",ch)

x = 100

@printf("value of x is %i", x)

y = 100.50

@printf("value of y is %.2f", y)

z = 246872374
@printf("%.3e", z)

#working with real world files
using CSV
using DataFrames
using Plots
linkToCSV = "/Users/niklasluttringhaus/Documents/GitHub/RenewablesInElectricityMarkets/CodeNiklas Playground/iris.csv"
iris = CSV.read(linkToCSV, DataFrame, normalizenames = true);
iris

names(iris)
size(iris)

first(iris,5)

last(iris)

describe(iris)

iris.Species

irisSpeciesCounter = Dict{String, Integer}()

for k in iris.Species
    if haskey(irisSpeciesCounter, k)
        irisSpeciesCounter[k] +=1
    else
        irisSpeciesCounter[k] = 1
    end
end

print(irisSpeciesCounter)

first(iris)

iris[:,[2,3,4]]
#table[rows, columns]
iris[1:5, 2:3]


#visualize DataFrame



x = 1:15; y = rand(15)
plot(x,y)
z= rand(15);
plot!(x,z)

plot(x,y,title="random graph", xlabel = "X axis this",ylabel= "axis")
scatter(x,y)
bar(x,y)
histogram(y)

p1 = plot(x,y)
p2 = (scatter(x,y))
p3 = bar(x,y)
p4 = histogram(x,y)

plot(p1,p2,p3,p4,layout=(2,2), legend =false)

y = rand(15,4)
plot(x,y, layout= (4,1))

iris = CSV.read(linkToCSV, DataFrame, normalizenames = true);

plot(iris.Sepal_Length)
bar(iris.Species,iris.Petal_Length)
scatter(iris.Petal_Length, iris.Petal_Width)

histogram(iris.Petal_Length)

#DDL - Create, Alter and drop
#DML - Insert update and delete
#DQL - Select

using StatsBase
items = ["a", 2, 5, "h", "hello", 3]
weights = [0.1, 0.1, 0.2, 0.2, 0.1, 0.3]
sample(items, Weights(weights))