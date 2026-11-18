require "rails_helper"

RSpec.describe "Task management" do
  let(:user) { create(:user, password: "s3cret-password") }
  let(:teammate) { create(:user, name: "Tom Teammate") }
  let!(:project) { create(:project, name: "Website", owner: user, members: [teammate]) }

  before do
    visit new_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "s3cret-password"
    click_on "Sign in"
  end

  it "creates and assigns a task" do
    visit project_path(project)
    click_on "New task"

    fill_in "Title", with: "Update the footer"
    select "High", from: "Priority"
    select "Tom Teammate", from: "Assignee"
    click_on "Create Task"

    expect(page).to have_text("Update the footer")
    expect(page).to have_css(".badge", text: "To do")
    expect(page).to have_current_path(%r{/projects/#{project.identifier}/tasks/\d+})
  end

  it "shows validation errors" do
    visit new_project_task_path(project)
    click_on "Create Task"

    expect(page).to have_text("Title can't be blank")
  end

  it "filters tasks by status" do
    create(:task, project: project, title: "Still open")
    create(:task, :done, project: project, title: "Already finished")

    visit project_tasks_path(project, status: "done")

    within("#tasks") do
      expect(page).to have_text("Already finished")
      expect(page).to have_no_text("Still open")
    end
  end

  it "marks a task as done" do
    task = create(:task, project: project, title: "Close me")

    visit project_task_path(project, task)
    select "Done", from: "Status"
    click_on "Update Task"

    expect(page).to have_css(".badge.bg-success", text: "Done")
    expect(task.reload).to be_done
  end
end
