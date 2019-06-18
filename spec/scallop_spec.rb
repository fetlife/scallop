require "scallop"

RSpec.describe Scallop do
  describe "#to_command & #cmd & #sudo" do
    specify "command building" do
      expect(Scallop.cmd(:ls).to_command).to eq "ls"
      expect(Scallop.cmd("ls", "/home/scallop").to_command).to eq "ls /home/scallop"
      expect(Scallop.sudo(:chucknorris).cmd(:rm, "-rf", "/").to_command).to eq "sudo -u chucknorris rm -rf /"
      expect(Scallop.sudo.cmd("ls").to_command).to eq "sudo ls"
      expect(Scallop.cmd(:echo, %w(1 2 3)).to_command).to eq "echo 1 2 3"
    end

    specify "escaping" do
      expect(Scallop.cmd("ls", "/path to/awesome file").to_command).to eq  "ls /path\\ to/awesome\\ file"
    end

    specify "parametrization" do
      expect(Scallop.cmd(:echo, Scallop.param(:foo)).set(foo: "bar").to_command).to eq "echo bar"
    end

    specify "parametrization merging" do
      expect(
        Scallop
          .cmd(:echo, Scallop.param(:foo), Scallop.param(:bar))
          .set(foo: "foo")
          .set(bar: "bar")
          .to_command
      ).to eq "echo foo bar"
    end

    specify "error on missing command" do
      expect do
        Scallop.sudo(:chucknorris).to_command
      end.to raise_error(Scallop::Errors::ValidationFailed)
    end

    specify "error on missing parameters" do
      expect do
        Scallop.cmd(:echo, Scallop.param(:foo)).to_command
      end.to raise_error(Scallop::Errors::ValidationFailed)
    end

    specify "immutability" do
      cmd1 = Scallop.cmd(:ls)
      cmd2 = cmd1.sudo(:chucknorris)

      expect(cmd1.to_command).to eq "ls"
      expect(cmd2.to_command).to eq "sudo -u chucknorris ls"

      cmd3 = Scallop.cmd(:echo, Scallop.param(:foo))
      cmd4 = cmd3.set(foo: "bar")
      cmd5 = cmd3.set(foo: "foo")

      expect(cmd4.to_command).to eq "echo bar"
      expect(cmd5.to_command).to eq "echo foo"
    end
  end

  describe "#run" do
    specify "successful command" do
      result = Scallop.cmd(:grep, "Lorem", fixture_path("lorem.txt")).run

      expect(result.stdout).to include("Lorem ipsum")
      expect(result.stderr).to be_empty
      expect(result.output).to include("Lorem ipsum")
      expect(result.success?).to eq true
    end

    specify "failed command without stderr" do
      result = Scallop.cmd(:grep, "bollocks", fixture_path("lorem.txt")).run

      expect(result.stdout).to be_empty
      expect(result.stderr).to be_empty
      expect(result.output).to be_empty
      expect(result.success?).to eq false
    end


    specify "failed command with stderr" do
      result = Scallop.cmd(:grep, "bollocks", "bollocks.txt").run

      expect(result.stdout).to be_empty
      expect(result.stderr).to include("No such file or directory")
      expect(result.output).to include("No such file or directory")
      expect(result.success?).to eq false
    end
  end

  describe "#run!" do
    specify "successful command" do
      result = Scallop.cmd(:grep, "Lorem", fixture_path("lorem.txt")).run!

      expect(result.stdout).to include("Lorem ipsum")
      expect(result.stderr).to be_empty
      expect(result.output).to include("Lorem ipsum")
      expect(result.success?).to eq true
    end

    specify "failed command with stderr" do
      expect do
        Scallop.cmd(:grep, "bollocks", "bollocks.txt").run!
      end.to raise_error do |error|
        expect(error).to be_a(Scallop::Errors::CommandFailed)
        expect(error).to respond_to(:result)

        expect(error.result.stdout).to be_empty
        expect(error.result.stderr).to include("No such file or directory")
        expect(error.result.output).to include("No such file or directory")
        expect(error.result.success?).to eq false
      end
    end
  end
end
