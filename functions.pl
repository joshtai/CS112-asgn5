%
% Prolog version of not.
%
not( X ) :- X, !, fail.
not( _ ).

constants( List ) :-
    Pi is pi,
    E is e,
    Epsilon is epsilon,
    List = [Pi, E, Epsilon].

%examples functions.pl
haversine_radians( Lat1, Lon1, Lat2, Lon2, Distance ) :-
    Dlon is Lon2 - Lon1,
    Dlat is Lat2 - Lat1,
    A is sin( Dlat / 2 ) ** 2
       + cos( Lat1 ) * cos( Lat2 ) * sin( Dlon / 2 ) ** 2,
    Dist is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
    Distance is Dist * 3961.