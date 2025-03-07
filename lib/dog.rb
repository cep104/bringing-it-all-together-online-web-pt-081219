require 'pry'
class Dog
  attr_accessor :name, :breed
  attr_reader :id
  def initialize(id: nil,name:,breed:)
    @name = name 
    @breed = breed
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL 
    CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table 
    sql = <<-SQL 
    DROP TABLE dogs 
    SQL
    DB[:conn].execute(sql)
  end
  
  def save
    if self.id 
      self.update 
    else
    sql = <<-SQL 
    INSERT INTO dogs(name,breed)
    values(?,?)
    SQL
          DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    # binding.pry
    Dog.new(name: self.name, breed: self.breed, id: self.id)
   
  end
  end
  
   def self.create(name:, breed:)
      dog = self.new(name: name, breed: breed)
      dog.save
      dog
   end
  
  def self.new_from_db(row)
      id = row[0]
      name = row[1]
      breed = row[2]
      self.new(name: name, breed: breed, id: id)
   end
   
   def self.find_by_id(id)
     sql = "SELECT * FROM dogs WHERE id = ?"
     DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end[0]
   end
   
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      SQL
      
      dog = DB[:conn].execute(sql, name, breed).first

      if dog
        new_dog = self.new_from_db(dog)
      else
        new_dog = self.create({:name => name, :breed => breed})
      end
      new_dog
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end[0]
  end
 
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  
  
end