stage { 'repo': }
stage { 'pre': }
Stage[repo] -> Stage[pre] -> Stage[main]

# Repos
class { 'epel': 
	stage => repo,
}

# Tools
class { 'concat::setup': 
	stage => pre
}
class { 'wget': 
	stage => pre
}

# Edit local /etc/hosts files to resolve some hostnames used on your application.
host { 'localhost.localdomain':
    ensure => 'present',
    target => '/etc/hosts',
    ip => '127.0.0.1',
    host_aliases => ['localhost','memcached','mysql','redis','sphinx'],
}

# Iptables
class iptables {
	package { "iptables":
		ensure => present
	}

	service { "iptables":
		require => Package["iptables"],
		hasstatus => true,
		status => "true",
		hasrestart => false,
	}

	file { "/etc/sysconfig/iptables":
		owner   => "root",
		group   => "root",
		mode    => 600,
		replace => true,
		ensure  => present,
		source  => "/vagrant/files/iptables.txt",
		require => Package["iptables"],
		notify  => Service["iptables"],
	}
}
class { 'iptables': }

# Apache
class { 'apache':
	sendfile		=> 'off',
	purge_configs => false,
}
apache::mod { 'headers': }
apache::vhost { 'centos.local':
    priority        => '1',
    port            => '80',
    serveraliases   => ['www.centos.local',],
	docroot         => '/www',
    docroot_owner	=> 'vagrant',
    docroot_group	=> 'vagrant',
	logroot         => '/logs/httpd',
    options         => 'FollowSymLinks MultiViews',
}

apache::vhost { 'symfonydemo.local':
    priority        => '1',
    port            => '80',
    serveraliases   => ['www.symfonydemo.local',],
  docroot         => '/mnt/projects/symfony_demo/web',
    docroot_owner => 'vagrant',
    docroot_group => 'vagrant',
  logroot         => '/logs/httpd',
    options         => 'FollowSymLinks MultiViews',
    override      => "All"
}

apache::vhost { 'advice.local':
    priority        => '1',
    port            => '443',
    serveraliases   => ['www.advice.dev',],
  docroot         => '/mnt/projects/vice/advice/public',
    docroot_owner => 'vagrant',
    docroot_group => 'vagrant',
  logroot         => '/logs/httpd',
    options         => 'FollowSymLinks MultiViews',
    override      => "All"
}

# PHP
class { 'yum':
  extrarepo => [ 'webtatic'],
}

package { 'php56w' :
  ensure => 'present',
  require => Yumrepo['webtatic'],
}

package { 'php56w-mysql' :
  ensure => 'present',
  require => [
              Package['php56w'],
              Yumrepo['webtatic'],
              ],
}

package { 'php56w-pdo' :
  ensure => 'present',
  require => [
              Package['php56w'],
              Yumrepo['webtatic'],
            ]
}

package { 'php56w-mbstring' :
  ensure => 'present',
  require => [
              Package['php56w'],
              Yumrepo['webtatic'],
            ]
}

package { 'php56w-mcrypt' :
  ensure => 'present',
  require => [
              Package['php56w'],
              Yumrepo['webtatic'],
            ]
}

package { 'nodejs' :
  ensure => 'present',
}

package { 'npm' :
  ensure => 'present',
}

# MySQL
class { '::mysql::server':
  root_password    => '1234',
  override_options => { 'mysqld' => { 'max_connections' => '1024' } }
}


# MongoDb
class {'::mongodb::server': }

# Git
package { "git":
    ensure => "installed",
}
