# vagrant-otrs

Vagrant Box with OTRS deployed on ubuntu/trusty64 for development purposes.

1. Run "vagrant up"
2. Go to the OTRS installer at <http://localhost:3002/otrs/installer.pl>
3. Configure an "Existing Database" with MySQL, (default credentials: User: `otrs` Password: `vagrant` Database: `otrs`)
4. (Optional) Configure Mail settings
5. Remember OTRS-root user password for first login
6. Login at `http://localhost:3002/otrs/index.pl`
7. Enjoy.

## OTRS install directory

```
/opt/otrs
```

## OTRS Version

Default version is 5.0.16 You can pick your desired OTRS version by setting the VERSION variable at the start of `init.sh`
