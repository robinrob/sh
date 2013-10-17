import subprocess
import logging
import os
import shutil

from fabric.decorators import task

# Configurable parameters
PYTHONBREW_DIR = "~/.pythonbrew"

SRC_DIR = './'

PYTHON3 = '3.2'

# Do not change this - used in initial installation
PYTHON_APP = "python_app.py"


@task
def new(destination=""):
    subprocess.call("git clone -b master git@bitbucket.org:robinrob/python_app.git " + destination, shell=True)
    install(destination)


@task
def install(destination=None):
    if destination is not None:
        os.chdir(destination)

    if os.path.exists(PYTHON_APP):
        cwd_name = os.getcwd().split(os.sep)[-1]
        os.rename(PYTHON_APP, cwd_name + '.py')
        shutil.rmtree(".git")

    install_python()
    install_requirements()


def install_python():
    subprocess.call("pythonbrew install " + PYTHON3, shell=True)


def use_python(version):
    subprocess.call("pythonbrew use " + version, shell=True)


def install_requirements():
    use_python(PYTHON3)
    subprocess.call("pip install -r requirements.txt", shell=True)


@task
def clean():
    subprocess.call("find . -name '*.pyc' -delete", shell=True)
    subprocess.call("find . -name '*~' -delete", shell=True)
    subprocess.call("find . -name '__pycache__' -delete", shell=True)


@task
def test():
    subprocess.call("nosetests", shell=True)


@task
def run(app=PYTHON_APP, args="Hello\!"):
    subprocess.call("pythonbrew py -p " + PYTHON3 + " " + app + " " + args, shell=True)


@task
def count():
    clean()
    subprocess.call("find . -name '*.py' | xargs wc -l", shell=True)


@task
def commit(message="Auto-update."):
    clean()
    subprocess.call("git add *", shell=True)
    subprocess.call("git add .gitignore", shell=True)
    subprocess.call("git add -u", shell=True)
    subprocess.call("git add README.md --ignore-errors", shell=True)
    subprocess.call("git add requirements.txt --ignore-errors", shell=True)
    status()
    subprocess.call("git commit -m '" + message + "'", shell=True)
    

@task
def push(branch="master"):
    subprocess.call("git push origin " + branch, shell=True)
    
    
@task
def pull(branch="master"):    subprocess.call("git pull origin " + branch, shell=True)
    
    
@task
def status():
    subprocess.call("git status", shell=True)
    
    
@task
def log():
    subprocess.call("git log", shell=True)


@task
def deploy(message="Auto-update", branch="master"):
    commit(message)
    pull(branch)
    push(branch)
    
    
@task
def log():
    # Git formats
    git_log_medium_format = "%C(bold)Commit:%C(reset) %C(green)%H%C(red)%d%n%C(bold)Author:%C(reset) %C(cyan)%an <%ae>%n%C(bold)Date:%C(reset)   %C(blue)%ai (%ar)%C(reset)%n%+B"
    #git_log_oneline_format = "%C(green)%h%C(reset) %s%C(red)%d%C(reset)%n"
    #git_log_brief_format = "%C(green)%h%C(reset) %s%n%C(blue)(%ar by %an)%C(red)%d%C(reset)%n"


    # Git aliases
    #gl="git log --topo-order --pretty=format:${_git_log_medium_format}" + wrap_quotes(git_log_medium_format)
    gls="git log --topo-order --stat --pretty=format:" + wrap_quotes(git_log_medium_format)
    #gld="git log --topo-order --stat --patch --full-diff --pretty=format:" + wrap_quotes(git_log_medium_format)
    #glo="git log --topo-order --pretty=format:" + wrap_quotes(git_log_oneline_format)
    #glg="git log --topo-order --all --graph --pretty=format:" + wrap_quotes(git_log_oneline_format)
    #glb="git log --topo-order --pretty=format:" + wrap_quotes(git_log_brief_format)
    #glc="git shortlog --summary --numbered"


    subprocess.call(gls, shell=True)


def wrap_quotes(s):
    return "'" + s + "'"

@task
def readme():
    subprocess.call("less README.md", shell=True)