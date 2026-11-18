namespace :maintenance do
  desc "Archive projects without activity for the given number of days (default: 180)"
  task :archive_stale_projects, [:days] => :environment do |_task, args|
    days = Integer(args.fetch(:days, 180))
    system_user = User.find_by!(email: "system@tracker.example")

    stale = Project.unarchived.where(updated_at: ...days.days.ago)
    puts "Archiving #{stale.count} projects idle for more than #{days} days"

    stale.find_each do |project|
      project.archive!(by: system_user)
      puts "  - #{project.identifier}"
    end
  end

  desc "Import tasks from a CSV file: rake maintenance:import_tasks[project-id,path/to/file.csv]"
  task :import_tasks, [:project, :path] => :environment do |_task, args|
    project = Project.find_by!(identifier: args.fetch(:project))
    importer = File.open(args.fetch(:path)) do |file|
      TaskImporter.new(project: project, author: project.owner, io: file).call
    end

    puts "Imported #{importer.imported} tasks"
    importer.skipped.each do |skip|
      warn "Line #{skip[:line]}: #{skip[:errors].join('; ')}"
    end
  end

  desc "Revoke API tokens that have expired"
  task revoke_expired_tokens: :environment do
    expired = ApiToken.where(revoked_at: nil).where(expires_at: ...Time.current)
    puts "Revoking #{expired.count} tokens"
    expired.find_each(&:revoke!)
  end
end
