# Requirements

* [Install Elm architecture](http://elm-lang.org/install)

# Running the site

First make sure you install all packages by running `npm install`

* `gulp`: Runs the default task to build and serve the local site
* `gulp deploy`: deploys to GH pages
* `gulp test`: Runs the tests

# Source structure

    .
    ├── elm-package.json
    ├── gulpfile.js
    ├── package.json
    ├── src
    │   ├── elm
    │   │   ├── Messages.elm
    │   │   ├── Main.elm
    │   │   ├── Models.elm
    │   │   └── Views.elm
    │   ├── assets
    │   │   ├── images
    │   │   │   └── logo.png
    │   │   └── scss
    │   │       └── style.scss
    │   └── index.html
    └── test
