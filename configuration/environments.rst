.. index::
    single: Environments

How to Master and Create new Environments
=========================================

Every application is the combination of code and a set of configuration that
dictates how that code should function. The configuration may define the database
being used, if something should be cached or how verbose logging should be.

In Symfony, the idea of "environments" is the idea that the same codebase can be
run using multiple different configurations. For example, the ``dev`` environment
should use configuration that makes development easy and friendly, while the
``prod`` environment should use a set of configuration optimized for speed.

.. index::
   single: Environments; Configuration files

Different Environments, different Configuration Files
-----------------------------------------------------

A typical Symfony application begins with three environments: ``dev``,
``prod``, and ``test``. As mentioned, each environment simply represents
a way to execute the same codebase with different configuration. Each
environment can load its own individual configuration files.

When Symfony is loaded, it uses the given environment to
determine which configuration files to load. This accomplishes the goal of
multiple environments in an elegant, powerful and transparent way.

Of course, in reality, each environment differs only somewhat from others.
Generally, all environments will share a large base of common configuration.

The `config` directory looks like this:

.. code-block:: text

    config/
    ├─ packages/
    │  ├─ package1.yaml
    │  ├─ package2.yaml
    │  ├─ ...
    │  ├─ dev/
    │  │  └─ package1.yaml
    │  │  └─ package2.yaml
    │  │  └─ ... (other package configurations specific to the dev environment)
    │  ├─ test/
    │  │  └─ ...
    ├─ routes/
    │  ├─ dev/
    │  │  └─ package1.yaml
    │  │  └─ package2.yaml
    │  │  └─ ...
    │  └─ ...
    ├─ routes.yaml
    │  ...

The ``packages`` subdirectory contains common configuration for each installed package.
It also contains optional specific configuration for each environment, in
dedicated folders corresponding to each of these environments. For example,
if the web profiler package has been installed, the following configuration
is added to enable it only for the dev environment:

.. code-block:: yaml

    # config/packages/dev/web_profiler.yaml
    web_profiler:
        toolbar: true

In the same way, routes that are common to all environments are defined in the
`config/routes.yaml` file while additional routes can be defined per
environment in the `config/routes/` folder. This is used for example by the web
profiler routes that are automatically configured to only be made available
for the ``dev`` environment:

.. code-block:: yaml

    # config/routes/dev/web_profiler.yaml
    web_profiler_wdt:
        resource: '@WebProfilerBundle/Resources/config/routing/wdt.xml'
        prefix: /_wdt

    web_profiler_profiler:
        resource: '@WebProfilerBundle/Resources/config/routing/profiler.xml'
        prefix: /_profiler

.. index::
   single: Environments; Executing different environments

Executing an Application in different Environments
--------------------------------------------------

The environment in which the application is executed is determined by the ``APP_ENV``
environment variable.

This environment variable may be defined in the ``.env`` file at the root of
your application:

.. code-block:: text

    # /.env
    APP_ENV=dev
    APP_DEBUG=1

A Symfony application can be executed in any environment by using this
``APP_ENV`` parameter.

.. index::
   single: Configuration; Debug mode

.. sidebar:: *Debug* Mode

    Important, but unrelated to the topic of *environments* is the ``APP_DEBUG``
    environment variable. This specifies if the application should run in "debug
    mode". Regardless of the environment, a Symfony application can be run with debug
    mode set to ``true`` or ``false``. This affects many things in the application,
    such as displaying stacktraces on error pages or if cache files are
    dynamically rebuilt on each request. Though not a requirement, debug mode
    is generally set to ``true`` for the ``dev`` and ``test`` environments and
    ``false`` for the ``prod`` environment.

    Internally, the value of the debug mode becomes the ``kernel.debug``
    parameter used inside the :doc:`service container </service_container>`.
    If you look inside the application configuration file, you'll see the
    parameter used, for example, to turn logging on or off when using the
    Doctrine DBAL:

    .. configuration-block::

        .. code-block:: yaml

            doctrine:
               dbal:
                   logging: '%kernel.debug%'
                   # ...

        .. code-block:: xml

            <?xml version="1.0" encoding="UTF-8" ?>
            <container xmlns="http://symfony.com/schema/dic/services"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:doctrine="http://symfony.com/schema/dic/doctrine"
                xsi:schemaLocation="http://symfony.com/schema/dic/services
                    http://symfony.com/schema/dic/services/services-1.0.xsd
                    http://symfony.com/schema/dic/doctrine
                    http://symfony.com/schema/dic/doctrine/doctrine-1.0.xsd">

                <doctrine:dbal logging="%kernel.debug%" />

            </container>

        .. code-block:: php

            $container->loadFromExtension('doctrine', array(
                'dbal' => array(
                    'logging'  => '%kernel.debug%',
                    // ...
                ),
                // ...
            ));

