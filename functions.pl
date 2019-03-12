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


% from graphpaths.pl
writeallpaths( Node, Node ) :-
   write( Node ), write( ' this is wrongxs ' ), write( Node ), nl.
writeallpaths( Node, Next ) :-
   listpath( Node, Next, [Node], List, 0 ),
   write( Node ), write( ' to ' ), write( Next ), write( ' is ' ),
   writepath( List ),
   fail.

writepath( [] ) :-
   nl.
writepath( [Head|Tail] ) :-
   write( ' ' ), write( Head ), writepath( Tail ).

listpath( Node, End, Outlist ) :-
  write('outlist: '), write(Outlist),nl,
  listpath( Node, End, [Node], Outlist ).

listpath( Node, Node, _, [Node], CurrTime ).
listpath( Node, End, Tried, [Node|List] , CurrTime) :-
  CurrT is CurrTime + 1,
  %write('Node: '), write(Node),write(' End: '), write(End),write(' Tried: '), write(Tried),nl,
  flight( Node, Next, DepartT),
  time_to_num(DepartT, DepartTimeNum),
  write(' depart: '), write(DepartTimeNum),nl,
  write(' currtime: '), write(CurrTime),nl,

  compute_arrival_time(flight(Node, Next, DepartT), ArrivalTime),
  %write(' arrive: '), write(ArrivalTime),nl,
  not( member( Next, Tried )),
  listpath( Next, End, [Next|Tried], List , CurrT).

  % from format.pl
  to_upper( Lower, Upper) :-
     atom_chars( Lower, Lowerlist),
     maplist( lower_upper, Lowerlist, Upperlist),
     atom_chars( Upper, Upperlist).

  print_trip( Action, Code, Name, time( Hour, Minute)) :-
     to_upper( Code, Upper_code),
     format( "%-6s  %3s  %-16s  %02d:%02d",
             [Action, Upper_code, Name, Hour, Minute]),
     nl.

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

%check_valid(Airport1, Airport2) :-

time_to_num(time(Hours, Minute), TimeNum) :-
  TimeNum is Hours + Minute / 60.


%case for trying to fly to the departure airport
fly(Airport1, Airport1) :-
    nl,
    write('cannot fly to the same airport'), fail.

fly(Airport1, Airport2) :-
    %check_valid(Airport1, Airport2),
    flight(Airport1, Airport2, time(Hours, Minute)),
    %p([Time], Hour, Minute).
    %nl, write(Airport1), write('yes'), write(Hours).
    airport(Airport1, Full1, _, _),
    airport(Airport2, Full2, _, _),


    nl,
    print_trip( depart, Airport1, Full1, time( 9, 3)),
    print_trip( arrive, Airport2, Full2, time( 9, 3)),

    nl.

% --------------------------------
