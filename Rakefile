RUBY = '2.0.0'


task :install do
   do_install()
end


def do_install()
  install_ruby()
  install_gems()
end


def install_ruby()
  rvm("install " + RUBY)
  use_ruby(RUBY)
end


def use_ruby(version)
  rvm("use " + RUBY)
end


def rvm(command)
  system("rvm " + command)
end


def install_gems()
  system("bundle install")
end


task :clean do
  clean()
end


def clean()
  clean()
end


def clean()
  system("find . -name '*~' -delete")
  system("find . -name '*.orig' -delete")
end


task :test do
  puts "Needs implementing!"
end


task :count do
  clean()
  system("find . -name '*.rb' | xargs wc -l")
end


task :commit do
  commit()
end


def commit()
  clean()
  add()
  status()
  system("git commit -m 'Auto-update'")
end


def add()
  system("git add -A")
end


task :push do(branch="master")
  push(branch)
end


def push(branch)
  system("git push origin " + branch)
end


task :pull do(branch="master")
  pull(branch)
end


def pull(branch)
  system("git pull origin " + branch)
end


task :status do
  status()
end


def status
  system("git status")
end


task :save do(branch="master")
  commit()
  pull(branch)
  push(branch)
end


task :deploy do
  do_install()
  system("git push heroku master")
end


task :log do
  # Git formats
  git_log_medium_format = "%C(bold)Commit%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B"
  #git_log_oneline_format = "%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n"
  #git_log_brief_format = "%C(green)%h%C(reset) %s%n%C(blue)(%ar by %an)%C(red)%d%C(reset)%n"


  # Git aliases
  #gl="git log --topo-order --pretty=format${_git_log_medium_format}" + wrap_quotes(git_log_medium_format)
  gls="git log --topo-order --stat --pretty=format" + wrap_quotes(git_log_medium_format)
  #gld="git log --topo-order --stat --patch --full-diff --pretty=format" + wrap_quotes(git_log_medium_format)
  #glo="git log --topo-order --pretty=format" + wrap_quotes(git_log_oneline_format)
  #glg="git log --topo-order --all --graph --pretty=format" + wrap_quotes(git_log_oneline_format)
  #glb="git log --topo-order --pretty=format" + wrap_quotes(git_log_brief_format)
  #glc="git shortlog --summary --numbered"

  system(gls)
end


def wrap_quotes(s)
  "'" + s + "'"
end