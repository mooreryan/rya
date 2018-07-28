RSpec.describe Rya::CoreExtensions do

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

  describe Rya::CoreExtensions::Process do
    let(:klass) { Class.new { extend Rya::CoreExtensions::Process } }

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
        end.to output(/Running: echo/ ).to_stderr_from_any_process
      end

      it "also logs the title" do
        expect do
          klass.run_and_time_it! title, "echo 'hi' > /dev/null"
        end.to output(/Apple pie finished in/ ).to_stderr_from_any_process
      end
    end
  end
end
