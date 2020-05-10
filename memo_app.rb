# frozen_string_literal: true

require "sinatra"
require "yaml/store"

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
  def initialize(store)
    @store = store
  end

  def self.find
    store = YAML::Store.new "memos.yml"
    Memo.new(store)
  end

  def index
    @store.transaction { @store["memo"] }
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
