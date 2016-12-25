# The Backup class (only for ec2 ubuntu14.04)
class backup (
        $src_bucket = true,
        $dst_bucket = true,
)
        {

        # Make sure java install
        require java

        # Update Repo on ec2
        exec { "apt-update":
                command => "/usr/bin/apt-get update"
        }

        # git install
        package { 'git':
                ensure => 'installed',
        }

        # Clone s3s3mirror tool
        vcsrepo { "/home/ubuntu/s3s3mirror":
                ensure => present,
                provider => git,
                source => 'https://github.com/cobbzilla/s3s3mirror'
        }

        # s3cfg file for aws keys
        file { "s3cfg":
                path => "/root/.s3cfg",
                content => template("backup/s3cfg.erb"),
                ensure => present
        }

        # Perform backup
        case $backup {
                "Incremental": {
                        exec { "Incremental backup":
                                cwd => "/home/ubuntu/s3s3mirror",
                                path    => ['/usr/bin', '/usr/sbin',],
                                command => "/bin/bash s3s3mirror.sh $src_bucket $dst_bucket >>/home/ubuntu/INCREMENTAL_BACKUP 2>&1",
                        }

                }
                "Exact": {
                        exec { "Exact backup":
                                cwd => "/home/ubuntu/s3s3mirror",
                                path    => ['/usr/bin', '/usr/sbin',],
                                command => "/bin/bash s3s3mirror.sh --delete-removed $src_bucket $dst_bucket >>/home/ubuntu/EXACT_BACKUP 2>&1",
                        }
                }
        }
}
