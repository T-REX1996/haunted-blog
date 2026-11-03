# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  scope :published, -> { where(secret: false) }

  scope :search, lambda { |term|
    pattern = "%#{sanitize_sql_like(term.to_s)}%"
    where('title LIKE :pattern OR content LIKE :pattern', pattern:)
  }

  scope :visible_to, lambda { |user|
    user ? where(secret: false).or(where(user:)) : published
  }

  scope :default_order, -> { order(id: :desc) }

  def owned_by?(target_user)
    user == target_user
  end
end
