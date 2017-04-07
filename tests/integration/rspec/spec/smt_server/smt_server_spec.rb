require 'spec_helper'

describe 'smt-repos', :type => :aruba do
  before(:each) { run('smt-repos') }
  before(:each) { stop_all_commands }

  it "executes without errors" do
    expect( last_command_started ).to be_successfully_executed
  end

  it "has at least one repo" do
    expect( last_command_started.stdout.split("\n").count ).to be > 4
  end
end

describe 'smt-repos -o', :type => :aruba do
  before(:each) { run('smt-repos -o') }
  before(:each) { stop_all_commands }

  it "executes without errors" do
    expect( last_command_started ).to be_successfully_executed
  end

  it "has at least one repo with enabled mirroring" do
    expect( last_command_started.stdout.split("\n").count ).to be > 4
  end
end
