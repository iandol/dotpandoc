# preludeGitVersion

Bump the document version and adds/replaces the version: major.minor-commits to the (piped) document.

## GIT and versioning:
* The major demand that we have is to assure that our work is being saved in git, in order to prevent loosing our work when crashes occur. The minor demand that we have is to support versioning of saved work.
* Similar to sw-testing, unsuccessful pdf generation by pandocomatic is independent from versioning. We only want to commit a verified piece of work, i.e., all tests passed. Then, and only then, we want to have a bumped version denoted in the document. 
* We want to have each and every committed progress versioned without the need to actively take action for that. This is easy since git will bump the release (the number of commits, placed after the first dash) automatically. 
* We want to be able to (actively) indicate that the bumped version is a major, minor or patch.

## THE PROBLEM
Generating a document with pandocomatic into your choice of output, e.g., pdf, precedes the process of committing the latest generated document to git. Only when committing the document with git, the git version will be bumped. However, we need that bumped git version while generating the document, since that is the latest moment we can include that new version into our document. A classical catch-22. 

## OBJECTIVE
To include the to-be-bumped version into the document generation process, prelude the git version that will result from eventually committing the new document.

## METHOD 
* Step 1: Assume the document-to-generate is commit-worthy, i.e., exactly as we want it. We thus anticipate a successful git commit after document generation. This implies to simulate a version bump, to be included in the document. The git version itself remains unaltered until we actually perform a 'git commit'.
* Step 2: As we start the pandocomatic document generation, we don't know whether the document will show as commit-worthy. Two cases apply: 
    * First, our assumption fails and the document is erroneous or otherwise not to our liking: no matter what we have preluded as version-to-be, no harm to the actual git versioning is done. Consequently, we can repeat the preludation process time after time as long as we make sure that we don't retain the version-to-be but start fresh with the latest git version as seed to the preluding; 
    * Second, our assumption holds and we've generated a valid, commit-able document. The preluded version has been included in the document itself, however, the document is yet to be committed. Consequently, after the 'git commit' the actual git version has been bumped, and is in correspondence with the preluded version that has been included in the document. 
    
## ADVANCED METHOD
Assume we not only want to apply versioning on the level of patches, viz the number of commits, but also on the other two levels. In order to align/match the preluded version as included in the document with the actual git version, it is the responsibility of the user to foretell the type of versioning of the commit already during document processing, and include this as proper <major|minor|commit> parameter to the preludeGitVersion process. In case of a major or minor version bump, we need to tell git that we don't want a patch-level bump but a major or minor instead. Besides, we need to instruct git with the tag command to create a new tag at the correct level. 

## USAGE

### Prerequisites

The folder that contains your `project.scriv` must be under git control and, hence, contain the `.git` folder.

### Testing

From the command line, one can test the proper operation of the command: input your markdown document into the command by pipe  (```cat document.md```) and it will output the result back to the command line. The result is the very same markdown document, but modified to include a

    version: x.y-z 

line in its YAML-block.

```
usage: preludeGitVersion.py [-h] [-p PATH] [-i {commit,minor,major}]

  -h, --help                show this help message and exit
  -p PATH, --path PATH      the path name to the local directory that 
                            includes the document git repo; 
                            default = "./"
  -i {commit,minor,major}, --increment {commit,minor,major}
                            indicates which version field is to be
                            bumped (major.minor-commits), preluding 
                            the actual commit; 
                            default = "commit"
```

### Integrated into the pandocomatic process line
In your ```document.md```, include a yaml block on top, as follows:
```
pandocomatic_:
  preprocessors: ['preprocessors/preludeGitVersion.py’]  
  ... 
...
version-incr: commit # major, minor or commit
...
```
This specifies to use the ```preludeGitVersion``` preprocessor, and indicates to prelude on the version-level of your choice (major.minor-commit). The result of the preprocessor will be piped into pandocomatic for processing.

Logging can be found in ./preludeGitVersion.log

## RULES
* Command line arguments take precedence over YAML-block arguments (this is mostly for testing purposes)