:- dynamic(partidos_hoy/5).
:- dynamic(equipo_es_de/2).
:- dynamic(campeon_liga/3).

abrir_base:-
    retractall(partidos_hoy(_,_,_,_,_)),
    retractall(equipo_es_de(_,_)),
    retractall(campeon_liga(_,_,_)),
    consult('db.txt').

guardar_base:-
    tell('db.txt'),
    listing(partidos_hoy),
    listing(equipo_es_de),
    listing(campeon_liga),
    told.

inicio:-
    write("Bienvenido al sistema de partidos de futbol! Ingrese su nombre"),nl,
    read(Nombre),
    inicio_ver_partidos(Nombre),
    inicio_pais(Pais),
    inicio_ligas(Pais,Liga),
    inicio_streamingg(Streaming,Liga,HayPartidos),
    inicio_estadio_horario(HayPartidos,HoraEstadioSiNo),
    inicio_mostrar_partidos(HayPartidos,HoraEstadioSiNo,Streaming,Liga),
    inicio_ultimos_campeones(Liga),
    nl,write("Gracias por usar el sistema!"),nl.

inicio_ver_partidos(Nombre):-
    nl,write("Hola "),write(Nombre),write("! Te interesa ver partidos hoy? [si/no]"),nl,
    read(Opcion),
    Opcion\='no',
    validar_opcion(Opcion).

validar_opcion('si').
validar_opcion(_) :-
    nl,write("No pude entenderte, Te interesa ver partidos hoy? (si/no)"),nl,
    read(Opcion),
    Opcion\='no',
    validar_opcion(Opcion).

inicio_pais(PaisDevuelto):-
    nl,write("Las ligas de que pais te interesan?"),nl,
    read(PaisIngresado),
    abrir_base,
    validar_pais(PaisIngresado,PaisDevuelto).

% Probar si puedo usar 1 sola variable de pais en lugar de 2

validar_pais(PaisIngresado,PaisDevuelto):- equipo_es_de(_,liga_es_de(_,PaisIngresado)), PaisDevuelto = PaisIngresado.
validar_pais(_,PaisDevuelto):-
    nl,write("El Pais ingresado no existe"),nl,
    inicio_pais(PaisDevuelto).

inicio_ligas(Pais,Liga):-
    nl,write("Conoces el nombre de las ligas del pais "), write(Pais), write("? [si/no]"),nl,
    read(OpcionLigas),nl,
    abrir_base,
    validar_opcion_ligas(OpcionLigas,Pais),
    nl,write("Que liga te interesa ver?"),nl,
    read(Liga),
    abrir_base,
    validar_liga_pais(Liga,Pais).

validar_opcion_ligas('si',_).
validar_opcion_ligas('no',Pais):-
    write("Las ligas de "),write(Pais),write(" son:"),nl,
    mostrar_ligas_pais(Pais, []).
validar_opcion_ligas(_,Pais):-
    nl,write("No pude entenderte, conoces el nombre de las ligas de "),write(Pais), write("? (si/no)"),nl,
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
validar_liga_pais(_,_):- nl,write("La liga que ingresaste no existe en ese pais."),nl,fail.

inicio_streamingg(Streaming,Liga,HayPartidos):-
    nl,write("Que servicio de streaming tenes contratado?"),nl,
    read(Streaming),
    abrir_base,
    validar_streaming(Streaming,Liga,HayPartidos).

validar_streaming(Streaming,Liga,1):- partidos_hoy(Streaming,_,Equipo,_,_),equipo_es_de(Equipo,liga_es_de(Liga,_)).
validar_streaming(_,_,0):- nl,write("No hay partidos hoy para esa Liga transmitidos por ese servicio de Streaming, debe contratar otro que lo transmita"),nl.


inicio_estadio_horario(1,HoraEstadioSiNo):-
    nl,write("Quiere conocer ademas el estadio y el horario en el que se juega? [si/no]"),nl,
    read(Respuesta),
    validar_horaestadiosino(Respuesta,HoraEstadioSiNo).
