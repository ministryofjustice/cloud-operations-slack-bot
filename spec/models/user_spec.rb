require "rails_helper"

RSpec.describe User, :type => :model do
  it "is null when user does not exist" do
    expect(User.count).to eq 0
  end

  it "is null when one user does exist but no channel exists" do
    User.create(slack_handle: "U1", channel_handle: "")
    expect(User.count).to eq 0
  end

  it "is one when one user does exist and the channel exists" do
    User.create(slack_handle: "U1", channel_handle: "C1")
    expect(User.count).to eq 1
  end

  it "does not allow creation when slack_handle already exists" do
    user1 = User.create(slack_handle: "U1")
    user2 = User.create(slack_handle: "U1")
    expect(user1).to be_valid
    expect(user2).to be_invalid
    expect(User.count).to eq 1
    expect(user2.errors.full_messages.first).to eq "your slack handle has already been registered"
  end

  it "is null after one user was created in a previous example" do
    expect(User.count).to eq 0
  end
end