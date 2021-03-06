% https://learnxinyminutes.com/docs/prolog/

% Joseph Nguyen (jnguy243@ucsc.edu)
% Joshua Tai (jitai@ucsc.edu)

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
writeallpaths( Node, Node ) :- true.

writeallpaths( Node, Next ) :-
   listpath( Node, Next, [Node], _, 0 ,_).

writepath(trip(ap1(Node,DepartT),ap2(Next,ArriveT))) :-
    airport(Node, Full1, _, _),
    airport(Next, Full2, _, _),
    print_trip( depart, Node, Full1, DepartT),
    print_trip( arrive, Next, Full2, ArriveT).
writepath( [trip(ap1(Node,DepartT),ap2(Next,ArriveT))|Tail] ) :-
    nonvar(Tail) -> writepath( Tail ),
    writepath(trip(ap1(Node,DepartT),ap2(Next,ArriveT)));
    writepath(trip(ap1(Node,DepartT),ap2(Next,ArriveT))).

listpath( Node, End, Outlist ) :-
  write('outlist: '), write(Outlist),nl,
  listpath( Node, End, [Node], Outlist ).

listpath( Node, Node, _, [Node], _, Path) :-
  writepath(Path).
listpath( Node, End, Tried, [Node|List] , CurrTime,[Path]) :-
  flight( Node, Next, DepartT),
  time_to_num(DepartT, DepartTimeNum),
  compute_arrival_time(flight(Node, Next, DepartT), ArrivalTime),
  not( member( Next, Tried )),
  DepartTimeNum > CurrTime,
  CurrT is ArrivalTime + 0.5,
  num_to_time(ArrivalTime, ArriveT),
  listpath( Next, End, [Next|Tried], List , 
      CurrT, [trip(ap1(Node,DepartT),ap2(Next,ArriveT))|Path]).

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
    FlightTime is Distance / 500.

compute_arrival_time(flight(Airport1, Airport2, time(Hours, Minute)), ArrivalTime) :-
    compute_flight_time(Airport1, Airport2, FlightTime),
    DepartTime is Hours + Minute / 60, % converts DepartTime into hours
    ArrivalTime is FlightTime + DepartTime.

time_to_num(time(Hours, Minute), TimeNum) :-
  TimeNum is Hours + Minute / 60.

num_to_time(TimeNum, time(Hours, Minute)) :-
    Time is TimeNum * 60,
    Timet is truncate(Time),
    Hours is floor(Time / 60),
    Minute is mod(Timet,60).

fly(Airport1, Airport2) :-
    nl,
    var(Airport1) -> fail;
    var(Airport2) -> fail;
    Airport1 == Airport2 -> write('cannot fly to the same airport'), fail;
    writeallpaths(Airport1, Airport2).

fly(Airport1, _) :-
    write('Error: can not find airport in database.'),
    not(airport(Airport1,_,_,_)),
    fail.

fly(_, Airport2) :-
    not(airport(Airport2,_,_,_)),
    fail.
% --------------------------------
