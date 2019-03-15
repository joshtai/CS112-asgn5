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
writeallpaths( Node, Node ) :- true.
   %write( Node ), write( ' this is wrongxs ' ), write( Node ), nl.

writeallpaths( Node, Next ) :-
   listpath( Node, Next, [Node], List, 0 ,Path).
   %write( Node ), write( ' to ' ), write( Next ), write( ' is ' ),
   %write('yes'),write(Path),nl,
   %writepath( Path ),


writepath(trip(ap1(Node,DepartT),ap2(Next,ArriveT))) :-
    %write('Node: '), write(Node),write(' End: '), write(Next),write(' depart: '), write(DepartT),write(' arrive: '), write(ArriveT),nl,
    airport(Node, Full1, _, _),
    airport(Next, Full2, _, _),
    %write('arrivalt: '), write(ArrivalTime),nl,
    %num_to_time(ArrivalTime, ArriveT),
    print_trip( depart, Node, Full1, DepartT),
    print_trip( arrive, Next, Full2, ArriveT).
writepath( [trip(ap1(Node,DepartT),ap2(Next,ArriveT))|Tail] ) :-
    nonvar(Tail) -> writepath( Tail ),
    writepath(trip(ap1(Node,DepartT),ap2(Next,ArriveT)));
    writepath(trip(ap1(Node,DepartT),ap2(Next,ArriveT))).
   %write( ' ' ), write( trip(ap1(Node,DepartT),ap2(Next,ArrivalTime)) ), nl.
   %write('tail: '), write(Tail),nl.

   %airport(Head, Full1, _, _),
   %print_trip( depart, Head, Full1, DepartT),


listpath( Node, End, Outlist ) :-
  write('outlist: '), write(Outlist),nl,
  listpath( Node, End, [Node], Outlist ).

listpath( Node, Node, _, [Node], CurrTime, Path) :-
  writepath(Path).
listpath( Node, End, Tried, [Node|List] , CurrTime,[Path]) :-

  %write('Node: '), write(Node),write(' End: '), write(End),write(' Tried: '), write(Tried),nl,
  flight( Node, Next, DepartT),
  time_to_num(DepartT, DepartTimeNum),
  %write(' depart: '), write(DepartTimeNum),nl,
  %write(' currtime: '), write(CurrTime),nl,

  compute_arrival_time(flight(Node, Next, DepartT), ArrivalTime),
  %write(' arrive: '), write(ArrivalTime),nl,
  not( member( Next, Tried )),
  DepartTimeNum > CurrTime,

  %num_to_time(ArrivalTime, ArriveT),
  %airport(Node, Full1, _, _),
  %airport(Next, Full2, _, _),
  %print_trip( depart, Node, Full1, DepartT),
  %print_trip( arrive, Next, Full2, ArriveT),
  %write('arrive at '), write(ArriveT), nl.
  CurrT is ArrivalTime + 0.5,
  num_to_time(ArrivalTime, ArriveT),
  %write('listpath: '), write(ArrivalTime),nl,
  listpath( Next, End, [Next|Tried], List , CurrT, [trip(ap1(Node,DepartT),ap2(Next,ArriveT))|Path]).

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

num_to_time(TimeNum, time(Hours, Minute)) :-
    %write('timenum: '), write(TimeNum), nl,
    Time is TimeNum * 60,
    Timet is truncate(Time),
    Hours is floor(Time / 60),
    Minute is mod(Timet,60).




fly(Airport1, Airport2) :-
    nl,
    var(Airport1) -> fail;
    Airport1 == Airport2 -> write('cannot fly to the same airport'),fail;
    writeallpaths(Airport1, Airport2).

% --------------------------------
