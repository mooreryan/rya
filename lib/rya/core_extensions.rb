module Rya
  # Contains extensions to core Ruby classes and modules.

  module CoreExtensions
    module Array
      # Scales with respect to the min and max of the data actually in the Array.
      def scale new_min, new_max
        old_min = self.min
        old_max = self.max

        self.scale_fixed old_min, old_max, new_min, new_max
      end

      # Scales with respect to a fixed old_min and old_max
      def scale_fixed old_min, old_max, new_min, new_max
        self.map do |elem|
          Rya::ExtendedClasses::MATH.scale elem, old_min, old_max, new_min, new_max
        end
      end
    end

    module Math
      def scale val, old_min, old_max, new_min, new_max
        # This can happen if you use the mean across non-zero samples.
        if old_max - old_min == 0
          # TODO better default value than this?
          (new_min + new_max) / 2;
        else
          ((((new_max - new_min) * (val - old_min)) / (old_max - old_min).to_f) + new_min)
        end

      end
    end

    module String

      # Use dynamic programming to find the length of the longest common substring.
      #
      # @param other The other string to test against.
      #
      # @example
      #   str = String.new("apple").extend Rya::CoreExtensions::String
      #   other = "ppie"
      #
      #   str.longest_common_substring other #=> 2
      #
      # @note This is the algorithm from https://www.geeksforgeeks.org/longest-common-substring/
      def longest_common_substring other
        if self.empty? || other.empty?
          return 0
        end

        self_len  = self.length
        other_len = other.length

        longest_common_suffix = Object::Array.new(self_len + 1) { Object::Array.new(other_len + 1, 0) }

        len = 0

        (self_len + 1).times do |i|
          (other_len + 1).times do |j|
            if i.zero? || j.zero? # this is for the dummy column
              longest_common_suffix[i][j] = 0
            elsif self[i - 1] == other[j - 1]
              val = longest_common_suffix[i - 1][j - 1] + 1
              longest_common_suffix[i][j] = val

              len = [len, val].max
            else
              longest_common_suffix[i][j] = 0
            end
          end
        end

        len
      end
    end

    module Time
      # Nicely format date and time
      def date_and_time fmt = "%F %T.%L"
        Object::Time.now.strftime fmt
      end

      # Run whatever is in the block and log the time it takes.
      def time_it title = "", logger = nil, run: true
        if run
          t = Object::Time.now

          yield

          time = Object::Time.now - t

          if title == ""
            msg = "Finished in #{time} seconds"
          else
            msg = "#{title} finished in #{time} seconds"
          end

          if logger
            logger.info msg
          else
            STDERR.puts msg
          end
        end
      end
    end

    module Process
      include CoreExtensions::Time

      # Runs a command and outputs stdout and stderr
      def run_it *a, &b
        exit_status, stdout, stderr = systemu *a, &b

        puts stdout unless stdout.empty?
        STDERR.puts stderr unless stderr.empty?

        exit_status
      end

      # Like run_it() but will raise Rya::AbortIf::Exit on non-zero exit status.
      def run_it! *a, &b
        exit_status = self.run_it *a, &b

        # Sometimes, exited? is not true and there will be no exit
        # status. Success should catch all failures.
        Rya::AbortIf.abort_unless exit_status.success?,
                                  "Command failed with status " \
                                      "'#{exit_status.to_s}' " \
                                      "when running '#{a.inspect}', " \
                                      "'#{b.inspect}'"

        exit_status
      end

      # Run a command and time it as well!
      #
      # @example
      #
      #   Process.extend Rya::CoreExtensions::Process
      #   Time.extend Rya::CoreExtensions::Time
      #
      #   Process.run_and_time_it! "Saying hello",
      #                            %Q{echo "hello world"}
      #
      #   Process.run_and_time_it! "This will raise SystemExit",
      #                            "ls arstoeiarntoairnt"
      def run_and_time_it! title = "",
                           cmd = "",
                           logger = Rya::AbortIf::logger,
                           &b

        Rya::AbortIf.logger.debug { "Running: #{cmd}" }

        time_it title, logger do
          run_it! cmd, &b
        end
      end
    end

  end
end

module Rya
  # Mainly for use within the CoreExtensions module definitions
  module ExtendedClasses
    MATH   = Class.new.extend(Rya::CoreExtensions::Math)
    STRING = Class.new.extend(Rya::CoreExtensions::String)
  end
end

