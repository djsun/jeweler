Given 'a working directory' do
  @working_dir = File.join(File.dirname(__FILE__), '..', '..', 'tmp')
  FileUtils.rm_rf @working_dir
  FileUtils.mkdir_p @working_dir
end

Given /^intentions to make a gem being tested by (\w+)$/ do |testing_framework|
  @testing_framework = testing_framework
end

Given /^I decide to call the project '((?:\w|-|_)+)'$/ do |name|
  @name = name
end

Given /I decide to summarize the project as '(.*)'/ do |summary|
  @summary = summary
end

Given /^I configure my email address as '(.*)'$/ do |user_email|
  @user_email = user_email
end

Given /^I configure my name as '(.*)'$/ do |user_name|
  @user_name = user_name
end

Given /^I configure my github username as '(.*)'$/ do |github_user|
  @github_user = github_user
end

Given /^I configure my github token as '(.*)'$/ do |github_token|
  @github_token = github_token
end


Given /^working git configuration$/ do
end

When /^I generate a project$/ do
  Jeweler::Generator.any_instance.stubs(:read_git_config).
        returns({
          'user.name' => @user_name,
          'user.email' => @user_email,
          'github.user' => @github_user,
          'github.token' => @github_token})

  @generator = Jeweler::Generator.new(@name, 
                                      :directory => "#{@working_dir}/#{@name}",
                                      :summary => @summary)

  @stdout = OutputCatcher.catch_out do
    @generator.run
  end
end

Then /^a directory named '(.*)' is created$/ do |directory|
  directory = File.join(@working_dir, directory)

  assert File.exists?(directory), "#{directory} did not exist"
  assert File.directory?(directory), "#{directory} is not a directory"
end

Then /^a file named '(.*)' is created$/ do |file|
  file = File.join(@working_dir, file)

  assert File.exists?(file), "#{file} did not exist"
  assert File.file?(file), "#{file} is not a file"
end

Then /^'(.*)' is ignored by git$/ do |git_ignore|
  @gitignore_content ||= File.read(File.join(@working_dir, @name, '.gitignore'))

  assert_match git_ignore, @gitignore_content
end

Then /^Rakefile has '(.*)' as the gem name$/ do |name|
  @rakefile_content ||= File.read(File.join(@working_dir, @name, 'Rakefile'))

  assert_match %Q{s.name = "#{name}"}, @rakefile_content
end

Then /^Rakefile has '(.*)' as the gem email$/ do |email|
  @rakefile_content ||= File.read(File.join(@working_dir, @name, 'Rakefile'))
  assert_match %Q{s.email = "#{email}"}, @rakefile_content
end

Then /^Rakefile has '(.*)' as the gem summary$/ do |summary|
  @rakefile_content ||= File.read(File.join(@working_dir, @name, 'Rakefile'))
  assert_match %Q{s.summary = %Q{#{summary}}}, @rakefile_content
end

Then /^Rakefile has '(.*)' as the gem homepage$/ do |homepage|
  @rakefile_content ||= File.read(File.join(@working_dir, @name, 'Rakefile'))
  assert_match %Q{s.homepage = "#{homepage}"}, @rakefile_content
end

Then /^Rakefile has '(.*)' in the Rake::TestTask pattern$/ do |pattern|
  @rakefile_content ||= File.read(File.join(@working_dir, @name, 'Rakefile'))

  assert_match %Q{t.pattern = '#{pattern}'}, @rakefile_content
end

Then /^Rakefile has '(.*)' in the Rcov::RcovTask test_pattern$/ do |test_pattern|

  @rakefile_content ||= File.read(File.join(@working_dir, @name, 'Rakefile'))

  assert_match "t.test_files = FileList['#{test_pattern}']", @rakefile_content

end

Then /^Rakefile has '(.*)' in the Rcov::RcovTask libs$/ do |libs|

  @rakefile_content ||= File.read(File.join(@working_dir, @name, 'Rakefile'))

  assert_match "t.libs << '#{libs}'", @rakefile_content

end

Then /^LICENSE has the copyright as belonging to '(.*)'$/ do |copyright_holder|
  @license_content ||= File.read(File.join(@working_dir, @name, 'LICENSE'))

  assert_match copyright_holder, @license_content
end

Then /^LICENSE has the copyright as being in (\d{4})$/ do |year|
  @license_content ||= File.read(File.join(@working_dir, @name, 'LICENSE'))

  assert_match year, @license_content
end


After do
  FileUtils.rm_rf @working_dir if @working_dir
end
