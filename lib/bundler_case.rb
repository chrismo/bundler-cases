require 'open3'

module VersionedBundlerCommand
  def versioned_bundler_command(cmd)
    ver = @version || @bundler_case.default_bundler_version || nil
    ensure_version_installed(ver) if ver
    ver ? cmd.gsub(/(?<!\.)(bundle )/, "bundle _#{ver}_ ") : cmd
  end

  def ensure_version_installed(ver)
    $installed ||= lookup_installed_bundler_versions
    unless $installed.include?(ver)
      puts "Installing bundler #{ver}..."
      `gem install bundler --version #{ver}`
      $installed = lookup_installed_bundler_versions
    end
  end

  def lookup_installed_bundler_versions
    `gem list bundler`.scan(/\Abundler \((.*)\)/).join.split(/, /)
  end
end

class BundlerCase
  extend Forwardable

  def self.define(options={}, &block)
    c = BundlerCase.new(options)
    c.instance_eval(&block)
    c
  end

  attr_reader :out_dir, :repo_dir, :failures, :default_bundler_version

  def initialize(options={})
    @reuse_out_dir = options[:reuse_out_dir]
    @default_bundler_version = options[:bundler_version] || options[:version]
    recreate_out_dir
    make_repo_dir

    # prolly should only support top-level step for non-step default
    # behavior OR nested ... but ... we'll see how this plays out
    @nested = []
    @step = Step.new(self)
    @step.given_bundler_version { @default_bundler_version } if @default_bundler_version
  end

  def step(description=nil, &block)
    Step.new(self, description).tap { |c| c.instance_eval(&block) }.tap { |s| @nested << s }
  end

  def repeat_step(step)
    @nested << step
  end

  def copy_setup(src)
    Dir["#{src}/*"].each { |src_fn| FileUtils.cp src_fn, out_dir }
  end

  def test
    @failures = []
    steps = @nested.empty? ? Array(@step) : @nested
    steps.each_with_index do |s, i|
      if s.description
        puts '#' * s.description.length
        puts s.description
        puts '#' * s.description.length
      end
      @failures = s.test(i + 1)
      break unless @failures.empty?
      puts
    end
    @failures.empty?
  end

  def gem_filename
    File.join(@out_dir, 'Gemfile')
  end

  def lock_filename
    File.join(@out_dir, 'Gemfile.lock')
  end

  private

  def recreate_out_dir
    @out_dir = File.expand_path('../out', __dir__)
    FileUtils.remove_entry_secure(@out_dir) if File.exist?(@out_dir) unless @reuse_out_dir
    FileUtils.makedirs @out_dir
  end

  def make_repo_dir
    @repo_dir = File.join(out_dir, 'repo')
    FileUtils.makedirs @repo_dir

    gems_dir = File.join(@repo_dir, 'gems')
    FileUtils.makedirs gems_dir
  end

  class Step
    include VersionedBundlerCommand

    attr_reader :description

    def initialize(bundler_case, description=nil)
      @bundler_case = bundler_case
      @description = description
      @failures = []
      @expected_specs = []
      @expected_not_specs = []
      @cmd = 'bundle install --path .bundle'
      @procs = []
    end

    def given_gems(&block)
      @procs << -> {
        instance_eval(&block)
        Dir.chdir(@bundler_case.repo_dir) do
          system 'gem generate_index'
        end
      }
    end

    def given_gemfile(opts={}, &block)
      contents = block.call.outdent
      swap_in_fake_repo(contents)
      @procs << -> { GemfileFixture.new(@bundler_case, contents, opts).build }
    end

    def given_lockfile(opts={}, &block)
      contents = block.call.outdent
      swap_in_fake_repo(contents)
      @procs << -> { File.open(@bundler_case.lock_filename, 'w') { |f| f.print contents } }
    end

    def given_gemspec
      # TODO
    end

    def given_bundler_version(&block)
      @version = block.call
    end

    def execute_bundler(&block)
      @cmd = block.call
    end

    def expect_output(&block)
      @expected_bundler_output = block.call
    end

    def expect_locked(&block)
      @expected_specs.concat(block.call.map do |name, ver|
        if ver.nil? && name.split(/ /).length == 2
          Gem::Specification.new(*name.split(/ /))
        else
          Gem::Specification.new(name, ver)
        end
      end)
    end

    def expect_not_locked(&block)
      @expected_not_specs.concat(block.call.map do |name, ver|
        Gem::Specification.new(name, ver)
      end)
    end

    def test(step_counter)
      Bundler.with_clean_env do
        ENV['BUNDLE_GEMFILE'] = @bundler_case.gem_filename
        Dir.chdir(@bundler_case.out_dir) do
          @procs.map(&:call)
          _execute_bundler(step_counter)
        end
      end

      @test_failures = []

      assert_outputs
      assert_specs

      @test_failures
    end

    def assert_specs
      unless @expected_specs.empty?
        lockfile = File.join(@bundler_case.out_dir, 'Gemfile.lock')
        parser = Bundler::LockfileParser.new(Bundler.read_file(lockfile))
        @test_failures.concat(ExpectedSpecs.new.failures(@expected_specs, parser.specs))
      end
    end

    def assert_outputs
      assert_output(@expected_bundler_output, @out)
    end

    def assert_output(to_match, to_search)
      if to_match
        case to_match
        when String
          re = /#{Regexp.escape(to_match)}/
          if to_search !~ re
            @test_failures << "Expected text not found: #{to_match}"
          end
        when Regexp
          if to_search !~ to_match
            @test_failures << "Expected text not found: #{to_match}"
          end
        else
          @test_failures << "Case definition failure. Unexpected type of expected text: #{to_match.class}"
        end
      end
    end

    private

    def _execute_bundler(step_counter)
      # Open3 is a 'better' way to do this, but I couldn't quickly figure out
      # how to stream output to console as well during the cmd. Since some installs
      # are long-running, not seeing any output until the cmd is finished is wonkers.
      cmd = versioned_bundler_command(@cmd)
      puts "=> #{cmd}"
      out_file = File.join(@bundler_case.out_dir, "step.#{step_counter}.out.txt")
      cmd = "#{cmd} 2>&1 | tee #{out_file}"
      system(cmd).tap do
        @out = File.read(out_file)
      end
    end

    def fake_gem(name, versions, deps=[], opts={})
      Array(versions).each do |ver|
        spec = Gem::Specification.new.tap do |s|
          s.name = name
          s.version = ver
          deps.each do |dep, *reqs|
            s.add_dependency dep, reqs
          end
        end

        if opts[:system]
          Dir.chdir(Dir.tmpdir) do
            Bundler.rubygems.build(spec, skip_validation = true)
            `gem install --ignore-dependencies --no-ri --no-rdoc #{spec.full_name}.gem`
          end
        else
          gems_dir = File.join(@bundler_case.repo_dir, 'gems')
          Dir.chdir(gems_dir) do
            Bundler.rubygems.build(spec, skip_validation = true)
          end
        end
      end
    end

    def fake_system_gem(name, versions, deps=[])
      fake_gem(name, versions, deps, system: true)
    end

    def swap_in_fake_repo(contents)
      contents.gsub!(/source +['"]fake["']/, %Q(source "file://#{@bundler_case.repo_dir}"))
    end
  end

  def_delegators :@step, *(Step.public_instance_methods(include_super = false) - [:test])

  class GemfileFixture
    include VersionedBundlerCommand

    def initialize(bundler_case, contents, opts={})
      @bundler_case = bundler_case
      @gem_filename = bundler_case.gem_filename
      @contents = contents
      @opts = opts
    end

    def build
      lock_down if @opts[:lock]

      write_gemfile_contents(@contents)
    end

    def write_gemfile_contents(contents)
      File.open(@gem_filename, 'w') { |f| f.print contents }
    end

    def lock_down
      pre_contents = @contents.dup
      lock = (@opts[:lock].is_a? TrueClass) ? [] : @opts[:lock]
      lock.each do |gem_lock|
        name, version = gem_lock.split(' ')
        re = /^\s*gem.*['"]\s*#{name}\s*['"].*$/
        unless pre_contents.gsub!(re, "gem '#{name}', '#{version}'")
          # NOTE: this could easily be problematic in many cases with multiple sources and whatnot ...
          # ... we can worry about this later. Sorry to whomever is now reading this and wishing they weren't
          pre_contents << "\n  gem '#{name}', '#{version}'"
        end
      end
      write_gemfile_contents(pre_contents)
      Dir.chdir(@bundler_case.out_dir) do
        cmd = versioned_bundler_command('bundle lock')
        puts "=> #{cmd}"
        system cmd
      end
    end
  end
end

class String
  def outdent
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end

class ExpectedSpecs
  def failures(expected, actual)
    res = []
    expected.each do |expect|
      found = actual.detect { |s| s.name == expect.name && s.version == expect.version }
      unless found
        found = actual.detect { |s| s.name == expect.name }
        if found
          res << "Expected #{expect.name} #{expect.version}, found #{found.name} #{found.version}"
        else
          res << "Expected #{expect.name} #{expect.version}, gem not found"
        end
      end
    end
    res
  end
end
