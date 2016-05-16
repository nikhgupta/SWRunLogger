class User < ActiveRecord::Base
  has_many :imports
  has_many :sprints, through: :imports
  has_many :rewards, through: :sprints
  has_many :runes, through: :rewards

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  def to_s
    email
  end

  def invalidate_cache!
    cache  = Rails.root.join "data", "reports"
    files  = Dir.glob(cache.join("**",  "#{id}.json"))
    files << Dir.glob(cache.join("**", "global.json"))
    files.flatten.uniq.map{|file| File.unlink file}
  end
end
