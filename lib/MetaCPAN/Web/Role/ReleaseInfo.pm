package MetaCPAN::Web::Role::ReleaseInfo;

use Moose::Role;

# TODO: are there other controllers that do (or should) include this?

# TODO: should some of this be in a separate (instantiable) model
# so you don't have to keep passing $data?
# Role/API/Aggregator?, Model/APIAggregator/ReleaseInfo?

# TODO: should the api_requests be in the base controller role,
# and then the default extras be defined in other roles?

# pass in any api request condvars and combine them with these defaults
sub api_requests {
    my ( $self, $c, $reqs, $data ) = @_;

    return {
        author     => $c->model('API::Author')->get( $data->{author} ),

        rating     => $c->model('API::Rating')->get( $data->{distribution} ),

        versions   => $c->model('API::Release')->versions( $data->{distribution} ),

        %$reqs,
    };
}

# organize the api results into simple variables for the template
sub stash_api_results {
    my ( $self, $c, $reqs, $data ) = @_;

    $c->stash({
        author     => $reqs->{author},
        #release    => $release->{hits}->{hits}->[0]->{_source},
        rating     => $reqs->{rating}->{ratings}->{ $data->{distribution} },
        versions   =>
            [ map { $_->{fields} } @{ $reqs->{versions}->{hits}->{hits} } ],
    });
}

# call recv() on all values in the provided hashref
sub recv_all {
    my ( $self, $condvars ) = @_;
    return { map { $_ => $condvars->{$_}->recv } keys %$condvars };
};

1;
