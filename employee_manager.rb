class Employee

  attr_accessor :salary, :boss
  attr_reader :name, :title
  #attr_writer

  def initialize(name, title, salary)
    @name = name
    @title = title
    @salary = salary
    @boss = nil
  end

  def calculate_bonus(multiplier)
    @salary * multiplier
  end

end

class Manager < Employee
  attr_accessor :employees
  attr_reader :group_salary

  def initialize(name, title, salary)
    super(name, title, salary)
    @employees = []
  end

  def group_salary
    array_salary = @employees.map {|employee| employee.salary}
    array_salary.inject(0, :+)
  end

  def add_employee(*employee)
    employee.each do |em|
      @employees << em
      em.boss = self
    end
  end

  def calculate_bonus(multiplier)
    acc_salary = 0
    @employees.each do |em|
      acc_salary += em.salary
      acc_salary += em.calculate_bonus(1) unless em.class == Employee
    end
    acc_salary * multiplier
  end

end


bob = Employee.new("Bob","Analyst", 20)
sol = Employee.new("Sol","Analyst", 85)
will = Employee.new("Will","Analyst", 10)

peter = Manager.new("Peter","CEO", 2000)

peter.add_employee(bob, sol, will)

ned = Manager.new("Ned","President", 5e6)

ned.add_employee(peter)

p bob.class
p ned.class

p ned.calculate_bonus(1)