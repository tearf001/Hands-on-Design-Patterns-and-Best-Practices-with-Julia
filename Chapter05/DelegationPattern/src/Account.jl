# Object Definition
import Dates: Date

mutable struct Account
    account_number::String
    balance::Float64
    date_opened::Date
end

# Accessors
account_number(a::Account) = a.account_number
balance(a::Account) = a.balance
date_opened(a::Account) = a.date_opened

# Functions

deposit!(a::Account, amount::Real) = a.balance += amount
withdraw!(a::Account, amount::Real) = a.balance -= amount

function transfer!(from::Account, to::Account, amount::Real)
    # println("Transferring ", amount, " from account ",
    #     account_number(from), " to account ", account_number(to))
    withdraw!(from, amount)
    deposit!(to, amount)
    return amount
end

if abspath(PROGRAM_FILE) == @__FILE__
    function test_account()
        acct = Account("1234", 100.00, Date(2019, 1, 1))
        @show acct
        @show deposit!(acct, 25)
        println("-------------------------------------")
    
        dest = Account("4321", 500.00, Date(2019, 2, 1))
        @show dest
        @show withdraw!(dest, 50.00)
        println("-------------------------------------")
    
        @show transfer!(acct, dest, 10.00)
        @show acct
        @show dest
    
        return nothing
    end
    test_account()
end