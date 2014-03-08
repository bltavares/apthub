# Apthub

This is an APT repo backed by Github's Release API.

This is not ready yet. The checksum is not being generated yet, which is required by apt.
When it is ready the idea will be that you can host it and it will allow you Releases to provide a simple repo.

It looks for .deb uploaded on Releases and build a a list of packages.

### Example for sources.list

```
deb http://<host-name>/<github user name>  <repon name>/
```

```
deb http://apthub.herokuapp.com/bltavares  baseline/
```
