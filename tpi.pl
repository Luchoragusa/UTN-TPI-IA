:- dynamic(partidos_hoy/4).
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

menu:-
    abrir_base, nl,
    write("======= Menu ======="),nl,
    write("Opcion 1 - Mostrar los partidos del dia de hoy en base a una liga/pais"),nl,
    write("Opcion 2 - Mostrar los ultimos campeones de una determinada liga de un pais"),nl,
    write("Opcion 0 - Salir"),
    nl,
    read(Opcion),
    nl,
    Opcion\=0,
    opcion(Opcion),
    menu.
menu.


menu_si_no(Opcion):-
    nl,
    write("1 - Si"),nl,
    write("2 - No"),nl,
    read(Opcion),
    validar_opcion(Opcion).
validar_opcion(1).
validar_opcion(2).
validar_opcion(_) :-
    write("Opcion no valida. Por favor, seleccione 1 o 2."), nl,
    menu_si_no(_).


opcion(1):-
    write("Opciones de filtrado"),nl,
    write("1 - Filtrar por liga"),nl,
    write("2 - Filtrar por pais"),nl,
    read(Opcion),
    nl,
    filtrar(Opcion).

    filtrar(1):-write("Las ligas cargadas en el sistema son: "),nl,
                abrir_base,
                mostrarLigas([]),
                write("Ingrese el nombre de la liga: "),
                read(Liga),nl,
                abrir_base, %% Usamos el abrir_base pq nosotros arriba usamos el retract para eliminar las ligas q fuimos mostrando
                verificar_liga(Liga), %% Verificamos si la liga existe, si falla, vuelve al write de "Ingrese el nombre de la liga: " | Linea 59
                write("Quiere conecer ademas el estadio y el horario en el que se juega?"),nl,
                menu_si_no(Opcion), nl,
                write("Los partidos de la liga "), write(Liga), write(" son: "), nl,
                obtenerPartidosLiga(Liga, Opcion).
        
        mostrarLigas(LigasMostrados):- %% ligasMostradas es una lista que contiene las ligas que ya han sido mostradas
            equipo_es_de(_, liga_es_de(Liga, _)),
            \+ member(Liga, LigasMostrados), %% Verificar si la liga esta o no en la cadena LigasMostradas
            write("= "), write(Liga),nl,
            retract(equipo_es_de(_, liga_es_de(Liga, _))),
            mostrarLigas([Liga|LigasMostrados]). %% Agregar la liga a la cadena de LigasMostradas, como un push
        mostrarLigas(_):- nl,nl.
            
        verificar_liga(Liga):- equipo_es_de(_,liga_es_de(Liga, _)).  
        verificar_liga(_):- write("La Liga ingresada no existe"),nl, fail.

        obtenerPartidosLiga(Liga, Opcion):-
            equipo_es_de(Equipo1, liga_es_de(Liga, Pais)),
            equipo_es_de(Equipo2, liga_es_de(Liga, Pais)),
            Equipo1 \= Equipo2,
            partidos_hoy(Equipo1,Equipo2,Hora,Estadio), %% Traemos el horario y el estadio, para cuando hacemos el retract, no eliminar ese partido de antes.
            write("=> "), write(Equipo1),write(" vs "),write(Equipo2), nl,
            retract(partidos_hoy(Equipo1,Equipo2,Hora,Estadio)),
            mostrar_hora_estadio(Hora, Estadio, Opcion),
            obtenerPartidosLiga(Liga, Opcion).
        obtenerPartidosLiga(_, _):- nl.

            mostrar_hora_estadio(Hora, Estadio, 1):-
                write("= "), write("El horario del partido es: "), write(Hora), nl,
                write("= "), write("El estadio del partido es: "), write(Estadio), nl.


    filtrar(2):- write("Los paises cargados en el sistema son: "),nl,
                mostrarPaises([]),
                abrir_base,
                write("Ingrese el nombre del pais: "),
                read(Pais),
                verificar_pais(Pais),
                write("Quiere conecer ademas el estadio y el horario en el que se juega?"),nl,
                menu_si_no(Opcion),
                write("Los partidos del pais "), write(Pais), write(" son: "), nl,
                obtenerPartidosPais(Pais, Opcion).

        mostrarPaises(PaisesMostrados):-
            equipo_es_de(_,liga_es_de(_, Pais)),
            \+ member(Pais, PaisesMostrados), % Verificar si el país ya ha sido mostrado
            write("= "), write(Pais),nl,
            retract(equipo_es_de(_,liga_es_de(_, Pais))),
            mostrarPaises([Pais|PaisesMostrados]).
        mostrarPaises(_):- nl.
    
        verificar_pais(Pais):- equipo_es_de(_,liga_es_de(_,Pais)).
        verificar_pais(_):- nl,write("El Pais ingresado no existe"),nl,fail.

        obtenerPartidosPais(Pais, Opcion):-
            equipo_es_de(Equipo1,liga_es_de(Liga, Pais)),
            equipo_es_de(Equipo2,liga_es_de(Liga, Pais)),
            Equipo1 \= Equipo2,
            partidos_hoy(Equipo1,Equipo2,Hora,Estadio),
            write("=> "), write(Equipo1),write(" vs "),write(Equipo2), nl,
            retract(partidos_hoy(Equipo1,Equipo2,Hora,Estadio)),
            mostrar_hora_estadio(Hora, Estadio, Opcion),    %es el de arriba
            obtenerPartidosPais(Pais, Opcion).
        obtenerPartidosPais(_,_):- nl.

    filtrar(_):- % condicion de comprobacion 
        write("Opcion no valida. Por favor, seleccione 1 o 2."),
        nl,nl,
        opcion(1).

