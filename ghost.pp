node default {
  Yumrepo <| |> -> Package <| |>
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

  file { '/opt/ghost':
    ensure => 'directory',
	}

	user { 'ghost':
	  ensure  => 'present',
	  comment => 'Ghost Blog',
	  home    => '/opt/ghost',
	  shell   => '/bin/bash'
	}

  include epel
  include nodejs

  nodejs::npm { 'ghost':
    target  => '/opt/ghost',
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
}
