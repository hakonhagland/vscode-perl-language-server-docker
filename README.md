# Run VS Code with Perl Language server from docker container

Run VS Code with [Perl Language server extension](https://marketplace.visualstudio.com/items?itemName=richterger.perl) preinstalled from a docker container.
The directory `share` in the current directory is shared with the container. So you can edit files on the host machine in this folder.

```
$ make build
$ make run-vscode  # Runs VS Code with Perl Language server with the share directory
```

