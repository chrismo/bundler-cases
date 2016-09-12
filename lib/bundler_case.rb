class BundlerCase
  extend Forwardable

  def self.define(options={}, &block)
    c = BundlerCase.new(options)
    c.instance_eval(&block)
    c
  end

  attr_reader :out_dir, :repo_dir, :failures

  def initialize(options={})
    @reuse_out_dir = options[:reuse_out_dir]
    recreate_out_dir
    make_repo_dir

    # prolly should only support top-level step for non-step default
    # behavior OR nested ... but ... we'll see how this plays out
    @nested = []
    @step = Step.new(self)
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
    steps.each do |s|
      if s.description
        puts '#' * s.description.length
        puts s.description
        puts '#' * s.description.length
      end
      @failures = s.test
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
      @procs << -> {
        installed = `gem list bundler`.scan(/\Abundler \((.*)\)/).join.split(/, /)
        unless installed.include?(@version)
          puts "Installing bundler #{@version}..."
          `gem install bundler --version #{@version}`
        end
      }
    end

    def execute_bundler(&block)
      @cmd = block.call
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

    def test
      bundler_result = true

      Bundler.with_clean_env do
        ENV['BUNDLE_GEMFILE'] = @bundler_case.gem_filename
        Dir.chdir(@bundler_case.out_dir) do
          @procs.map(&:call)
          bundler_result = _execute_bundler
        end
      end

      test_failures = []

      unless @expected_specs.empty?
        lockfile = File.join(@bundler_case.out_dir, 'Gemfile.lock')
        parser = Bundler::LockfileParser.new(Bundler.read_file(lockfile))
        test_failures.concat(ExpectedSpecs.new.failures(@expected_specs, parser.specs))
      end

      unless bundler_result
        unless @expect_bundler_failure
          test_failures << 'Bundle command failed'
        end
      end

      test_failures
    end

    private

    def _execute_bundler
      cmd = @version ? @cmd.gsub(/(?<!\.)(bundle )/, "bundle _#{@version}_ ") : @cmd
      puts "=> #{cmd}"
      system cmd
    end

    def fake_gem(name, versions, deps=[])
      Array(versions).each do |ver|
        spec = Gem::Specification.new.tap do |s|
          s.name = name
          s.version = ver
          deps.each do |dep, *reqs|
            s.add_dependency dep, reqs
          end
        end

        gems_dir = File.join(@bundler_case.repo_dir, 'gems')
        Dir.chdir(gems_dir) do
          Bundler.rubygems.build(spec, skip_validation = true)
        end
      end
    end

    def swap_in_fake_repo(contents)
      contents.gsub!(/source +['"]fake["']/, %Q(source "file://#{@bundler_case.repo_dir}"))
    end
  end

  def_delegators :@step, *(Step.public_instance_methods(include_super = false) - [:test])

  class GemfileFixture
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
      @opts[:lock].each do |gem_lock|
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
        cmd = 'bundle lock'
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
