require "rails_helper"

RSpec.describe Task do
  subject(:task) { build(:task, project: project) }

  let(:project) { create(:project) }

  describe "validations" do
    it { is_expected.to be_valid }

    it "requires a title" do
      task.title = ""

      expect(task).not_to be_valid
      expect(task.errors).to be_added(:title, :blank)
    end

    it "rejects an assignee who is not a project member" do
      task.assignee = create(:user)

      expect(task).not_to be_valid
      expect(task.errors).to be_added(:assignee, :not_a_member)
    end

    it "rejects a parent from another project" do
      task.parent = create(:task)

      expect(task).not_to be_valid
      expect(task.errors).to be_added(:parent, :different_project)
    end
  end

  describe "#overdue?" do
    around { |example| travel_to(Date.new(2026, 3, 15)) { example.run } }

    it "is overdue when the due date is in the past and the task is open" do
      task.due_on = Date.new(2026, 3, 14)

      expect(task).to be_overdue
    end

    it "is not overdue when the task is done" do
      task.assign_attributes(due_on: Date.new(2026, 3, 14), status: "done")

      expect(task).not_to be_overdue
    end

    it "is not overdue without a due date" do
      expect(task).not_to be_overdue
    end
  end

  describe "completion tracking" do
    let(:task) { create(:task) }

    it "sets completed_at when the task is done" do
      freeze_time do
        task.update!(status: "done")

        expect(task.completed_at).to eq(Time.current)
      end
    end

    it "clears completed_at when the task is reopened" do
      task = create(:task, :done)

      expect { task.update!(status: "todo") }.to change(task, :completed_at).to(nil)
    end
  end

  describe ".search" do
    let!(:matching) { create(:task, project: project, title: "Fix 100% CPU usage") }

    before { create(:task, project: project, title: "Write docs") }

    it "finds tasks by title" do
      expect(described_class.search("cpu")).to contain_exactly(matching)
    end

    it "escapes wildcard characters" do
      expect(described_class.search("100%")).to contain_exactly(matching)
    end

    it "returns everything for a blank query" do
      expect(described_class.search(nil).count).to eq(2)
    end
  end

  describe "assignment notifications" do
    let(:assignee) { create(:user) }

    before { project.memberships.create!(user: assignee) }

    it "notifies the new assignee" do
      expect { create(:task, project: project, assignee: assignee) }
        .to have_enqueued_mail(TaskMailer, :assigned)
    end

    it "does not notify authors who assign themselves" do
      expect { create(:task, project: project, assignee: assignee, author: assignee) }
        .not_to have_enqueued_mail(TaskMailer, :assigned)
    end
  end
end
