class User < ActiveRecord::Base
  has_many :sprints
  has_many :rewards, through: :sprints
  has_many :runes, through: :rewards

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  def to_s
    email
  end
end
