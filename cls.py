# class Person:
#   def __init__(self, name, age):
#     self.name = name
#     self.age = age

# p1 = Person("John", 36)

# print(p1.name)
# print(p1.age)

# 1..........ELECTRONICS

# class Electeronics():
#   processor = '8 gb octacore'
#   ram = '8 gb'
#   properties = {
#     'bluethooth':True,
#     'speaker':False,
#     'wifi':True
#   }
#   def testProperties(self):
#     if self.properties['bluethooth'] == True:
#       print('Bluethooth is working')
#     else:
#       print('Bluethooth is not working')

# obj = Electeronics()
# test = obj.testProperties()



# 2..........STUDENT
# class Student():
#   def __init__(self,name,roll,fathername):
#     self.name = name
#     self.roll = roll
#     self.fathername = fathername

#   def addmission(self,Name, Roll, Age, Father_name):
#     ob = Student(Name, Roll, Age, Father_name)
#     mylist.append(ob)
  
#   def setAge(self,age):
#     if age < 4:
#       print("You are underage: ") 
#     elif age > 20:
#       print("You are overage")
#     else:
#       print("Wel come to your new school ")
#     self.age = age
    
#   def setStd(self,std):
#     self.std = std

#   def Display(self):
#     print("Student name is: ",self.name)
#     print("Student roll number is: ",self.roll)
#     print("Student fathername is: ",self.fathername)
#     print("Student age is: ",self.age)
#     print("Student class is: ",self.std)
# mylist=[]
# obj = Student("Ankita",1,"Uday")
# obj.setAge(age = 14)
# obj.setStd(4)
# obj.Display()

# 3..........EMPLOYEES
class Employees():
  rank = {
      "ram" : "1st",
      "shyam" : "2nd",
      "mohan" : "3rd"
    }

  def Rank(self):
    if self.rank["ram"] == "1st":
      print("Ram is number 1st rank in the office")
    else:
      print("Ram is number not 1st rank in the office")  
    if self.rank["shyam"] == "3nd":
      print("Shyam is number 2nd rank in the office")
    else:
      print("Shyam is number not 2nd rank in the office")
    if self.rank["mohan"] == "4rd":  
      print("Mohan is number 3rd rank in the office")
    else:
      print("Another is the 3rd  rank in the office")

  def Salary(self,check_employee): 
    Id = int(input("Enter Employee Id: "))
    if (check_employee(Id)) == False:
      print("Employee does not  exists")
    else:
      Increment = int(input("Enter increase in Salary"))  
      print("Increment  of salary successful")

  # def Leave(self):

obj = Employees()
test = obj.Rank()
def Display():
    print("Welcome to Employee Management Record")
    print("1. to Rank of Employee")
    print("2. to Salary of Employee ")
    print("3. to  Absence of Employee")
    print("4. to Display Employees")
    print("5. to Exit")
    ch = int(input("Enter your Choice "))
    if ch == 1:
        obj.Rank()  
    elif ch == 2:
        obj.Salary()
    elif ch == 3:
        obj.Absence()
    elif ch == 4:
        obj.Display()
    elif ch == 5:   
        exit(0)
    else:
        print("Invalid Choice")


# 4..........CALCULATOR
# class Calculator:
#     def addition(self):
#         print(a + b)
#     def subtraction(self):
#         print(a - b)
#     def multiplication(self):
#         print(a * b)
#     def division(self):
#         print(a / b)
# a = int(input("Enter first number: "))
# b = int(input("Enter first number: "))  
# obj = Calculator()
# choice = 1
# while choice != 0:
#     print("1. +")
#     print("2. -")
#     print("3. *")
#     print("4. /")
#     choice = int(input("Enter your choice:  "))
#     if choice == 1:
#         print(obj.addition())
#     elif choice == 2:
#         print(obj.subtraction())
#     elif choice == 3:
#         print(obj.multiplication())
#     elif choice == 4:
#         print(obj.division())
#     else:
#         print("Invalid choice")



# 5..........BICYCLE
# class Bicycle():
#   def __init__(self,name,model,color,price):
#     self.name = name
#     self.model = model
#     self.color = color
#     self.price = price
#   def Wheel(self,run,stop):
#     self.run = run
#     self.stop = stop
#   def Pandel(self):
#     print(f"run {self.run},stop {self.stop}")

# b=Bicycle("bike",657,"blue",5487)
# print(b.name)
# print(b.model)
# print(b.color)
# print(b.price)
# b.Wheel(" 1 km "," after break")
# b.Pandel()