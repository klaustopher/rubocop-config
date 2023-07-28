require "rails_helper"

RSpec.describe User do
  subject { FactoryBot.create(:user) }

  it "does things" do
    expect(described_class.new).to be_a(described_class)
  end
end