Selecting the Environment for Console Commands
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

By default, Symfony commands are executed using the same environment as the web, using
the ``APP_ENV`` and ``APP_DEBUG`` environment variables.

behavior:

.. code-block:: terminal

    # 'dev' environment and debug enabled
    $ php bin/console command_name --env=dev

    # 'prod' environment
    $ php bin/console command_name --env=prod

    # 'test' environment and debug disabled
    $ php bin/console command_name --env=test --no-debug

In addition to the ``--env`` and ``--no-debug`` options, the behavior of Symfony
commands can also be controlled with environment variables. The Symfony console
application checks the existence and value of these environment variables before
executing any command:

``APP_ENV``
    Sets the execution environment of the command to the value of this variable
    (``dev``, ``prod``, ``test``, etc.);
``APP_DEBUG``
    If ``0``, debug mode is disabled. Otherwise, debug mode is enabled.

The default value of these environment variables can be set in the ``.env`` file
at the root of the project, or can be set at run-time:

.. code-block:: terminal

    # 'dev' environment and debug enabled
    $ APP_ENV=dev APP_DEBUG=1 php bin/console command_name

    # 'prod' environment
    $ APP_ENV=prod APP_DEBUG=0 php bin/console command_name

    # 'test' environment and debug disabled
    $ APP_ENV=test APP_DEBUG=0 php bin/console command_name

These environment variables are very useful for production servers because they
allow you to ensure that commands always run in the ``prod`` environment without
having to add any command option.

.. index::
   single: Environments; Creating a new environment

Creating a new Environment
--------------------------

When the Symfony app is run in an environment that didn't exist before, the new
environment is automatically created.


Suppose, for example, that before deployment, you need to benchmark your
application. One way to benchmark the application is to use near-production
settings, but with Symfony's ``web_profiler`` enabled. This allows Symfony
to record information about your application while benchmarking.

The best way to accomplish this is via a new environment called, for example,
``benchmark``. Start by creating a new configuration file:

.. configuration-block::

    .. code-block:: yaml

        # config/packages/benchmark/web_profiler.yml
        framework:
            profiler: { only_exceptions: false }

    .. code-block:: xml

        <!-- config/packages/benchmark/web_profiler.xml -->
        <?xml version="1.0" encoding="UTF-8" ?>
        <container xmlns="http://symfony.com/schema/dic/services"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:framework="http://symfony.com/schema/dic/symfony"
            xsi:schemaLocation="http://symfony.com/schema/dic/services
                http://symfony.com/schema/dic/services/services-1.0.xsd
                http://symfony.com/schema/dic/symfony
                http://symfony.com/schema/dic/symfony/symfony-1.0.xsd">

            <framework:config>
                <framework:profiler only-exceptions="false" />
            </framework:config>

        </container>

    .. code-block:: php

        // config/packages/benchmark/web_profiler.php
        $container->loadFromExtension('framework', array(
            'profiler' => array('only_exceptions' => false),
        ));


And with this simple addition, the application now supports a new environment
called ``benchmark``.

This new configuration file overrides the default one defined at the root of
``config/packages`` directory. This guarantees that the new environment is
identical to the default one, except for any changes explicitly made here.

If you want to access the ``benchmark`` environment, change the ``.env`` file
at the root of the project:

.. code-block:: diff

    # ...
    - APP_ENV=dev
    - APP_DEBUG=1
    + APP_ENV=benchmark
    + APP_DEBUG=0

.. index::
   single: Environments; Cache directory

Environments and the Cache Directory
------------------------------------

Symfony takes advantage of caching in many ways: the application configuration,
routing configuration, Twig templates and more are cached to PHP objects
stored in files on the filesystem.

By default, these cached files are largely stored in the ``var/cache`` directory.
However, each environment caches its own set of files:

.. code-block:: text

    your-project/
    ├─ var/
    │  ├─ cache/
    │  │  ├─ dev/   # cache directory for the *dev* environment
    │  │  └─ prod/  # cache directory for the *prod* environment
    │  ├─ ...

Sometimes, when debugging, it may be helpful to inspect a cached file to
understand how something is working. When doing so, remember to look in
the directory of the environment you're using (most commonly ``dev`` while
developing and debugging). While it can vary, the ``var/cache/dev`` directory
includes the following:

``srcDevDebugProjectContainer.php``
    The cached "service container" that represents the cached application
    configuration.

``srcProdProjectContainerUrlMatcher.php``
    The PHP class used for route matching - look here to see the compiled regular
    expression logic used to match incoming URLs to different routes.

``twig/``
    This directory contains all the cached Twig templates.

.. note::

    You can easily change the directory location and name. For more information
    read the article :doc:`/configuration/override_dir_structure`.

Going further
-------------

Read the article on :doc:`/configuration/external_parameters`.
