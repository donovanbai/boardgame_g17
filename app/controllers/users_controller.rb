class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :show]
  before_action :correct_user,   only: [:edit, :update, :show]

  def show
    @user = User.find(params[:id])
    @bgg_accounts = @user.bgg_accounts
    #search_params = params.slice(:maxage)
    @all_games = @user.collect_games(params[:maxage], params[:sort])
    @stuffsuch = params[:maxage]
    
    @bgg_account = current_user.bgg_accounts.build if logged_in?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Thank you for making an account at Bored? Game!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private
    
    def user_params
      params.require(:user).permit(:username, :password,
                                   :password_confirmation)
    end

    # Before filters

    # Confirms a logged-in user. Check later
    #def logged_in_user
    #  unless logged_in?
    #    flash[:danger] = "Please log in."
    #    redirect_to login_url
    #  end
    #end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless @user == current_user
    end
    
    def build_game_list
      temp = []
      for account in @bgg_accounts do
        temp = temp | account.games.where("minage <= ?", params[:maxage]).order(params[:sort])
      end
      return temp
    end
end
