require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_reader :id
  attr_accessor :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<~SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<~SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end

  def save

    if self.id
      self.update
    else
      sql = <<~SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<~SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)

  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    new_instance = Student.new(row[0], row[1], row[2])
    # new_instance.id = row[0]
    # new_instance.name = row[1]
    # new_instance.grade = row[2]
    new_instance
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?;"

    data = DB[:conn].execute(sql, name)[0]    #this returns an array of arrays that match

    self.new_from_db(data)

  end


end
