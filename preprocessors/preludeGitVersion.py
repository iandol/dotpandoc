#!/usr/local/bin/python3
import logging
import sys
import datetime

import git.exc
from git import Repo


def parseInput():
    import argparse
    default = {}
    default['-p'] = './'
    default['-i'] = ''

    # Get all arguments and ACK the command
    parser = argparse.ArgumentParser(
        description='''Bump the document version and adds/replaces the version: mjr.mnr-commits to the (piped) document.''',
        epilog='''OBJECTIVE: When the documents are managed by git, git commits are executed *after* document \n
          generation in order to prevent erroneous docs to end up in git. Therefore, the current git version the \n
          document is tagged with, denotes the version of the previous document. To end up with correct versioning, \n
          the version to be inserted in the current document must prelude the git version. \n
          METHOD: We assume the document-to-generate is commit-worthy, and we thus anticipate a successful git \n
          commit after document generation. This implies to simulate a version bump, to be included in the document. \n
          Because we simulate the git bump, the git version itself remains unaltered. Two cases apply: \n
          First, whenever our assumption fails and the document is erroneous, no harm to the actual git versioning \n
          is done and we can repeat the process time after time until the document is correct; \n
          Second, for a valid, commit-able document the version bump is now included in the document itself, however, \n
          the document is yet to be committed (resulting in an actual git version bump). In order to align/match the \n
          documented version with the actual git version, it is the responsibility of the user to foretell the type \n
          of versioning of the commit during document processing, and include this as proper <major|minor|commit> \n
          parameter to the preludeGitVersion process.\n
          RULES: command line arguments take precedence over YAML-block arguments
        '''
    )
    parser.add_argument('-p', '--path',
                        help='''the path name to the local directory that 
                             includes the document git repo; default = "{}"'''.format(default['-p']),
                        default=default['-p']
                        )
    parser.add_argument('-i', '--increment',
                        choices=['commit', 'minor', 'major'],
                        help='indicates which version field is bumped (major.minor-commits), preluding the actual commit; default = "commit"'
                        )

    args = parser.parse_args()
    return args.path, args.increment


def getGitVersion(dir="./"):
    try:
        repo = Repo(dir, search_parent_directories=False)
    except git.exc.InvalidGitRepositoryError as err:
        print(
            "Error: git repository {} not found - Create an empty Git repository or reinitialize an existing one with 'git init' ({})".format(
                dir + '.git/', sys.argv[0]), file=sys.stderr)
        exit(1)

    if repo.bare:
        version, commits, hash = "v0.0", "0", ""
        repo.create_tag(version, message="initial tag")
        logging.info("current git is bare git, hence version tag created: {}".format(version))
    else:
        describe = repo.git.describe("--tags")
        logging.info("current git version: {}".format(describe))
        if "-" in describe:
            version, commits, hash = describe.split('-')
            hash = hash[1:]
        else:
            version = describe
            commits = "0"
            hash = ""

    return version + '-' + commits, hash


def incrementGitVersion(git_path="", incr_field="", yaml_version=""):
    assert (git_path and incr_field), "Expected path/to/.git and the field to increment"
    # Get current git status information
    git_version, git_hash = getGitVersion(git_path)

    # Assume a YAML version trumps a git version
    if yaml_version and not yaml_version.isspace():
        logging.info("Using version from yaml-block ({})".format(yaml_version))
        return incrementVersion(yaml_version, incr_field)
    else:
        logging.info("Using version found in git ({})".format(git_version))
        return incrementVersion(git_version, incr_field)


