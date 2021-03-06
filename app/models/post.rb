# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  title      :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Post < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :favorites, dependent: :destroy
  belongs_to :user
  belongs_to :topic
  mount_uploader :image, ImageUploader



  def up_votes
    votes.where(value: 1).count
  end

  def down_votes
      votes.where(value: -1).count
  end

  def points
     votes.sum(:value)
  end

  default_scope { order(rank: :desc) }
  scope :visible_to, -> (user) { user ? all : joins(:topic).where('topics.public' => true) }
  #scope :ordered_by_title, -> { reorder(title: :asc)}
  #scope :ordered_by_reverse_created_at, -> { reorder(created_at: :asc)}

  validates :title, length: { minimum: 5 }, presence: true
  validates :body, length: { minimum: 10 }, presence: true
  validates :topic, presence: true
  validates :user, presence: true

  def update_rank
    age_in_days = (created_at - Time.new(1970,1,1)) / (60 * 60 * 24)
    new_rank = points + age_in_days

    update_attribute(:rank, new_rank)
  end


  def create_vote
    user.votes.create(value: 1, post: self)
  end

  def save_with_initial_vote
    ActiveRecord::Base.transaction do
      if save
        create_vote
      end
    end
  end



end
