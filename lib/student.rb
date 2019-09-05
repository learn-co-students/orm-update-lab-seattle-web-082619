# frozen_string_literal: true
require_relative '../config/environment.rb'

class Student
  attr_accessor :name, :grade, :id

  def initialize(name = nil, grade = nil, id = nil)
    self.name = name
    self.grade = grade
    self.id = id
  end

  def save
    if id
      update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, name, grade)
      self.id = DB[:conn].execute('SELECT last_insert_rowid() FROM students')[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, grade, id)
  end

  def self.create(name, grade)
    Student.new(name, grade).save
  end

  def self.new_from_db(row)
    id, *values = row
    Student.new(*values, id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map(&method(:new_from_db))[0]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end
end
