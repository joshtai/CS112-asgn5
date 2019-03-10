% https://learnxinyminutes.com/docs/prolog/

% Prolog version of not.
not( X ) :- X, !, fail.
not( _ ).

% from functions.pl
haversine_radians( Lat1, Lon1, Lat2, Lon2, Distance ) :-
    Dlon is Lon2 - Lon1,
    Dlat is Lat2 - Lat1,
    A is sin( Dlat / 2 ) ** 2
       + cos( Lat1 ) * cos( Lat2 ) * sin( Dlon / 2 ) ** 2,
    Dist is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
    Distance is Dist * 3961.

% -------------------------------

% deg to radians -> deg * pi/180
degmin_to_rads(degmin(Degrees,Minutes), Radians) :-
    DecimalDegree is Degrees + Minutes / 60,
    Radians is DecimalDegree * pi / 180.

compute_distance(Airport1, Airport2, Distance) :-
    airport(Airport1, _, Lat1, Long1),
    airport(Airport2, _, Lat2, Long2),
    % converts all degmins into rads (part a of the prompt)
    degmin_to_rads(Lat1, Lat1rad),
    degmin_to_rads(Long1, Long1rad),
    degmin_to_rads(Lat2, Lat2rad),
    degmin_to_rads(Long2, Long2rad),
    haversine_radians(Lat1rad,Long1rad,Lat2rad,Long2rad, Distance).

compute_flight_time(Airport1, Airport2, FlightTime) :-
    compute_distance(Airport1, Airport2, Distance),
    FlightTime is Distance / 500. % gets flight time by dividing distance to 500 mph

compute_arrival_time(flight(Airport1, Airport2, time(Hours, Minute)), ArrivalTime) :-
    compute_flight_time(Airport1, Airport2, FlightTime),
    DepartTime is Hours + Minute / 60, % converts DepartTime into hours
    ArrivalTime is FlightTime + DepartTime.

% --------------------------------
