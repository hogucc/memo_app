# frozen_string_literal: true

require "sinatra"
require "pg"
require "dotenv/load"

get "/" do
  memos = Memo.find
  @memos = memos.index
  erb :top
end

get "/memos/new" do
  erb :new
end

post "/memos" do
  memos = Memo.find
  memos.create(params[:title], params[:body])
  redirect "/"
end

get "/memos/:id" do
  @id = params[:id].to_i
  memos = Memo.find
  @memo = memos.show(@id)
  erb :show
end

get "/memos/:id/edit" do
  @id = params[:id].to_i
  memos = Memo.find
  @memo = memos.show(@id)
  erb :edit
end

patch "/memos/:id" do
  memos = Memo.find
  memos.update(params[:id].to_i, params[:title], params[:body])
  redirect "/"
end

delete "/memos/:id" do
  memos = Memo.find
  memos.delete(params[:id].to_i)
  redirect "/"
end

class Memo
  def initialize(connection)
    @connection = connection
  end

  def self.find
    connection = PG.connect(
      host: ENV["DB_HOST"],
      user: ENV["DB_USER"],
      password: ENV["DB_PASSWORD"],
      dbname: ENV["DB_NAME"]
    )
    Memo.new(connection)
  end

  def index
    result = @connection.exec("SELECT id, title FROM Memo ORDER BY id")
    @connection.finish

    result
  end

  def create(title, body)
    @connection.exec("INSERT INTO Memo (title, body) VALUES ($1, $2)", [title, body])
    @connection.finish
  end

  def show(id)
    memo = {}

    @connection.exec("SELECT title, body FROM Memo where id = $1", [id]) do |result|
      memo.merge!(result.first)
    end

    memo
  end

  def update(id, title, body)
    @connection.exec("UPDATE Memo set title = $1, body = $2 where id = $3", [title, body, id])
    @connection.finish
  end

  def delete(id)
    @connection.exec("DELETE FROM Memo where id = $1", [id])
    @connection.finish
  end
end
