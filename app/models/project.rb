class Project < ApplicationRecord
  belongs_to :user

  has_many :bids, dependent: :destroy

  has_one_attached :design_document
  has_one_attached :srs_document

  validates :title, presence: true

  enum visibility: %i[pub priv]

  delegate :email, to: :user

  scope :recent_by_user, ->(user) { where(user: user).order(created_at: :desc).limit(5) }

  scope :recent, -> { order(created_at: :desc).limit(5) }

  def visibility_status
    if self.visibility == 'pub'
      'Public'
    else
      'Private'
    end
  end

  def self.all_skills
    ['Javascript developer', 'Ruby developer', 'Elixir developer', 'Typescript developer', 'Python developer']
  end
end
