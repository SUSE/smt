require 'spec_helper'

describe 'zypper repos', :type => :aruba do
  before(:each) { run('zypper repos') }
  before(:each) { stop_all_commands }

  it "executes without errors" do
    expect( last_command_started ).to be_successfully_executed
  end

  it "has at least one repo with enabled mirroring" do
    smt_repos_counter = 0
    last_command_started.stdout.split("\n").each { |line|
      smt_repos_counter += 1 if ( line =~ /SMT\-http/ )
    }

    expect( smt_repos_counter ).to be >= 1
  end
end

describe 'SCC credentials file', :type => :aruba do
  let(:file) { '/etc/zypp/credentials.d/SCCcredentials' }

  it "exists" do
    expect( File.exists?(file) ).to be true
  end

  it "is not empty" do
    expect(File.size(file)).to be > 0
  end
end

describe 'SMT credentials file', :type => :aruba do
  let(:files) { Dir.glob('/etc/zypp/credentials.d/SMT-*') }

  it "exists" do
    expect( files.count ).to be 1
  end

  it "is not empty" do
    expect(File.size(files[0])).to be > 0
  end
end
