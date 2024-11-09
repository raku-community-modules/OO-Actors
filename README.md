[![Actions Status](https://github.com/raku-community-modules/OO-Actors/actions/workflows/linux.yml/badge.svg)](https://github.com/raku-community-modules/OO-Actors/actions) [![Actions Status](https://github.com/raku-community-modules/OO-Actors/actions/workflows/macos.yml/badge.svg)](https://github.com/raku-community-modules/OO-Actors/actions) [![Actions Status](https://github.com/raku-community-modules/OO-Actors/actions/workflows/windows.yml/badge.svg)](https://github.com/raku-community-modules/OO-Actors/actions)

NAME
====

OO::Actors - Implementation of actors using Raku meta-programming

SYNOPSIS
========

```raku
use OO::Actors;

actor AnActor {
    ...
}
```

DESCRIPTION
===========

A minimal actors implementation that makes use of Raku's meta-programming support to abstract away the ordered asynchronous dispatch.

Writing an actor
================

The `OO::Actors` module provides an `actor` declarator. Beyond that, it's very much like writing a normal class.

```raku
use OO::Actors;

enum Severity <Fatal Error Warning Notice>;

actor EventLog {
    has %!events-by-level{Severity};

    method log(Severity $level, Str $message) {
        push %!events-by-level{$level}, $message;
    }

    method latest-entries(Severity $level-limit) {
        my @found;
        for %!events-by-level.kv -> $level, @messages {
            next if $level > $level-limit;
            push @found, @messages;
        }
        return @found;
    }
}
```

Method calls to an actor are asynchronous. That is, making a method call puts the method name and arguments into a queue. Note that this means you'd better not pass things and then mutate them!

Methods are run in the thread pool, one call at a time.

Getting results
===============

Since method calls on an actor are asynchronous, how do you cope with query methods? Each method call on an actor returns a `Promise`. This can be used to get the result;

```raku
say await $log.latest-entries(Error);
```

AUTHOR
======

Jonathan Worthington

Source can be located at: https://github.com/raku-community-modules/OO-Actors . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2014 - 2023 Jonathan Worthington

Copyright 2024 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

