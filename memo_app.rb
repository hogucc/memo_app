# frozen_string_literal: true

require "sinatra"
require "yaml/store"
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
  @memos = memos.create(params[:title], params[:body])
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

  def close_connection
    @connection.finish
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
    titles = []
    begin
      @connection.exec("SELECT title FROM Memo") do |result|
        result.each do |row|
          titles << row
        end
      end
    ensure
      @connection.finish
    end

    titles
  end

  def create(title, body)
    @store.transaction do
      @store["memo"] += [{ title: title, body: body }]
    end
  end

  def show(id)
    @store.transaction { @store["memo"][id] }
  end

  def update(id, title, body)
    @store.transaction do
      @store["memo"][id] = { title: title, body: body }
    end
  end

  def delete(id)
    @store.transaction do
      @store["memo"].delete_at(id)
    end
  end
end
