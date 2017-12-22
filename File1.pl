% Author:
% Date: 13/12/2017

%%%%%%%%%%%%%%%%%%%%% Facts %%%%%%%%%%%%%%%%%%%%%
%% Airlines
% name, aircraft id
airline("SAS", "ZY-JJO").
airline("SAS", "OY-JJO").
airline("SAS", "XY-JJO").
airline("Air Canada", "BB-JJO").

%% Airports
% name, city, country, weather condition
airport("YYZ", "Toronto", "Canada", clear).
airport("CPH", "Copenhagen", "Denmark", cloudy).
airport("MCI", "Kansas City", "USA", windy).

%% Aircrafts
% id, model, manufacturer
aircraft("ZY-JJO", "Airbus A380", "Airbus").
aircraft("OY-JJO", "Airbus A380", "Airbus").
aircraft("XY-JJO", "Airbus A380", "Airbus").
aircraft("BB-JJO", "Boeing 777", "Boeing").

%% Aircraft models
% model, weight class
aircraftModel("Airbus A380", heavy).

%% Seats
% model, nr., class, type, left, right
seat("Airbus A380", "27A", "Economy", "Window", "", "27B").
seat("Airbus A380", "27B", "Economy", "Other", "27A", "27C").
seat("Airbus A380", "27C", "Economy", "aisle", "27B", "").

seat("Boeing 777", "1A", "Economy", "Window", "1B", "").

%% Allowed flight weather
% weigth class, weather condition
allowedWeather(light, clear).
allowedWeather(light, cloudy).
allowedWeather(heavy, clear).
allowedWeather(heavy, cloudy).
allowedWeather(heavy, windy).

%% Flight legs
% origin airport, destination airport, airline name, aircraft id
flightLeg("CPH", "YYZ", "SAS", "OY-JJO").
flightLeg("YYZ", "MCI", "SAS", "XY-JJO").
flightLeg("MCI", "YYZ", "Air Canada", "BB-JJO").

%% Passengers
% CPR nr., first name, last name, birthdate
passenger("ddmmyy-xxxx", "Jacob", "Mortensen", "dd.mm.yyyy").
passenger("ddmmyy-zzzz", "Bitten", "Wils", "dd.mm.yyyy").

%% Passports
% CPR nr., country
passport("ddmmyy-xxxx", "Denmark").
passport("ddmmyy-xxxx", "USA").
passport("ddmmyy-zzzz", "Denmark").

%% Visa agreements
% country, country
visaAgreement("Denmark", "Canada").

%% Itenerary
% Multi-leg booking code, leg booking code
itenerary("ABC", "8V32EU").
itenerary("DEF", "9V32EU").

%% Bookings
% leg booking code, CPR nr.
booking("8V32EU", "ddmmyy-xxxx").
booking("9V32EU", "ddmmyy-zzzz").

%% Reservations
% leg booking code, origin airport, destination airport, airline name, seat nr.
reservation("8V32EU", "CPH", "YYZ", "SAS", "27B").
reservation("9V32EU", "YYZ", "MCI", "SAS", "27B").

%%%%%%%%%%%%%%%%%%%%% Rules %%%%%%%%%%%%%%%%%%%%%
%% Flight
% origin airport, destination airport, airline name, aircraft id leg one, aircraft id next leg
flight(Origin, Destination, Airline, AircraftId, _) :- flightLeg(Origin, Destination, Airline, AircraftId).
flight(Origin, Destination, Airline, AircraftIdOne, AircraftIdTwo) :- flightLeg(Origin, StopoverAirport, Airline, AircraftIdOne),
                                                                      flight(StopoverAirport, Destination, Airline, AircraftIdTwo, _).
                                                                
%% Problem 3
% Returns the airports a passenger is allowed to fly towards in the second variable
% CPR is the passengers CPR number
% IATA is the airports identification code
% allowedAirportDestinations("ddmmyy-xxxx", X). returns "YYZ" and "CPH"

allowedAirportDestinations(CPR, IATA) :- passenger(CPR, _, _, _), passport(CPR, Country), airport(IATA, _, Country, _);
                                         passenger(CPR, _, _, _), passport(CPR, Country), visaAgreement(Country, OtherCountry), airport(IATA, _, OtherCountry, _);
                                         passenger(CPR, _, _, _), passport(CPR, Country), visaAgreement(OtherCountry, Country), airport(IATA, _, OtherCountry, _).

%% Problem 4
% Returns a boolean value representing if a passenger (presented by his CPR nr.) have any reservations to a country he is not allowed to enter
% CPR is the passengers CPR number
% illegalReservations("ddmmyy-xxxx"). returns false
% illegalReservations("ddmmyy-zzzz"). returns true

illegalReservations(CPR) :- booking(BookingCode, CPR), reservation(BookingCode, _, Destination, _, _),
                            not(allowedAirportDestinations(CPR, Destination));
                            booking(BookingCode, CPR), reservation(BookingCode, Origin, _, _, _),
                            not(allowedAirportDestinations(CPR, Origin)).

%% Problem 5
% Returns the booking codes for all reservations, where two passengers have reserved the same seat on the same flight leg in the first variable
% BookingCode is the booking codes, which is double bookings
% doubleBookings(X). returns false if there is no double bookings

doubleBookings(BookingCode) :- flightLeg(Origin, Destination, Airline, _),
                               reservation(BookingCode, Origin, Destination, Airline, Seat), reservation(BookingCodeTwo, Origin, Destination, Airline, Seat),
                               booking(BookingCode, CPR), booking(BookingCodeTwo, CPRTwo),
                               not(booking(BookingCode, CPR) == booking(BookingCodeTwo, CPRTwo)).

