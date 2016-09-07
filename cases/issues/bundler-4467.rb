BundlerCase.define reuse_out_dir: true do
  step do
    given_gemfile do
      <<-G
    source 'https://rubygems.org'

    gem 'rails', '~> 4.2.0'

    gem 'mysql2', group: :mysql
    gem 'pg', group: :postgres
    gem 'sqlite3', group: :sqlite

    gem 'sass-rails', '~> 4.0.0'

    gem 'uglifier', '>= 1.3.0'

    gem 'coffee-rails', '~> 4.0.0'

    # gem 'therubyracer', platforms: :ruby

    gem 'jquery-rails'
    gem 'jquery-ui-rails'

    gem 'turbolinks'
    #gem 'jquery-turbolinks'

    gem 'jbuilder', '~> 1.2'

    group :doc do
      gem 'sdoc', require: false
    end

    group :development do
      gem 'better_errors'
      gem 'binding_of_caller'
      gem 'byebug'
      gem 'meta_request'
      gem 'thin'
      gem 'quiet_assets'
      # 4.2
      gem 'web-console', '~> 2.0'
      gem 'spring'
    end

    # 4.2
    gem 'responders', '~> 2.0'

    # UI
    gem 'hirb'
    gem 'font-awesome-rails'
    gem 'bootstrap-sass'
    gem 'haml-rails'
    gem 'haml'
    gem 'simple_form', '~> 3.0.0.rc'

    gem 'nokogiri'

    gem 'kramdown'

    gem 'ancestry'
    gem 'acts_as_list'

    gem 'cocaine'
    gem 'paperclip'


    gem 'kaminari'
    gem 'kaminari-bootstrap'

    gem 'rack-mini-profiler', require: false
    gem 'rack-utf8_sanitizer'

    gem 'actionpack-page_caching'
    gem 'dalli'
    gem 'exception_notification'
    gem 'typhoeus'

    gem 'pandoc-ruby'

    gem 'newrelic_rpm', group: :new_relic
      G
    end

    given_lockfile do
      <<-L
    GEM
      remote: https://rubygems.org/
      specs:
        actionmailer (4.2.5.2)
          actionpack (= 4.2.5.2)
          actionview (= 4.2.5.2)
          activejob (= 4.2.5.2)
          mail (~> 2.5, >= 2.5.4)
          rails-dom-testing (~> 1.0, >= 1.0.5)
        actionpack (4.2.5.2)
          actionview (= 4.2.5.2)
          activesupport (= 4.2.5.2)
          rack (~> 1.6)
          rack-test (~> 0.6.2)
          rails-dom-testing (~> 1.0, >= 1.0.5)
          rails-html-sanitizer (~> 1.0, >= 1.0.2)
        actionpack-page_caching (1.0.2)
          actionpack (>= 4.0.0, < 5)
        actionview (4.2.5.2)
          activesupport (= 4.2.5.2)
          builder (~> 3.1)
          erubis (~> 2.7.0)
          rails-dom-testing (~> 1.0, >= 1.0.5)
          rails-html-sanitizer (~> 1.0, >= 1.0.2)
        activejob (4.2.5.2)
          activesupport (= 4.2.5.2)
          globalid (>= 0.3.0)
        activemodel (4.2.5.2)
          activesupport (= 4.2.5.2)
          builder (~> 3.1)
        activerecord (4.2.5.2)
          activemodel (= 4.2.5.2)
          activesupport (= 4.2.5.2)
          arel (~> 6.0)
        activesupport (4.2.5.2)
          i18n (~> 0.7)
          json (~> 1.7, >= 1.7.7)
          minitest (~> 5.1)
          thread_safe (~> 0.3, >= 0.3.4)
          tzinfo (~> 1.1)
        acts_as_list (0.4.0)
          activerecord (>= 3.0)
        ancestry (2.1.0)
          activerecord (>= 3.0.0)
        arel (6.0.3)
        better_errors (2.0.0)
          coderay (>= 1.0.0)
          erubis (>= 2.6.6)
          rack (>= 0.9.0)
        binding_of_caller (0.7.2)
          debug_inspector (>= 0.0.1)
        bootstrap-sass (3.2.0.2)
          sass (~> 3.2)
        builder (3.2.2)
        byebug (8.2.2)
        callsite (0.0.11)
        climate_control (0.0.3)
          activesupport (>= 3.0)
        cocaine (0.5.8)
          climate_control (>= 0.0.3, < 1.0)
        coderay (1.1.0)
        coffee-rails (4.0.1)
          coffee-script (>= 2.2.0)
          railties (>= 4.0.0, < 5.0)
        coffee-script (2.3.0)
          coffee-script-source
          execjs
        coffee-script-source (1.8.0)
        daemons (1.1.9)
        dalli (2.7.4)
        debug_inspector (0.0.2)
        erubis (2.7.0)
        ethon (0.8.1)
          ffi (>= 1.3.0)
        eventmachine (1.2.0.1)
        exception_notification (4.1.4)
          actionmailer (~> 4.0)
          activesupport (~> 4.0)
        execjs (2.2.2)
        ffi (1.9.10)
        font-awesome-rails (4.2.0.0)
          railties (>= 3.2, < 5.0)
        globalid (0.3.6)
          activesupport (>= 4.1.0)
        haml (4.0.5)
          tilt
        haml-rails (0.5.3)
          actionpack (>= 4.0.1)
          activesupport (>= 4.0.1)
          haml (>= 3.1, < 5.0)
          railties (>= 4.0.1)
        hike (1.2.3)
        hirb (0.7.2)
        i18n (0.7.0)
        jbuilder (1.5.3)
          activesupport (>= 3.0.0)
          multi_json (>= 1.2.0)
        jquery-rails (3.1.2)
          railties (>= 3.0, < 5.0)
          thor (>= 0.14, < 2.0)
        jquery-ui-rails (5.0.2)
          railties (>= 3.2.16)
        json (1.8.3)
        kaminari (0.16.1)
          actionpack (>= 3.0.0)
          activesupport (>= 3.0.0)
        kaminari-bootstrap (3.0.1)
          kaminari (>= 0.13.0)
          rails
        kramdown (1.10.0)
        loofah (2.0.3)
          nokogiri (>= 1.5.9)
        mail (2.6.3)
          mime-types (>= 1.16, < 3)
        meta_request (0.3.4)
          callsite (~> 0.0, >= 0.0.11)
          rack-contrib (~> 1.1)
          railties (>= 3.0.0, < 5.0.0)
        mime-types (2.99.1)
        mini_portile2 (2.0.0)
        minitest (5.8.4)
        multi_json (1.11.2)
        mysql2 (0.4.3)
        newrelic_rpm (3.15.0.314)
        nokogiri (1.6.7.2)
          mini_portile2 (~> 2.0.0.rc2)
        pandoc-ruby (1.0.0)
        paperclip (4.2.0)
          activemodel (>= 3.0.0)
          activesupport (>= 3.0.0)
          cocaine (~> 0.5.3)
          mime-types
        pg (0.18.4)
        quiet_assets (1.0.3)
          railties (>= 3.1, < 5.0)
        rack (1.6.4)
        rack-contrib (1.1.0)
          rack (>= 0.9.1)
        rack-mini-profiler (0.9.2)
          rack (>= 1.1.3)
        rack-test (0.6.3)
          rack (>= 1.0)
        rack-utf8_sanitizer (1.3.2)
          rack (>= 1.0, < 3.0)
        rails (4.2.5.2)
          actionmailer (= 4.2.5.2)
          actionpack (= 4.2.5.2)
          actionview (= 4.2.5.2)
          activejob (= 4.2.5.2)
          activemodel (= 4.2.5.2)
          activerecord (= 4.2.5.2)
          activesupport (= 4.2.5.2)
          bundler (>= 1.3.0, < 2.0)
          railties (= 4.2.5.2)
          sprockets-rails
        rails-deprecated_sanitizer (1.0.3)
          activesupport (>= 4.2.0.alpha)
        rails-dom-testing (1.0.7)
          activesupport (>= 4.2.0.beta, < 5.0)
          nokogiri (~> 1.6.0)
          rails-deprecated_sanitizer (>= 1.0.1)
        rails-html-sanitizer (1.0.3)
          loofah (~> 2.0)
        railties (4.2.5.2)
          actionpack (= 4.2.5.2)
          activesupport (= 4.2.5.2)
          rake (>= 0.8.7)
          thor (>= 0.18.1, < 2.0)
        rake (11.1.1)
        rdoc (4.1.2)
          json (~> 1.4)
        responders (2.1.0)
          railties (>= 4.2.0, < 5)
        sass (3.2.19)
        sass-rails (4.0.3)
          railties (>= 4.0.0, < 5.0)
          sass (~> 3.2.0)
          sprockets (~> 2.8, <= 2.11.0)
          sprockets-rails (~> 2.0)
        sdoc (0.4.1)
          json (~> 1.7, >= 1.7.7)
          rdoc (~> 4.0)
        simple_form (3.0.4)
          actionpack (~> 4.0)
          activemodel (~> 4.0)
        spring (1.3.3)
        sprockets (2.11.0)
          hike (~> 1.2)
          multi_json (~> 1.0)
          rack (~> 1.0)
          tilt (~> 1.1, != 1.3.0)
        sprockets-rails (2.3.3)
          actionpack (>= 3.0)
          activesupport (>= 3.0)
          sprockets (>= 2.8, < 4.0)
        sqlite3 (1.3.11)
        thin (1.6.3)
          daemons (~> 1.0, >= 1.0.9)
          eventmachine (~> 1.0)
          rack (~> 1.0)
        thor (0.19.1)
        thread_safe (0.3.5)
        tilt (1.4.1)
        turbolinks (2.5.1)
          coffee-rails
        typhoeus (1.0.1)
          ethon (>= 0.8.0)
        tzinfo (1.2.2)
          thread_safe (~> 0.1)
        uglifier (2.5.3)
          execjs (>= 0.3.0)
          json (>= 1.8.0)
        web-console (2.3.0)
          activemodel (>= 4.0)
          binding_of_caller (>= 0.7.2)
          railties (>= 4.0)
          sprockets-rails (>= 2.0, < 4.0)

    PLATFORMS
      ruby

    DEPENDENCIES
      actionpack-page_caching
      acts_as_list
      ancestry
      better_errors
      binding_of_caller
      bootstrap-sass
      byebug
      cocaine
      coffee-rails (~> 4.0.0)
      dalli
      exception_notification
      font-awesome-rails
      haml
      haml-rails
      hirb
      jbuilder (~> 1.2)
      jquery-rails
      jquery-ui-rails
      kaminari
      kaminari-bootstrap
      kramdown
      meta_request
      mysql2
      newrelic_rpm
      nokogiri
      pandoc-ruby
      paperclip
      pg
      quiet_assets
      rack-mini-profiler
      rack-utf8_sanitizer
      rails (~> 4.2.0)
      responders (~> 2.0)
      sass-rails (~> 4.0.0)
      sdoc
      simple_form (~> 3.0.0.rc)
      spring
      sqlite3
      thin
      turbolinks
      typhoeus
      uglifier (>= 1.3.0)
      web-console (~> 2.0)
      L
    end

    given_bundler_version { '1.11.2' }

    execute_bundler { 'bundle install --deployment' }
  end

  step do
    # given_bundler_version { '1.10.5' } works in 1.10.5
    given_bundler_version { '1.11.0' }

    execute_bundler { 'bundle update simple_form' }
  end

  step do
    given_bundler_version { '1.13.0.rc.2' }

    execute_bundler { 'bundle update simple_form' }
  end
end
