class Membership < ApplicationRecord
  ROLES = %w[owner maintainer member viewer].freeze

  belongs_to :project
  belongs_to :user

  enum :role, ROLES.index_by(&:itself), default: "member", validate: true

  validates :user_id, uniqueness: { scope: :project_id }
  validate :project_keeps_an_owner, on: :update, if: :role_changed?

  before_destroy :ensure_not_last_owner

  private

  def project_keeps_an_owner
    return unless role_was == "owner"
    return if project.memberships.owner.where.not(id: id).exists?

    errors.add(:role, :last_owner)
  end

  def ensure_not_last_owner
    return unless owner?
    return if project.memberships.owner.count > 1

    errors.add(:base, :last_owner)
    throw :abort
  end
end
