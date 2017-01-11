class HomeController < ApplicationController
  def index
    @users = User.all
    @asqs = Asq.all
    @title = 'Home'
  end
end
