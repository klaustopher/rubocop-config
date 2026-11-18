require "rails_helper"

RSpec.describe "API V1 Tasks" do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }
  let(:token) { ApiToken.create!(user: user) }
  let(:headers) { { "Authorization" => "Bearer #{token.plaintext}", "Accept" => "application/json" } }

  describe "GET /api/v1/projects/:project_id/tasks" do
    before { create_list(:task, 3, project: project) }

    it "lists the tasks of the project" do
      get api_v1_project_tasks_path(project), headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.size).to eq(3)
      expect(response.headers["X-Total-Count"]).to eq("3")
    end

    it "paginates" do
      get api_v1_project_tasks_path(project), params: { per_page: 2, page: 2 }, headers: headers

      expect(response.parsed_body.size).to eq(1)
    end

    it "rejects an invalid since parameter" do
      get api_v1_project_tasks_path(project), params: { since: "yesterday" }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "requires a valid token" do
      get api_v1_project_tasks_path(project), headers: headers.merge("Authorization" => "Bearer nope")

      expect(response).to have_http_status(:unauthorized)
    end

    it "hides projects the user is not a member of" do
      get api_v1_project_tasks_path(create(:project)), headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/projects/:project_id/tasks" do
    let(:params) { { task: { title: "Ship it", priority: "high" } } }

    it "creates a task" do
      expect { post api_v1_project_tasks_path(project), params: params, headers: headers }
        .to change(project.tasks, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include("title" => "Ship it", "priority" => "high", "status" => "todo")
    end

    it "returns validation errors" do
      post api_v1_project_tasks_path(project), params: { task: { title: "" } }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body.dig("errors", "title")).to be_present
    end
  end
end
