role Actor {
    has Lock::Async $!orderer .= new;

    method !post($method, $capture) {
        $!orderer.lock.then({
            LEAVE $!orderer.unlock;
            $method(self, |$capture)
        });
    }
}

class MetamodelX::ActorHOW is Metamodel::ClassHOW {
    my %bypass = :new, :bless, :BUILDALL, :BUILD, 'dispatch:<!>' => True, :is-generic;

    method find_method(Mu \obj, $name, | --> Mu) is raw {
        my $method = callsame;
        my $post = self.find_private_method(obj, 'post');
        %bypass{$name} || !$method
            ?? $method
            !!  -> \obj, |capture { $post(obj, $method, capture); }
    }

    method compose(Mu \type) {
        self.add_role(type, Actor);
        nextsame
    }

    method publish_method_cache(|) { }
}

my package EXPORTHOW {
    package DECLARE {
        constant actor = MetamodelX::ActorHOW;
    }
}

=begin pod

=head1 NAME

OO::Actors - Implementation of actors using Raku meta-programming

=head1 SYNOPSIS

=begin code :lang<raku>

use OO::Actors;

actor AnActor {
    ...
}

=end code

=head1 DESCRIPTION

A minimal actors implementation that makes use of Raku's meta-programming
support to abstract away the ordered asynchronous dispatch.

=head1 Writing an actor

The C<OO::Actors> module provides an C<actor> declarator. Beyond
that, it's very much like writing a normal class.

=begin code :lang<raku>

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

=end code

Method calls to an actor are asynchronous. That is, making a method
call puts the method name and arguments into a queue. Note that this
means you'd better not pass things and then mutate them!

Methods are run in the thread pool, one call at a time.

=head1 Getting results

Since method calls on an actor are asynchronous, how do you cope with
query methods? Each method call on an actor returns a C<Promise>.
This can be used to get the result;

=begin code :lang<raku>

say await $log.latest-entries(Error);

=end code

=head1 AUTHOR

Jonathan Worthington

Source can be located at: https://github.com/raku-community-modules/OO-Actors . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2014 - 2023 Jonathan Worthington

Copyright 2024 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
