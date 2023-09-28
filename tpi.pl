:- dynamic(partidos_hoy/5).
:- dynamic(equipo_es_de/2).
:- dynamic(campeon_liga/3).
:- discontiguous filtrar/1.
:- discontiguous opcion/1.

abrir_base:-
    retractall(partidos_hoy(_,_,_,_)),
    retractall(equipo_es_de(_,_)),
    retractall(campeon_liga(_,_,_)),
    consult("db.txt").
    
guardar_base:- 
    tell('db.txt'), 
    listing(partidos_hoy),
    listing(equipo_es_de),
    listing(campeon_liga),
    told.

inicio:- 
    write("Bienvenido al sistema de partidos de futbol! Ingrese su nombre"),nl,
    read(Nombre),
    nl,write("Hola "),write(Nombre),write("! Te interesa ver partidos hoy?"),nl,
    read(Opcion),
    Opcion\='no',
    Opcion\='No',
    validar_opcion(Opcion),
    nl,write("Las ligas de que pais te interesan?"),nl,
    read(Pais),
    abrir_base,
    validar_pais(Pais),
    nl,write("Conoces el nombre de las ligas del pais "), write(Pais), write("?"),nl,
    read(OpcionLigas),
    abrir_base,
    validar_opcion_ligas(OpcionLigas,Pais),
    nl,write("Que liga te interesa ver?"),nl,
    read(Liga),
    abrir_base,
    validar_liga_pais(Liga,Pais),
    nl,write("Que servicio de streaming tenes contratado?"),nl,
    read(Streaming),
    abrir_base,
    validar_streaming(Streaming),
    nl,write("Quiere conecer ademas el estadio y el horario en el que se juega?"),nl,
    read(Respuesta),
    validar_horaestadiosino(Respuesta,HoraEstadioSiNo),
    mostar_partidos(Streaming,Liga,HoraEstadioSiNo),
    nl,write("Te interesa ver los ultimos campeones de esa Liga?"),nl,
    read(OpcionCampeon),
    validar_opcioncampeon(OpcionCampeon),
    nl,write("Gracias por usar el sistema!"),nl,
    menu.
inicio. 

validar_opcion('si').
validar_opcion('Si').
validar_opcion(_) :-
    write("No pude entenderte, Te interesa ver partidos hoy? (si/no)"),
    nl.

validar_pais(Pais):- equipo_es_de(_,liga_es_de(_,Pais)).
validar_pais(_):- nl,write("El Pais ingresado no existe"),nl,fail.

validar_opcion_ligas(OpcionLigas):- OpcionLigas='si',mostrar_ligas_pais(Pais, []).
validar_opcion_ligas(OpcionLigas):- OpcionLigas='Si',mostrar_ligas_pais(Pais, []).
validar_opcion_ligas(OpcionLigas):- OpcionLigas='no',fail.
validar_opcion_ligas(OpcionLigas):- OpcionLigas='No',fail.
validar_opcion_ligas(_,Pais):- 
    nl,write("No pude entenderte, Conoces el nombre de las ligas del pais "),write(Pais), write("? (si/no)"),nl,
    read(OpcionLigas),
    validar_opcion_ligas(OpcionLigas,Pais).

mostrar_ligas_pais(Pais, LigasMostradas):- 
    equipo_es_de(_,liga_es_de(Liga, Pais)),
    \+ member(Liga, LigasMostradas), % Verificar si el país ya ha sido mostrado
    write("-> "), write(Liga),nl,
    retract(equipo_es_de(_,liga_es_de(Liga, Pais))),
    mostrar_ligas_pais(Pais, [Liga|LigasMostradas]).
mostrar_ligas_pais(_, _).

validar_liga_pais(Liga,Pais):- equipo_es_de(_,liga_es_de(Liga,Pais)).
validar_liga_pais(_,_):- write("La Liga ingresada no existe en ese Pais"),nl,fail.

validar_streaming(Streaming):- partidos_hoy(Streaming,_,_,_,_).
validar_streaming(Streaming):- nl,write("No hay partidos hoy para esa Liga transmitidos por ese servicio de Streaming"),nl.

validar_horaestadiosino('si', 1).
validar_horaestadiosino('Si', 1).
validar_horaestadiosino('no', 2).
validar_horaestadiosino('No', 2).
validar_horaestadiosino(_, _):- 
    nl,write("No pude entenderte, Quiere conocer ademas el estadio y el horario en el que se juega? (si/no)"),nl,
    read(HoraEstadioSiNo),
    validar_horaestadiosino(HoraEstadioSiNo, _).

mostrar_partidos(Streaming,Liga,HoraEstadioSiNo):- 
    equipo_es_de(Equipo1, liga_es_de(Liga, Pais)),
    equipo_es_de(Equipo2, liga_es_de(Liga, Pais)),
    Equipo1 \= Equipo2,
    partidos_hoy(Streaming,Equipo1,Equipo2,Hora,Estadio), %% Traemos el horario y el estadio, para cuando hacemos el retract, no eliminar ese partido de antes.
    write("=> "), write(Equipo1),write(" vs "),write(Equipo2), nl,
    retract(partidos_hoy(Streaming,Equipo1,Equipo2,Hora,Estadio)),
    mostrar_hora_estadio(Hora, Estadio, HoraEstadioSiNo),
    mostrar_partidos(Liga, Opcion).
mostrar_partidos(_,_):- nl.

mostrar_hora_estadio(Hora, Estadio, 1):-
    write("= "), write("El horario del partido es: "), write(Hora), nl,
    write("= "), write("El estadio del partido es: "), write(Estadio), nl.

validar_opcioncampeon(_,'Si'):- campeones(Liga).
validar_opcioncampeon(_,'si'):- campeones(Liga).
validar_opcioncampeon(_,'no').
validar_opcioncampeon(_,'No').
validar_opcioncampeon(_, _):- 
    nl,write("No pude entenderte, Te interesa ver los ultimos campeones de esa Liga? (si/no)"),nl,
    read(OpcionCampeon),
    validar_opcioncampeon(_, OpcionCampeon).

campeones(Liga):-
    write("Los ultimos campeones de la liga "),write(Liga),write(" son: "), nl,nl,
    abrir_base,
    mostrar_campeon_liga(Liga),
    nl,write("Desea agregar algun otro equipo campeon para esta liga ?"),
    read(Respuesta),
    validar_agregarcampeon(Respuesta).

mostrar_campeon_liga(Liga):-
    campeon_liga(Equipo, Liga, Anio),
    write("= "), write(Equipo), write(" - "), write(Anio),nl,
    retract(campeon_liga(Equipo, Liga, Anio)),
    mostrar_campeon_liga(Liga).
mostrar_campeon_liga(_):-  nl.

validar_agregarcampeon('Si'):- abrir_base,agregar_campeon(Liga).
validar_agregarcampeon('si'):- abrir_base,agregar_campeon(Liga).
validar_agregarcampeon('no').
validar_agregarcampeon('No').
validar_agregarcampeon(_):-
    nl,write("No pude entenderte, Desea agregar algun otro equipo campeon para esta liga ? (si/no)"),nl,
    read(Respuesta),
    validar_agregarcampeon(Respuesta).

agregar_campeon(Liga):-
    abrir_base,
    write("Cual es el nombre del equipo?"),
    read(Equipo),
    write("Ingrese el anio en el que salio campeon: "),
    read(Anio),
    assert(campeon_liga(Equipo, Liga, Anio)),
    guardar_base,
    write("Desea agregar otro equipo campeon para esta liga?"),
    read(Respuesta),
    validar_agregarcampeon(Respuesta).