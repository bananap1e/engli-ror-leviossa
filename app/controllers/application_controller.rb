# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :forbid_user_vote!, only: :vote

  def shared_vote(instance)
    if params[:vote] == 'up'
      instance.liked_by current_user
    else
      instance.downvote_from current_user
    end

    if instance.vote_registered?
      instance.set_carma(params[:vote], current_user)
      message = params[:vote] == 'up' ? 'Liked your' : 'Disliked your'
      instance.create_activity key: message, owner: current_user, recipient: instance.user
      flash[:notice] = 'Thanks'
    else
      flash[:danger] = 'You\'ve already voted'
    end
  end

  private

  def forbid_user_vote!
    @phrase = Phrase.friendly.find(params[:phrase_id])
    cheater = if params[:controller] == 'examples'
                phrase.examples.find_by(id: params[:example_id]).user == current_user
              else
                @phrase.user == current_user
              end

    if cheater
      flash[:danger] = 'You can\'t vote for yourself'
      redirect_back(fallback_location: root_path)
    end
  end
end
