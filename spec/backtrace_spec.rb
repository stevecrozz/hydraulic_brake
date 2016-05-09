require 'spec_helper'

RSpec.describe Airbrake::Backtrace do
  describe ".parse" do
    context "UNIX backtrace" do
      let(:backtrace) { described_class.new(AirbrakeTestError.new) }

      let(:parsed_backtrace) do
        # rubocop:disable Metrics/LineLength, Style/HashSyntax, Style/SpaceAroundOperators, Style/SpaceInsideHashLiteralBraces
        [{:file=>"/home/kyrylo/code/airbrake/ruby/spec/spec_helper.rb", :line=>23, :function=>"<top (required)>"},
         {:file=>"/opt/rubies/ruby-2.2.2/lib/ruby/2.2.0/rubygems/core_ext/kernel_require.rb", :line=>54, :function=>"require"},
         {:file=>"/opt/rubies/ruby-2.2.2/lib/ruby/2.2.0/rubygems/core_ext/kernel_require.rb", :line=>54, :function=>"require"},
         {:file=>"/home/kyrylo/code/airbrake/ruby/spec/airbrake_spec.rb", :line=>1, :function=>"<top (required)>"},
         {:file=>"/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb", :line=>1327, :function=>"load"},
         {:file=>"/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb", :line=>1327, :function=>"block in load_spec_files"},
         {:file=>"/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb", :line=>1325, :function=>"each"},
         {:file=>"/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/configuration.rb", :line=>1325, :function=>"load_spec_files"},
         {:file=>"/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb", :line=>102, :function=>"setup"},
         {:file=>"/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb", :line=>88, :function=>"run"},
         {:file=>"/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb", :line=>73, :function=>"run"},
         {:file=>"/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/lib/rspec/core/runner.rb", :line=>41, :function=>"invoke"},
         {:file=>"/home/kyrylo/.gem/ruby/2.2.2/gems/rspec-core-3.3.2/exe/rspec", :line=>4, :function=>"<main>"}]
        # rubocop:enable Metrics/LineLength, Style/HashSyntax,Style/SpaceAroundOperators, Style/SpaceInsideHashLiteralBraces
      end

      it "returns a properly formatted array of hashes" do
        expect(described_class.parse(AirbrakeTestError.new)).
          to eq(parsed_backtrace)
      end
    end

    context "Windows backtrace" do
      let(:windows_bt) do
        ["C:/Program Files/Server/app/models/user.rb:13:in `magic'",
         "C:/Program Files/Server/app/controllers/users_controller.rb:8:in `index'"]
      end

      let(:ex) { AirbrakeTestError.new.tap { |e| e.set_backtrace(windows_bt) } }

      let(:parsed_backtrace) do
        # rubocop:disable Metrics/LineLength, Style/HashSyntax, Style/SpaceInsideHashLiteralBraces, Style/SpaceAroundOperators
        [{:file=>"C:/Program Files/Server/app/models/user.rb", :line=>13, :function=>"magic"},
         {:file=>"C:/Program Files/Server/app/controllers/users_controller.rb", :line=>8, :function=>"index"}]
        # rubocop:enable Metrics/LineLength, Style/HashSyntax, Style/SpaceInsideHashLiteralBraces, Style/SpaceAroundOperators
      end

      it "returns a properly formatted array of hashes" do
        expect(described_class.parse(ex)).to eq(parsed_backtrace)
      end
    end

    context "JRuby Java exceptions" do
      let(:backtrace_array) do
        # rubocop:disable Metrics/LineLength, Style/HashSyntax, Style/SpaceInsideHashLiteralBraces, Style/SpaceAroundOperators
        [{:file=>"InstanceMethodInvoker.java", :line=>26, :function=>"org.jruby.java.invokers.InstanceMethodInvoker.call"},
         {:file=>"Interpreter.java", :line=>126, :function=>"org.jruby.ir.interpreter.Interpreter.INTERPRET_EVAL"},
         {:file=>"RubyKernel$INVOKER$s$0$3$eval19.gen", :line=>nil, :function=>"org.jruby.RubyKernel$INVOKER$s$0$3$eval19.call"},
         {:file=>"RubyKernel$INVOKER$s$0$0$loop.gen", :line=>nil, :function=>"org.jruby.RubyKernel$INVOKER$s$0$0$loop.call"},
         {:file=>"IRBlockBody.java", :line=>139, :function=>"org.jruby.runtime.IRBlockBody.doYield"},
         {:file=>"RubyKernel$INVOKER$s$rbCatch19.gen", :line=>nil, :function=>"org.jruby.RubyKernel$INVOKER$s$rbCatch19.call"},
         {:file=>"/opt/rubies/jruby-9.0.0.0/bin/irb", :line=>nil, :function=>"opt.rubies.jruby_minus_9_dot_0_dot_0_dot_0.bin.irb.invokeOther4:start"},
         {:file=>"/opt/rubies/jruby-9.0.0.0/bin/irb", :line=>13, :function=>"opt.rubies.jruby_minus_9_dot_0_dot_0_dot_0.bin.irb.RUBY$script"},
         {:file=>"Compiler.java", :line=>111, :function=>"org.jruby.ir.Compiler$1.load"},
         {:file=>"Main.java", :line=>225, :function=>"org.jruby.Main.run"},
         {:file=>"Main.java", :line=>197, :function=>"org.jruby.Main.main"}]
        # rubocop:enable Metrics/LineLength, Style/HashSyntax, Style/SpaceInsideHashLiteralBraces, Style/SpaceAroundOperators
      end

      it "returns a properly formatted array of hashes" do
        allow(described_class).to receive(:java_exception?).and_return(true)

        expect(described_class.parse(JavaAirbrakeTestError.new)).
          to eq(backtrace_array)
      end
    end

    context "generic backtrace" do
      context "when function is absent" do
        # rubocop:disable Metrics/LineLength
        let(:generic_bt) do
          ["/home/bingo/bango/assets/stylesheets/error_pages.scss:139:in `animation'",
           "/home/bingo/bango/assets/stylesheets/error_pages.scss:139",
           "/home/bingo/.gem/ruby/2.2.2/gems/sass-3.4.20/lib/sass/tree/visitors/perform.rb:349:in `block in visit_mixin'"]
        end
        # rubocop:enable Metrics/LineLength

        let(:ex) { AirbrakeTestError.new.tap { |e| e.set_backtrace(generic_bt) } }

        let(:parsed_backtrace) do
          # rubocop:disable Metrics/LineLength, Style/HashSyntax, Style/SpaceInsideHashLiteralBraces, Style/SpaceAroundOperators
          [{:file=>"/home/bingo/bango/assets/stylesheets/error_pages.scss", :line=>139, :function=>"animation"},
           {:file=>"/home/bingo/bango/assets/stylesheets/error_pages.scss", :line=>139, :function=>nil},
           {:file=>"/home/bingo/.gem/ruby/2.2.2/gems/sass-3.4.20/lib/sass/tree/visitors/perform.rb", :line=>349, :function=>"block in visit_mixin"}]
          # rubocop:enable Metrics/LineLength, Style/HashSyntax, Style/SpaceInsideHashLiteralBraces, Style/SpaceAroundOperators
        end

        it "returns a properly formatted array of hashes" do
          expect(described_class.parse(ex)).to eq(parsed_backtrace)
        end
      end

      context "when line is absent" do
        let(:generic_bt) do
          ["/Users/grammakov/repositories/weintervene/config.ru:in `new'"]
        end

        let(:ex) { AirbrakeTestError.new.tap { |e| e.set_backtrace(generic_bt) } }

        let(:parsed_backtrace) do
          [{ file: '/Users/grammakov/repositories/weintervene/config.ru',
             line: nil,
             function: 'new' }]
        end

        it "returns a properly formatted array of hashes" do
          expect(described_class.parse(ex)).to eq(parsed_backtrace)
        end
      end
    end

    context "unknown backtrace" do
      let(:unknown_bt) { ['a b c 1 23 321 .rb'] }

      let(:ex) { AirbrakeTestError.new.tap { |e| e.set_backtrace(unknown_bt) } }

      it "raises error" do
        expect { described_class.parse(ex) }.
          to raise_error(Airbrake::Error, /can't parse/)
      end
    end

    context "given a backtrace with an empty function" do
      let(:bt) do
        ["/airbrake-ruby/vendor/jruby/1.9/gems/rspec-core-3.4.1/exe/rspec:3:in `'"]
      end

      let(:ex) { AirbrakeTestError.new.tap { |e| e.set_backtrace(bt) } }

      let(:parsed_backtrace) do
        [{ file: '/airbrake-ruby/vendor/jruby/1.9/gems/rspec-core-3.4.1/exe/rspec',
           line: 3,
           function: '' }]
      end

      it "returns a properly formatted array of hashes" do
        expect(described_class.parse(ex)).to eq(parsed_backtrace)
      end
    end
  end
end
