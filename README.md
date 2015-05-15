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

  * OSIAM 2.1

      * auth-server 2.0
      * resource-server 2.0
      * addon-self-administration 1.4
      * addon-administration 1.4

  * OpenJDK 7

      Headless JRE installed

  * Flyway 3.2.1

      Configured for installed PostgreSQL database

  * Tomcat 7
  * PostgreSQL Server 9.3

      Local and host authentication is set to `trust`, so you can connect from
      anywhere without using a password.

  * Docker

      Latest version installed by Vagrant. Required by integration tests.

  * Maven 3.0.5

## Upgrading

To upgrade your environment to a new version, you have to destroy the old and
create a new one. The provisioning doesn't support multiple runs very well. This
issue will be addressed in a future version.

## Becoming root

You can become root with `$ sudo ...` without needing a password. If you ever
really need passwords for some accounts, note that the default Vagrant settings
are still working, i.e. `root:vagrant` and `vagrant:vagrant`.
