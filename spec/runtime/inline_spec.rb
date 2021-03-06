require "spec_helper"

describe "bundler/inline#gemfile" do
  def script(code, options = {})
    @out = ruby("require 'bundler/inline'\n\n" << code, options)
  end

  before :each do
    build_lib "one", "1.0.0" do |s|
      s.write "lib/baz.rb", "puts 'baz'"
      s.write "lib/qux.rb", "puts 'qux'"
    end

    build_lib "two", "1.0.0" do |s|
      s.write "lib/two.rb", "puts 'two'"
      s.add_dependency "three", "= 1.0.0"
    end

    build_lib "three", "1.0.0" do |s|
      s.write "lib/three.rb", "puts 'three'"
      s.add_dependency "seven", "= 1.0.0"
    end

    build_lib "four", "1.0.0" do |s|
      s.write "lib/four.rb", "puts 'four'"
    end

    build_lib "five", "1.0.0", :no_default => true do |s|
      s.write "lib/mofive.rb", "puts 'five'"
    end

    build_lib "six", "1.0.0" do |s|
      s.write "lib/six.rb", "puts 'six'"
    end

    build_lib "seven", "1.0.0" do |s|
      s.write "lib/seven.rb", "puts 'seven'"
    end

    build_lib "eight", "1.0.0" do |s|
      s.write "lib/eight.rb", "puts 'eight'"
    end

    build_lib "four", "1.0.0" do |s|
      s.write "lib/four.rb", "puts 'four'"
    end

    @gemfile = <<-G
      path "#{lib_path}"
      gem "two"
      gem "four", :require => false
    G
  end

  it "requires the gems" do
    script <<-RUBY
      gemfile do
        path "#{lib_path}"
        gem "two"
      end
    RUBY

    expect(out).to eq("two")
    expect(exitstatus).to be_zero if exitstatus

    script <<-RUBY, :expect_err => true
      gemfile do
        path "#{lib_path}"
        gem "eleven"
      end

      puts "success"
    RUBY

    expect(err).to include "Could not find gem 'eleven (>= 0) ruby'"
    expect(out).not_to include "success"

    script <<-RUBY
      gemfile(true) do
        source "file://#{gem_repo1}"
        gem "rack"
      end
    RUBY

    expect(out).to include("Rack's post install message")
    expect(exitstatus).to be_zero if exitstatus
  end
end
