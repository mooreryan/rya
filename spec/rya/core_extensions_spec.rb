RSpec.describe Rya::CoreExtensions do

  describe Rya::CoreExtensions::Array do
    let(:ary) { Array.new.extend Rya::CoreExtensions::Array }

    describe "#scale" do
      it "scales arrays" do
        ary << 0 << 75 << 50 << 25 << 100
        expected = [100, 175, 150, 125, 200]

        new_min = 100
        new_max = 200

        actual = ary.scale new_min, new_max

        expect(actual).to eq expected
      end

      it "can scale from high to low as well" do
        ary << 0 << 75 << 50 << 25 << 100
        expected = [200, 125, 150, 175, 100]

        new_min = 200
        new_max = 100

        actual = ary.scale new_min, new_max

        expect(actual).to eq expected
      end
    end
  end

  describe Rya::CoreExtensions::File do
    let(:klass) { Class.new { extend Rya::CoreExtensions::File }}

    describe "#command?" do
      it "is falsey if arg is not a executable command" do
        expect(klass.command? "asrotienaorsitenaoi").to be_falsey
      end

      it "returns full path of command if it is a command on the path" do
        expect(klass.command? "ls").to match "ls"
      end
    end
  end

  describe Rya::CoreExtensions::Math do
    let(:klass) { Class.new { extend Rya::CoreExtensions::Math } }

    describe "#scale" do
      it "returns avg of new_min and new_max if old_min and old_max are equal" do
        val     = 1
        old_min = 1
        old_max = 1
        new_min = 10
        new_max = 20

        expected = 15
        actual   = klass.scale val, old_min, old_max, new_min, new_max

        expect(actual).to eq expected
      end

      it "scales the val" do
        val     = 15
        old_min = 10
        old_max = 20
        new_min = 100
        new_max = 200

        expected = 150
        actual   = klass.scale val, old_min, old_max, new_min, new_max

        expect(actual).to eq expected
      end

      it "can reverse scales as well" do
        val     = 18
        old_min = 10
        old_max = 20
        new_min = 200
        new_max = 100

        expected = 120
        actual   = klass.scale val, old_min, old_max, new_min, new_max

        expect(actual).to eq expected
      end

    end
  end

  describe Rya::CoreExtensions::Process do
    let(:klass) { Class.new { extend Rya::CoreExtensions::Process } }

    describe "run_until_success" do
      let(:fail_sometimes) { File.join __dir__, "..", "test_programs", "fail_sometimes.rb" }

      it "runs a program until it's successful" do
        tries = 2
        pass_chance = 1
        cmd = "#{fail_sometimes} #{pass_chance}"

        klass.run_until_success tries do
          klass.run_it cmd
        end
      end

      it "raises an error if the program doesn't complete in alloted tries" do
        tries = 2
        pass_chance = 0
        cmd = "#{fail_sometimes} #{pass_chance}"

        error = Rya::MaxAttemptsExceededError

        expect do
          klass.run_until_success tries do
            klass.run_it cmd
          end
        end.to raise_error error
      end

      it "raises an error if the block doesn't return a value that responds to exitstatus" do
        error = Rya::Error

        expect do
          klass.run_until_success 10 do
            klass.run_it "echo 'hi'"

            puts "this will return nil"
          end
        end.to raise_error error
      end
    end

    describe "#run_it" do
      it "runs command and returns a Process::Status object" do
        proc_status = klass.run_it "echo 'hi'"

        expect(proc_status).to be_a Process::Status
      end

      it "gives a proc status with good exitstatus on good command" do
        proc_status = klass.run_it "echo 'hi'"

        expect(proc_status.exitstatus).to be_zero
      end

      it "writes the stdout of the command" do
        expect { klass.run_it "echo 'hi'" }.to output("hi\n").to_stdout
      end

      # it "writes the stderr of the command" do
      #   prog = %q{ruby -e 'STDERR.puts "hi"'}
      #   expect { klass.run_it prog }.to output("hi\n").to_stdout
      # end

      it "gives proc status with bad exitstatus on failing command" do
        proc_status = klass.run_it "rya___arstoien"

        expect(proc_status.exitstatus).not_to be_zero
      end
    end

    describe "#run_it!" do
      it "raises error with bad command" do
        expect { klass.run_it! "rya___arstoien" }.to raise_error Rya::AbortIf::Exit
      end

      it "runs commands" do
        expect { klass.run_it! "echo 'hi'" }.to output("hi\n").to_stdout
      end
    end

    describe "#run_and_time_it!" do
      let(:title) { "Apple pie" }

      it "raises error with bad command" do
        expect do
          klass.run_and_time_it! title, "rya___arstoien"
        end.to raise_error Rya::AbortIf::Exit
      end

      it "logs the command being run" do
        expect do
          klass.run_and_time_it! title, "echo 'hi' > /dev/null"
        end.to output(/Running: echo/).to_stderr_from_any_process
      end

      it "also logs the title" do
        expect do
          klass.run_and_time_it! title, "echo 'hi' > /dev/null"
        end.to output(/Apple pie finished in/).to_stderr_from_any_process
      end
    end
  end

  describe Rya::CoreExtensions::String do
    let(:str) { String.new.extend Rya::CoreExtensions::String }

    describe "#longest_common_substring" do
      it "gives length of longest common substring" do
        str << "apple"
        other = "ppie"

        expect(str.longest_common_substring other).to eq 2
      end

      it "test 2" do
        str << "apple"
        other = "aaaaaaaple"

        expect(str.longest_common_substring other).to eq 3
      end

      it "test 3" do
        str << "apple"
        other = "zzzplezzzpleezzz"

        expect(str.longest_common_substring other).to eq 3
      end


      it "gives zero when no common substring" do
        str << "apple"
        other = "foo"

        expect(str.longest_common_substring other).to eq 0
      end

      it "gives zero when self is empty" do
        other = "ryan"

        expect(str.longest_common_substring other).to eq 0
      end

      it "gives zero when other is empty" do
        str << "apple"
        other = ""

        expect(str.longest_common_substring other).to eq 0
      end

      it "gives zero when both are empty" do
        other = ""

        expect(str.longest_common_substring other).to eq 0
      end
    end
  end

  describe Rya::CoreExtensions::Time do
    let(:klass) { Class.new { extend Rya::CoreExtensions::Time } }

    describe "#time_it" do
      it "does whatever is in the block" do
        foo = 10

        klass.time_it do
          foo += 10
        end

        expect(foo).to eq 20
      end

      it "times whatever is in the block" do
        expect do
          klass.time_it do
            # Do something
          end
        end.to output(/Finished in .* seconds/).to_stderr_from_any_process
      end

      it "can take a special message" do
        expect do
          klass.time_it "Listing dirs" do
            # Do something
          end
        end.to output(/Listing dirs/).to_stderr_from_any_process
      end

      it "can take a special logger" do
        expect do
          klass.time_it "Apple", Rya::AbortIf.logger do
            # Do something
          end
        end.to output(/Apple/).to_stderr_from_any_process
      end

      it "can optionally skip what's in the block" do
        foo = 10

        expect do
          klass.time_it run: false do
            foo += 10
          end
        end.not_to output.to_stderr_from_any_process

        expect(foo).to eq 10
      end
    end
  end

end
