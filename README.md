# OSIAM Vagrant

A development environment for OSIAM based on [Vagrant](https://www.vagrantup.com/).

## Usage

  1. Clone this repo and [install Vagrant](https://docs.vagrantup.com/v2/installation/index.html)
     and [Virtualbox](https://www.virtualbox.org/)
  2. Copy `example-config.yaml` to `config.yaml` and change it to your needs
  3. Start development VM with `vagrant up` (don't worry about some red error
     messages; as long as Vagrant doesn't complain that it couldn't start the
     VM, everything's alright)
  4. Login in via SSH using `vagrant ssh`

## Installation Details

  * OSIAM current GitHub master

      * [osiam](https://github.com/osiam/osiam)
      * [addon-self-administration](https://github.com/osiam/addon-self-administration)
      * [addon-administration](https://github.com/osiam/addon-administration)

  * OpenJDK 8

  * Flyway 3.2.1

      Configured for installed PostgreSQL database.

  * Tomcat 8

  * PostgreSQL Server 9.4

      Local and host authentication is set to `trust`, so you can connect from
      anywhere without using a password.

  * Docker

      Latest version installed by Vagrant. Required for running integration
      tests from host.
      
  * Greenmail 1.4.1
  
      Simple mail server for the self-administration and administration
      deployed in the tomcat.

  * Maven 3.3.9

  * Git

## Upgrading

To upgrade your environment to a new version, you have to destroy the old and
create a new one. The provisioning doesn't support multiple runs very well. This
issue will be addressed in a future version.

## Becoming root

You can become root with `$ sudo ...` without needing a password. If you ever
really need passwords for some accounts, note that the default Vagrant settings
are still working, i.e. `root:vagrant` and `vagrant:vagrant`.

## Mail server

You do not need to change anything if you like to send e-mails via the
self-administration or administration. You can get the e-mails on pop3 port
10110. This is helpful if you like to register a user and want to activate him
with the generated link which is sent with the e-mail. Here is an example how
to get e-mails with telnet:

Login to the greenmail server via telnet

    $ telnet localhost 10110
    
Use the e-mail address of the user

    USER e-mail address e.g. hello@osiam.org
    PASS e-mail address e.g. hello@osiam.org
    
List all messages

    LIST

Show message with ID 1

    RETR 1