inicio_estadio_horario(0,_).

validar_horaestadiosino('si', 1).
validar_horaestadiosino('no', 0).
validar_horaestadiosino(_,Respuesta):-
    nl,write("No pude entenderte, quiere conocer ademas el estadio y el horario en el que se juega? (si/no)"),nl,
    read(HoraEstadioSiNo),
    validar_horaestadiosino(HoraEstadioSiNo,Respuesta).

inicio_mostrar_partidos(1,HoraEstadioSiNo,Streaming,Liga):-
    equipo_es_de(Equipo1, liga_es_de(Liga,_)),
    equipo_es_de(Equipo2, liga_es_de(Liga,_)),
    Equipo1 \= Equipo2,
    partidos_hoy(Streaming,Equipo1,Equipo2,Hora,Estadio), %% Traemos el horario y el estadio, para cuando hacemos el retract, no eliminar ese partido de antes.
    nl,write("=> "), write(Equipo1),write(" vs "),write(Equipo2), nl,
    retract(partidos_hoy(Streaming,Equipo1,Equipo2,Hora,Estadio)),
    mostrar_hora_estadio(HoraEstadioSiNo,Hora, Estadio),
    inicio_mostrar_partidos(1,HoraEstadioSiNo,Streaming,Liga).
inicio_mostrar_partidos(_,_,_,_).

mostrar_hora_estadio(1,Hora, Estadio):-
    write("= "), write("El horario del partido es: "), write(Hora), nl,
    write("= "), write("El estadio del partido es: "), write(Estadio), nl.
mostrar_hora_estadio(0,_,_).

inicio_ultimos_campeones(Liga):-
    nl,write("Te interesa ver los ultimos campeones de esa Liga? [si/no]"),nl,
    read(OpcionCampeon),
    validar_opcioncampeon(Liga,OpcionCampeon).

validar_opcioncampeon(Liga,'si'):- campeones(Liga).
validar_opcioncampeon(_,'no').
validar_opcioncampeon(_, _):-
    nl,write("No pude entenderte, Te interesa ver los ultimos campeones de esa Liga? (si/no)"),nl,
    read(OpcionCampeon),
    validar_opcioncampeon(_, OpcionCampeon).

campeones(Liga):-
    nl,write("Los ultimos campeones de la liga "),write(Liga),write(" son: "), nl,nl,
    abrir_base,
    mostrar_campeon_liga(Liga),
    nl,write("Desea agregar algun otro equipo campeon para esta liga? [si/no]"),nl,
    read(Respuesta),
    validar_agregarcampeon(Respuesta,Liga).

mostrar_campeon_liga(Liga):-
    campeon_liga(Equipo, Liga, Anio),
    write("= "), write(Equipo), write(" - "), write(Anio),nl,
    retract(campeon_liga(Equipo, Liga, Anio)),
    mostrar_campeon_liga(Liga).
mostrar_campeon_liga(_):-  nl.

validar_agregarcampeon('si',Liga):- abrir_base,agregar_campeon(Liga).
validar_agregarcampeon('no',_).
validar_agregarcampeon(_,Liga):-
    nl,write("No pude entenderte, Desea agregar algun otro equipo campeon para esta liga ? (si/no)"),nl,
    read(Respuesta),
    validar_agregarcampeon(Respuesta,Liga).

agregar_campeon(Liga):-
    abrir_base,
    write("Cual es el nombre del equipo?"),
    read(Equipo),
    write("Ingrese el anio en el que salio campeon: "),
    read(Anio),
    assert(campeon_liga(Equipo, Liga, Anio)),
    guardar_base,
    write("Desea agregar otro equipo campeon para esta liga? [si/no]"),
    read(Respuesta),
    validar_agregarcampeon(Respuesta,Liga).
