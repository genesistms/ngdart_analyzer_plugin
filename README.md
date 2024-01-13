This project is attempt to revive archived angular analyzer plugin. While i am
still looking at the old angular analyzer and how they did things, with changes
in dart sdk and dart analyzer package i decided to go make it from scratch.

My plan is to gradually update the plugin with new features until we get to the
point where old angular analyzer was.

Goal is to include this package inside AngularDart.

## Install

```yaml
dependencies:
  ngdart_analyzer_plugin:
    git: https://github.com/genesistms/ngdart_analyzer_plugin
```

And then add to your
[analysis_options.yaml file](https://www.dartlang.org/guides/language/analysis-options#the-analysis-options-file):

```yaml
analyzer:
  plugins:
    - ngdart_analyzer_plugin
```

## Features

For what's currently supported, see `CURRENT_SUPPORT.md`.
