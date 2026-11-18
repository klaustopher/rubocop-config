require "rails_helper"

RSpec.describe Tasks::BulkReassign do
  subject(:result) do
    described_class.new(project: project, task_ids: task_ids, assignee: assignee, actor: actor).call
  end

  let(:owner) { create(:user) }
  let(:assignee) { create(:user) }
  let(:project) { create(:project, owner: owner, members: [assignee]) }
  let(:tasks) { create_list(:task, 3, project: project) }
  let(:task_ids) { tasks.map(&:id) }
  let(:actor) { owner }

  context "when the actor manages the project" do
    it "reassigns all open tasks" do
      expect(result).to be_success
      expect(result.updated_count).to eq(3)
      expect(tasks.map { |task| task.reload.assignee }).to all(eq(assignee))
    end

    it "skips tasks that are already done" do
      tasks.first.update!(status: "done")

      expect(result.updated_count).to eq(2)
    end

    it "skips tasks already assigned to the target" do
      tasks.first.update!(assignee: assignee)

      expect(result.updated_count).to eq(2)
    end
  end

  context "when the actor is a regular member" do
    let(:actor) { assignee }

    it "refuses to reassign" do
      expect(result).not_to be_success
      expect(result.errors).to include(I18n.t("tasks.bulk_reassign.not_allowed"))
    end
  end

  context "when the assignee is not a member" do
    let(:assignee) { create(:user) }
    let(:project) { create(:project, owner: owner) }

    it "returns an error and changes nothing" do
      expect { result }.not_to(change { tasks.map { |task| task.reload.assignee_id } })
      expect(result.errors).to include(I18n.t("tasks.bulk_reassign.not_a_member"))
    end
  end

  context "without any tasks selected" do
    let(:task_ids) { ["", nil] }

    it { is_expected.not_to be_success }
  end
end
