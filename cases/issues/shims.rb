def do_system(cmd)
  puts "=> #{cmd}"
  result = system cmd
  puts "ERR" if !result
end

def uninstall_bundler
  do_system 'gem uninstall bundler -a -x --force'
end

def uninstall_rg
  do_system 'gem uninstall rubygems-update -a -x --force'
end

def install_bundler(version)
  do_system "gem install bundler -v #{version}"
end

def install_rg(version)
  do_system "gem update --system #{version}"
end

def exec
  do_system 'bundle exec bundle exec ls'
end


def combos
  bundlers = %w(1.12.6 1.13.6)
  rgs = %w(2.6.1 2.6.2)
  uninstall_bundlers = [true, false]
  uninstall_rgs = [true, false]

  bundlers.each do |bundler_version|
    rgs.each do |rg_version|
      uninstall_bundlers.each do |un_bund|
        uninstall_rgs.each do |un_rg|
          puts "bu: #{bundler_version} | rg: #{rg_version} | un_bu: #{un_bund}  | un_rg: #{un_rg}"

          uninstall_rg if un_rg
          uninstall_bundler if un_bund
          install_rg(rg_version)
          install_bundler(bundler_version)
          exec

          puts '-' * 120
        end
      end
    end
  end

end

combos






# BundlerCase.define do
#   step do
#     given_rubygems_version { '2.6.1' }
#     given_bundler_version { '1.12.6' }
#     given_gemfile do
#       <<-__
#         source 'https://rubygems.org'
#       __
#     end
#     execute_bundler { 'bundle exec bundle exec ls' }
#     expect_output { 'Gemfile.lock' }
#   end
#
#   step do
#     given_rubygems_version { '2.6.2' }
#     given_bundler_version { '1.13.6' }
#     given_gemfile do
#       <<-__
#         source 'https://rubygems.org'
#       __
#     end
#     execute_bundler { 'bundle exec bundle exec ls' }
#     expect_output { 'Gemfile.lock' }
#   end
#
#   step do
#     given_rubygems_version { '2.6.2' }
#     given_bundler_version { '1.12.6' }
#     given_gemfile do
#       <<-__
#         source 'https://rubygems.org'
#       __
#     end
#     execute_bundler { 'bundle exec bundle exec ls' }
#     expect_output { 'Gemfile.lock' }
#   end
#
# end
