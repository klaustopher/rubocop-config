require "csv"

class TaskImporter
  REQUIRED_HEADERS = %w[title status].freeze
  STATUS_ALIASES = {
    "open"        => "todo",
    "wip"         => "in_progress",
    "in progress" => "in_progress",
    "closed"      => "done",
    "resolved"    => "done",
  }.freeze

  class ImportError < StandardError; end

  attr_reader :imported, :skipped

  def initialize(project:, author:, io:)
    @project = project
    @author = author
    @io = io
    @imported = 0
    @skipped = []
  end

  def call
    csv = CSV.new(@io, headers: true, header_converters: ->(header) { header.to_s.strip.downcase })
    rows = csv.read

    missing = REQUIRED_HEADERS - rows.headers.compact
    raise ImportError, "Missing columns: #{missing.join(', ')}" if missing.any?

    Task.transaction do
      rows.each.with_index(2) { |row, line| import_row(row, line) }
    end

    self
  end

  private

  def import_row(row, line)
    task = @project.tasks.build(
      title:           row["title"]&.strip,
      description:     row["description"],
      status:          normalize_status(row["status"]),
      priority:        row.fetch("priority", "normal").presence || "normal",
      due_on:          parse_date(row["due"]),
      estimated_hours: row["estimate"].presence&.to_f,
      assignee:        find_assignee(row["assignee"]),
      author:          @author
    )

    if task.save
      @imported += 1
    else
      @skipped << { line: line, errors: task.errors.full_messages }
    end
  end

  def normalize_status(value)
    status = value.to_s.strip.downcase
    STATUS_ALIASES.fetch(status, status)
  end

  def parse_date(value)
    return if value.blank?

    Date.parse(value)
  rescue Date::Error
    nil
  end

  def find_assignee(email)
    return if email.blank?

    @project.members.find_by(email: email.strip.downcase)
  end
end