def incrementVersion(version, incr="commit"):
    import re
    reVersionFormat = re.compile(r'v(?P<mjr>\d+)\.(?P<mnr>\d+)(-(?P<cmts>\d+))?')
    reresult = reVersionFormat.match(version)
    assert reresult, "Error: version <major.minor[-commits]> expected, got {}".format(version)
    assert incr in ["major", "minor", "commit"], "Error: increment 'major', 'minor', or 'commit' expected, got {}".format(incr)
    logging.info("Incrementing version {} on level '{}'".format(version,incr))
    major = int(reresult.group("mjr"))
    minor = int(reresult.group("mnr"))
    commits = int(reresult.group("cmts")) if reresult.group("cmts") else 0

    if incr == "commit":
        commits += 1
    elif incr == "minor":
        commits = 0
        minor += 1
    elif incr == "major":
        commits = 0
        minor = 0
        major += 1
    logging.info("Continuing with version {}".format("v" + str(major) + "." + str(minor) + '-' + str(commits)))
    
    return "v" + str(major) + "." + str(minor) + '-' + str(commits)


def extractYAMLBlock(text):
    import re
    p0 = re.compile(r'^(---)[ ]*$(\n|\r)(?P<yaml>(^.*$(\n|\r))*?)(---|\.\.\.)[\s]*$', re.MULTILINE)
    yaml = p0.match(text)
    return yaml[p0.groupindex['yaml']]


def extractVersionData(text):
    import re
    regexIncr = r'^version-incr[ ]*:\s*(?P<incr>major|minor|commit)\s*(#.*)?$'
    regexVersion = r'^version[ ]*:\s*(?P<vers>[\S*]*?)\s*(#.*)?$'
    incr = re.search(regexIncr, text, re.MULTILINE)
    vers = re.search(regexVersion, text, re.MULTILINE)
    return vers.group('vers') if vers else None, incr.group('incr') if incr else None


def yamlSub(text=None, label=None, newvalue=None):
    import re
    assert label in ("version", "version-incr"), "YAML parameter 'version' or 'version-incr' expected, got {}".format(
        label)
    assert text, "YAML substitution for parameter '{}' requires a text in-place to substitute in".format(label)
    assert newvalue, "YAML parameter '{}' requires new value, got {}".format(label, newvalue)
    pattern = re.compile(r'^' + label + r'\s*:[\s*\S*]*?\s*(#.*)?$', re.MULTILINE)
    return pattern.sub("{}: {}".format(label, newvalue), text)


def modifyDocument(git_path=None, arg_incr_field=None, file=None):
    import re

    # Extract YAML intended versioning information
    yaml_start = re.compile(r'^(---)[ ]*$', re.MULTILINE)
    # Read the text, either from file or from pipe
    text = ""
    if file:
        with open(file) as f:
            text = ''.join(f.readlines())
    else:
        text = ''.join(sys.stdin.readlines())
    assert text, "Empty input. Provide markdown text, either in file or by pipe."

    yamlVersion, yamlIncr = extractVersionData(extractYAMLBlock(text))
    if yamlIncr:
        logging.info("== Found increment level in YAML-block: {}".format(yamlIncr))

    # Command line arguments take precedence over yaml values
    incr_field = (arg_incr_field if arg_incr_field else yamlIncr)
    logging.info("== Set increment level: {}".format(incr_field))

    newtext = yamlSub(text, "version-incr", incr_field) if incr_field else text
    if yamlVersion:
        logging.info("== Found version in YAML-block: {}".format(yamlVersion))
        newtext = yamlSub(newtext, "version", incrementGitVersion(git_path, incr_field, yamlVersion))
    else:
        newtext = yaml_start.sub("---\nversion: {}".format(incrementGitVersion(git_path, incr_field, "")), newtext, count=1)
    return newtext


if __name__ == '__main__':
    import os
    from pathlib import Path

    cwd = os.getcwd()
    logfile = cwd + '/' + Path(sys.argv[0]).stem + '.log'
    logging.basicConfig(filename=logfile,
                        encoding='utf-8',
                        level=logging.DEBUG,
                        filemode='w')
    logging.info("======= running {} =========".format(sys.argv[0]))
    logging.info("== {}".format(datetime.datetime.now().strftime("%c")))

    # init: read command line arguments
    git_path, incr_field = parseInput()
    logging.info("== Path/to/.git: {}".format(git_path))
    logging.info("== Increment level at command line: {}".format(incr_field if incr_field else 'None'))

    print(modifyDocument(git_path, incr_field))
