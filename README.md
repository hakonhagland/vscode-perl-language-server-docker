# Run VS Code from docker container

Run VS Code from Ubuntu docker container, the directory `share` in the current
directory is shared with the container. So you can edit files on the host machine
in this folder.

```
$ make build
$ make run-vscode  # Runs VS Code on the share directory
```

