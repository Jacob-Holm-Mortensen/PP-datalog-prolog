% Author: Jacob Holm Mortensen, jmorte14
% Date: 12/12/2017

%% Problems
% Problem 1
airline(Name, FlightLegs).

weatherCondition(clear).
weatherCondition(cloudy).
weatherCondition(windy).
weatherCondition(thunderstorms).

airport(IATA, PrimaryCity, LocatedAt, Weather) :- weatherCondition(Weather).

seat(seat("27b", "Business", "other", "27a", "27c")).
seat(seat("50a", "Economy", "window", "none", "50b")).

model("Airbus A380", Seat, heavy) :- seat(Seat).

allowedInWeather(light, clear).
allowedInWeather(light, cloudy).
allowedInWeather(heavy, clear).
allowedInWeather(heavy, cloudy).
allowedInWeather(heavy, windy).

aircraft("OY-JJO", Model, "Airbus", heavy)

aircraft(RegNr, Model, Manufacturer, Type) :- reg(RegNr), model(Model), manufacturer(Manufacturer).

passanger(FName, LName, Birthday).

passport(Passenger, Country).

leg(AirportOne, AirportTwo, ServiceAirline, OperatingAirline, Aircraft).

booking(BookingCode, Passenger).

reservation(BookingCode, Origin, Destination, Airline, SeatNr) :- booking(BookingCode).

itinerary(Code, Reservations).

visaAgreement(CountryOne, CountryTwo).

% Problem 2

% Problem 3
allowedAirportDestinations(Passenger, IATA) :- passport(Passenger, Country), airport(IATA, _, Country, _);
                                               passport(Passenger, Country), visaAgreement(Country, OtherCountry), airport(IATA, _, OtherCountry, _);
                                               passport(Passenger, Country), visaAgreement(OtherCountry, Country), airport(IATA, _, OtherCountry, _).

% Problem 4
illegalReservation(Passenger) :- booking(BookingCode, Passenger), reservation(BookingCode, _, Destination, _, _), not allowedAirportDestination(Passenger, Destination);

% Problem 5
% doubleBook(BookingCode) :-

% Problem 6
permittedTakeoff(RegNr) :- not doubleBook(BookingCode), reservation(BookingCode, Origin, Destination, Airline, _), leg(Origin, Destination, _, Airline, Aircraft), aircraft(RegNr, _, _, Type),
                           airport(Origin, _, _ OWeather), allowedWeather(Type, OWeather), airport(Destination, _, _ DWeather), allowedWeather(Type, DWeather),
                           booking(BookingCode, Passenger), not illegalReservation(Passenger).

% Problem 7


% Problem 8

