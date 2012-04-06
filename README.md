# Growlfire

Growlfire provides growl notifications via Campfire's steaming api.

## Installation

Growlfire can be installed via RubyGems:

    $ gem install growlfire

## Usage

Growlfire needs a Campfire api token, your campfire subdomain, and the name of the room you wish to join.
The api token can be set via an env variable CAMPFIRE_TOKEN or as a single line in ~/.campfire

To start growlfire, simply use the command:

    $ growlfire mydomain myroom

If you run into problems, you can turn on debug logging to STDOUT with GROWLFIRE_DEBUG=true env var.