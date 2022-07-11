#   1.......... Sum: Write a function to sum all the numbers in a given list.
#             Note – No arguments, define variable inside the function an


# def add():
#     num = [1, 2, 3, 4, 5]
#     total = 0
#     for x in num:
#        total += x
#     return total   
# print("Sum of the number in a list : ",add())

# def sum():
#     total = 0
#     numbers = (8, 2, 3, 0, 7)
#     for x in numbers:
#         total += x
#     return total
# print(sum())



#   2.......... Reverse: Write a function to reverse a given city name, prompt user to input city name,
# define function with one argument and return reverse of the city name.

def rev(s):
    s1 = ""
    for i in s:
        s1 = i + s1
    return s1
s = input("Enter the city name:  ")
print ("The original string city name  is : ",s)   
print ("The reversed string city name   is : ",rev(s))



#   3..........Count: Write a function that accepts a string and calculate the number of upper case
# letters and lower case letters, provide default value of string as a greeting message “Welcome
# To You in Python program.” 


# def up_low():
#     greet = " Welcome To You in Python program. " 
#     count1 = 0
#     count2 = 0
#     for i in greet:
#         if(i.islower()):
#             count1 = count1+1
#         elif(i.isupper()):
#             count2 = count2+1
#     return count1,count2     
# res1,res2 = up_low()  
# print("The number of lowercase characters is:",res1)
# print("The number of uppercase characters is:",res2)
