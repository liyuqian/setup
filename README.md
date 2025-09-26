Scripts to set up packages, apps, configs, and system environments.

Unlike homebrew, we don't offer a sandbox, and will use as many OS-specific
tools and commands as possible. The code can employ complex logic to determine
which ones to use. The philosophy is that anything that can be done in CLIs can
be achieved by this tool; anything that can be specified by humans can be
automated by this tool.

Unlike ansible, we don't use DSL or yaml config files. Instead, all logic and
configurations are written in code to provide the max flexibility. It allows us
to use IDEs, plugins, and exisiting toolchains to debug and write the code. It's
the developer's responsibility to make the code readable and clean. We don't
force it by restricting the language into DSL or yaml.
