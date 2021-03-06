# frozen_string_literal: true

class Example < ActiveRecord::Base
  include IsAuthorMethod
  include PublicActivity::Model

  belongs_to :phrase
  belongs_to :user

  acts_as_votable

  validates :example, :phrase_id, :user_id, presence: true
  validates_uniqueness_of :example, scope: :phrase_id, message: 'has already been used!'
end