%% Problem 6
%
%
%
clearedForTakeoff(AircraftId) :- flightLeg(Origin, Destination, Airline, AircraftId),
                                 aircraft(AircraftId, AircraftModel, _),
                                 aircraftModel(AircraftModel, Type),
                                 reservation(BookingCode, Origin, Destination, Airline, _),
                                 not(doubleBookings(BookingCode)),
                                 airport(Origin, _, _, OWeather), allowedWeather(Type, OWeather),
                                 airport(Destination, _, _, DWeather), allowedWeather(Type, DWeather),
                                 booking(BookingCode, CPR), not(illegalReservations(CPR)).

%% Problem 7 a
%
%
%
noReservationOrUnallowedDestinations(Origin, Destination, Airline, AircraftId, CPR, SeatNr) :- aircraft(AircraftId, AircraftModel, _),
                                                                                             seat(AircraftModel, SeatNr, _, _, _, _),
                                                                                             not(reservation(_, Origin, Destination, Airline, SeatNr)),
                                                                                             allowedAirportDestinations(CPR, Origin),
                                                                                             allowedAirportDestinations(CPR, Destination).

checkFlight(Origin, Destination, Airline, AircraftId, _, CPR) :- flightLeg(Origin, Destination, Airline, AircraftId),
                                                                 noReservationOrUnallowedDestinations(Origin, Destination, Airline, AircraftId, CPR, _).

checkFlight(Origin, Destination, Airline, AircraftIdOne, AircraftIdTwo, CPR) :- flightLeg(Origin, StopoverAirport, Airline, AircraftIdOne),
                                                                                noReservationOrUnallowedDestinations(Origin, Destination, Airline, AircraftIdOne, CPR, _),
                                                                                checkFlight(StopoverAirport, Destination, Airline, AircraftIdTwo, _, CPR).

mayBookFlight(CPR, Origin, Destination) :- checkFlight(Origin, Destination, _, _, _, CPR).

%% Problem 7 b
%
%
%
checkSameAirlineFlight(Origin, Destination, Airline, AircraftId, _, CPR, OperatorAirline) :- flightLeg(Origin, Destination, Airline, AircraftId),
                                                                                             noReservationOrUnallowedDestinations(Origin, Destination, Airline, AircraftId, CPR, _),
                                                                                             airline(OperatorAirline, AircraftId).

checkSameAirlineFlight(Origin, Destination, Airline, AircraftIdOne, AircraftIdTwo, CPR, OperatorAirline) :- flightLeg(Origin, StopoverAirport, Airline, AircraftIdOne),
                                                                                                            noReservationOrUnallowedDestinations(Origin, Destination, Airline, AircraftIdOne, CPR, _),
                                                                                                            airline(OperatorAirline, AircraftIdOne),
                                                                                                            checkSameAirlineFlight(StopoverAirport, Destination, Airline, AircraftIdTwo, _, CPR, OperatorAirline).

mayBookSameAirlineFlight(CPR, Origin, Destination) :- checkSameAirlineFlight(Origin, Destination, _, _, _, CPR, _).

%% Problem 7 c
%
%
%
checkBoeingFlight(Origin, Destination, Airline, AircraftId, _, CPR) :- flightLeg(Origin, Destination, Airline, AircraftId),
                                                                       noReservationOrUnallowedDestinations(Origin, Destination, Airline, AircraftId, CPR, _),
                                                                       aircraft(AircraftId, _, "Boeing").

checkBoeingFlight(Origin, Destination, Airline, AircraftIdOne, AircraftIdTwo, CPR) :- flightLeg(Origin, StopoverAirport, Airline, AircraftIdOne),
                                                                                      noReservationOrUnallowedDestinations(Origin, Destination, Airline, AircraftIdOne, CPR, _),
                                                                                      aircraft(AircraftIdOne, _, "Boeing"),
                                                                                      checkBoeingFlight(StopoverAirport, Destination, Airline, AircraftIdTwo, _, CPR).

mayBookBoeingFlight(CPR, Origin, Destination) :- checkBoeingFlight(Origin, Destination, _, _, _, CPR).

%% Problem 7 d
%
%
%
checkWindowFlight(Origin, Destination, Airline, AircraftId, _, CPR) :- flightLeg(Origin, Destination, Airline, AircraftId),
                                                                       noReservationOrUnallowedDestinations(Origin, Destination, Airline, AircraftId, CPR, SeatNr),
                                                                       aircraft(AircraftId, AircraftModel, _),
                                                                       seat(AircraftModel, SeatNr, _, "Window", _, _).

checkWindowFlight(Origin, Destination, Airline, AircraftIdOne, AircraftIdTwo, CPR) :- flightLeg(Origin, StopoverAirport, Airline, AircraftIdOne),
                                                                                      noReservationOrUnallowedDestinations(Origin, Destination, Airline, AircraftIdOne, CPR, SeatNr),
                                                                                      aircraft(AircraftIdOne, AircraftModel, _),
                                                                                      seat(AircraftModel, SeatNr, _, "Window", _, _),
                                                                                      checkWindowFlight(StopoverAirport, Destination, Airline, AircraftIdTwo, _, CPR).

mayBookWindowFlight(CPR, Origin, Destination) :- checkWindowFlight(Origin, Destination, _, _, _, CPR).

%% Problem 8
%
%
%



