opcion(2):-
    write("Los paises cargados en el sistema son: "),nl,
    mostrarPaises([]),
    abrir_base,
    write("Ingrese el nombre del pais: "),
    read(Pais),
    verificar_pais(Pais),
    write("Las ligas pertenecientes a ese pais son: "),nl,
    mostrar_ligas_pais(Pais, []),
    write("Ingrese el nombre de la liga: "),
    read(Liga),
    abrir_base,
    verificar_liga_pais(Liga,Pais),
    write("Los ultimos campeones de la liga "),write(Liga),write(" son: "), nl,nl,
    mostrar_campeon_liga(Liga),
    write("Desea agregar algun otro equipo campeon para esta liga ?"),
    menu_si_no(Opcion),
    agregar_campeon(Opcion, Liga).
    
        mostrar_ligas_pais(Pais, LigasMostradas):- % por si un pais tiene +1 liga
            equipo_es_de(_,liga_es_de(Liga, Pais)),
            \+ member(Liga, LigasMostradas), % Verificar si el país ya ha sido mostrado
            write("= "), write(Liga),nl,
            retract(equipo_es_de(_,liga_es_de(Liga, Pais))),
            mostrar_ligas_pais(Pais, [Liga|LigasMostradas]).
        mostrar_ligas_pais(_, _).

        verificar_liga_pais(Liga,Pais):- equipo_es_de(_,liga_es_de(Liga,Pais)).
        verificar_liga_pais(_,_):- write("La Liga ingresada no existe en ese Pais"),nl,fail.

        mostrar_campeon_liga(Liga):-
            campeon_liga(Equipo, Liga, Anio),
            write("= "), write(Equipo), write(" - "), write(Anio),nl,
            retract(campeon_liga(Equipo, Liga, Anio)),
            mostrar_campeon_liga(Liga).
        mostrar_campeon_liga(_):-  nl.

        agregar_campeon(1, Liga):-
            abrir_base,
            write("Ingrese el nombre del equipo: "),
            read(Equipo),
            write("Ingrese el anio en el que salio campeon: "),
            read(Anio),
            assert(campeon_liga(Equipo, Liga, Anio)),
            guardar_base,
            write("Desea agregar algun otro equipo campeon para esta liga ?"),
            menu_si_no(Opcion),
            agregar_campeon(Opcion, Liga).
        agregar_campeon(2, _):- write("Gracias por responder!"),nl.

opcion(_):-write("Opcion no valida. Por favor, seleccione una opcion valida."), nl.
