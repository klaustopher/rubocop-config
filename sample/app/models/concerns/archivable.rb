module Archivable
  extend ActiveSupport::Concern

  included do
    belongs_to :archived_by, class_name: "User", optional: true

    scope :archived, -> { where.not(archived_at: nil) }
    scope :unarchived, -> { where(archived_at: nil) }
  end

  def archived?
    archived_at.present?
  end

  def archive!(by:)
    return if archived?

    update!(archived_at: Time.current, archived_by: by)
  end

  def unarchive!
    update!(archived_at: nil, archived_by: nil)
  end
end
