class Task < ApplicationRecord
  include Archivable

  PRIORITIES = { low: 0, normal: 1, high: 2, urgent: 3 }.freeze
  OPEN_STATUSES = %w[todo in_progress review].freeze

  belongs_to :project, touch: true
  belongs_to :author, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :parent, class_name: "Task", optional: true

  has_many :subtasks, class_name: "Task", foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  enum :status, { todo: "todo", in_progress: "in_progress", review: "review", done: "done" }, default: :todo
  enum :priority, PRIORITIES, default: :normal, prefix: true

  validates :title, presence: true, length: { maximum: 255 }
  validates :estimated_hours, numericality: { greater_than: 0, less_than: 1000 }, allow_nil: true
  validate :assignee_is_project_member
  validate :parent_belongs_to_same_project

  before_save :track_completion, if: :status_changed?
  after_commit :notify_assignee, on: [:create, :update], if: :saved_change_to_assignee_id?

  scope :open, -> { where(status: OPEN_STATUSES) }
  scope :assigned_to, ->(user) { where(assignee: user) }
  scope :due_within, ->(period) { open.where(due_on: Date.current..period.from_now.to_date) }
  scope :by_urgency, -> { order(priority: :desc, due_on: :asc) }

  def self.search(query)
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query)}%"
    where("title ILIKE :pattern OR description ILIKE :pattern", pattern: pattern)
  end

  def overdue?
    due_on.present? && due_on.past? && !done?
  end

  def reference
    "#{project.identifier.upcase}-#{id}"
  end

  def time_spent_ratio
    return if estimated_hours.blank? || logged_hours.blank?

    logged_hours / estimated_hours
  end

  private

  def track_completion
    self.completed_at = done? ? Time.current : nil
  end

  def notify_assignee
    return if assignee.nil? || assignee == author

    TaskMailer.with(task: self, recipient: assignee).assigned.deliver_later
  end

  def assignee_is_project_member
    return if assignee.nil? || assignee.member_of?(project)

    errors.add(:assignee, :not_a_member)
  end

  def parent_belongs_to_same_project
    return if parent.nil? || parent.project_id == project_id

    errors.add(:parent, :different_project)
  end
end
