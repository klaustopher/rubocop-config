class Project < ApplicationRecord
  include Archivable

  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :tasks, dependent: :destroy

  has_one_attached :logo

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :identifier,
            presence:   true,
            uniqueness: true,
            format:     { with: /\A[a-z][a-z0-9-]{1,29}\z/ }
  validates :budget_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :derive_identifier, if: -> { identifier.blank? && name.present? }

  scope :visible_to, ->(user) { joins(:memberships).where(memberships: { user_id: user.id }) }
  scope :recently_active, -> { where(updated_at: 2.weeks.ago..).order(updated_at: :desc) }

  def to_param
    identifier
  end

  def owner
    memberships.owner.first&.user
  end

  def progress
    total = tasks.count
    return 0.0 if total == 0

    (tasks.done.count.to_f / total * 100).round(1)
  end

  def overdue_tasks
    tasks.open.where(due_on: ...Date.current)
  end

  private

  def derive_identifier
    self.identifier = name.parameterize.first(30)
  end
end
