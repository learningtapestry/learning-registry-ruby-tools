# lr-bridge
Tool for bridging Learning Registry and other systems.

## Installation instructions
* We *highly* recommend you use Ruby 1.9.3 or greater. It *should* work in 1.8.7 but we don't recommend this and don't guarantee it in the future.
  * https://www.ruby-lang.org/en/documentation/installation/
* You must have Ruby gems installed also (usually this comes with Ruby unless you build from source).
* Install "bundler": `sudo gem install bundler` or Windows `gem install bundler`
* Pull down and unzip this repository to a local folder.
  * You can download a zip of this repo here: https://github.com/learningtapestry/lr-bridge/archive/master.zip
* From that local folder, run: `bundle install`
  * Provide sudo password if requested
* Run lr-bridge to retrieve all LR records as:
```
ruby lr-bridge.rb --node http://sandbox.learningregistry.org --folder /tmp/lr-test-download
```
Or for Windows:
```
ruby lr-bridge.rb --node http://sandbox.learningregistry.org --folder c:/temp/lr-test-folder
```
  * Waaaaait. It takes a while to download all the records. You should see status updates as it runs.
  * If it fails, you have to restart from the beginning unfortunately and **use a new download folder**!

* You should now have all the records from LR in the folder you specified
  * The folder will have sub-folders in a semi-tree-balanced manner (we create the minimum number of sub-folders possible for the given number of files downloaded)

## Testing
To run tests on the current codebase go to the ./test folder and run:
`ruby learningregistry_test.rb`
