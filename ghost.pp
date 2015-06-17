node default {
  Yumrepo <| |> -> Package <| |>
  include epel
  include nodejs
  # Death to the allow_virtual_packages warning
  if versioncmp($::puppetversion,'3.6.1') >= 0 {
    $allow_virtual_packages = hiera('allow_virtual_packages',false)
    Package {
      allow_virtual => $allow_virtual_packages,
    }
  }

  class { 'timezone':
    timezone => 'UTC',
  }

	user { 'ghost':
	  ensure  => 'present',
	  comment => 'Ghost Blog',
	  home    => '/opt/ghost',
	  shell   => '/bin/bash'
	}

  file { '/opt/ghost':
    ensure  => 'directory',
    owner   => 'ghost',
    require => User['ghost']
	}

  nodejs::npm { 'ghost':
    target  => '/opt/ghost',
    user    => 'ghost'
  }

  file { '/opt/ghost/node_modules':
    ensure    => 'directory',
    recurse   => true,
    owner     => 'ghost',
    require   => Nodejs::Npm['ghost']
	}

  class { 'supervisord':
    install_pip => true,
  }

	supervisord::program { 'ghost':
	  command     => '/usr/bin/node /opt/ghost/node_modules/ghost/index.js',
	  autostart   => true,
	  autorestart => true,
	  user        => 'ghost',
	  priority    => '100',
	  environment => {
	    'NODE_ENV'   => 'production'
	 	}
	}

	class { 'apache':
    default_vhost => false
	}

	apache::vhost { 'ghost.sandbox.internal':
    port          => '80',
    docroot       => '/opt/ghost/node_modules/ghost',
    proxy_dest    => 'http://localhost:2368/'
  }
}
