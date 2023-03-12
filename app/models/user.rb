class User < ApplicationRecord

  extend FriendlyId
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_one_attached :avatar
  has_many :links, dependent: :destroy
  friendly_id :username, use: %i[slugged]

  after_create :create_default_links
  after_update :create_default_links

  validates :full_name, length: { maximum: 50 }
  validates :body, length: { maximum: 80 }
  validate :valid_username

  def valid_username
    errors.add(:username, 'is already taken') if User.where(username:).where.not(id:).exists?

    restricted_username_list = %(admin root dashboard analytics appearance settings preferences calendar)

    errors.add(:username, 'is restricted') if restricted_username_list.include?(username)
  end

  def should_generate_new_friendly_id?
    username_changed? || slug.blank?
  end

  def get_daily_profile_views
    daily_views = Ahoy::Event.where(user_id: id)
                             .where(name: "Viewed Dashboard")
   
    daily_views.group_by_day(:time).count
  end

  def get_daily_link_clicks
     daily_link_clicks = Ahoy::Event.where(user_id: id)
                                    .where(name: 'Clicked Link')
    daily_link_clicks.group_by_day(:time).count
  end

  def get_daily_views_by_device_type
    device_views = Ahoy::Event.joins(:visit)
                              .where('time > ? AND time < ?',
                                     Date.today.last_month,
                                     Date.today.end_of_day).group(:device_type)
  end

  private

  def create_default_links
    Link.create(user: self, title: '', url: '') while links.count < 5
  end
end
