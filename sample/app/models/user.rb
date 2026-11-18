class User < ApplicationRecord
  has_secure_password

  has_many :memberships, dependent: :destroy
  has_many :projects, through: :memberships
  has_many :assigned_tasks,
           class_name:  "Task",
           foreign_key: :assignee_id,
           inverse_of:  :assignee,
           dependent:   :nullify
  has_many :authored_tasks,
           class_name:  "Task",
           foreign_key: :author_id,
           inverse_of:  :author,
           dependent:   :restrict_with_error

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 100 }
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  scope :notifiable, -> { where(email_notifications: true) }

  def first_name
    name.split.first
  end

  def member_of?(project)
    memberships.exists?(project: project)
  end

  def role_in(project)
    memberships.find_by(project: project)&.role
  end

  def can_manage?(project)
    role_in(project).in?(%w[owner maintainer])
  end
end
