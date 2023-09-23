:- dynamic(partidos_hoy/4).
:- dynamic(liga_es_de/2).
:- dynamic(equipo_es_de/2).
:- dynamic(campeon_liga/3).

abrir_base:- 
    retractall(apartidos_hoy(_,_,_,_)), 
    retractall(liga_es_de(_,_)), 
    retractall(equipo_es_de(_,_)), 
    retractall(campeon_liga(_,_,_)),
    consult("db.txt").

menu:-
    abrir_base,
    write("Opcion 1 - Mostrar los partidos del dia de hoy en base a una liga/pais"),nl,
    write("Opcion 2 - Mostrar los ultimos campeones de una determinada liga de un pais"),nl,
    write("0 - Salir"),
    nl,
    read(Opcion),
    Opcion\=0,
    opcion(Opcion),
    menu.
menu.


opcion(1):- 
    write("Opciones de filtrado"),nl,
    write("1 - Filtrar por liga"),nl,
    write("2 - Filtrar por pais"),nl,   %TODO --> opcion dentro "desea conocer el horario de los partidos?" y que muestre los estadios
    read(Opcion),
    filtrar(Opcion).

    mostrarLigas:-
        write("Las ligas cargadas en el sistema son: "),nl,
        findall(Liga, liga_es_de(Liga,_), Ligas),
        mostrar(Ligas).
    
    mostrar([]).
    mostrar([X|Xs]):-
        write(X),nl,
        mostrar(Xs).

    filtrar(1):- write("Las ligas cargadas en el sistema son: "),nl,
                mostrarLigas(),
                write("Ingrese el nombre de la liga: "),
                read(Liga),
                write("Los partidos de la liga "), write(Liga), write(" son: "), nl,
                obtenerPartidosLiga(Liga),
                menu.

    obtenerPartidosLiga(Liga):- 
        partidos_hoy(Equipo1,Equipo2,_,_),
        equipo_es_de(Equipo1,Pais),
        equipo_es_de(Equipo2,Pais),
        liga_es_de(Liga,Pais),
        write(Equipo1),write(" vs "),write(Equipo2), nl, fail.


    mostrarPaises():- equipo_es_de(_,Pais), write(Pais),nl,fail.

    filtrar(2):- write("Los paises cargados en el sistema son: "),nl,
                mostrarPaises(),
                write("Ingrese el nombre del pais: "),
                read(Pais),
                write("Los partidos del pais "), write(Pais), write(" son: "), nl,
                obtenerPartidosPais(Pais),
                menu.

    obtenerPartidosPais(Pais):-
        partidos_hoy(Equipo1,Equipo2,_,_),
        equipo_es_de(Equipo1,Pais),
        equipo_es_de(Equipo2,Pais),
        write(Equipo1),write(" vs "),write(Equipo2), nl, fail.
    
opcion(2):- 
    write("Los paises cargados en el sistema son: "),nl,
    mostrarPaises(),
    write("Ingrese el nombre del pais: "),
    read(Pais),
    write("Las ligas pertenecientes a ese pais son: "),nl,
    liga_es_de(Liga,Pais),
    write(Liga),nl,
    write("Ingrese el nombre de la liga: "),
    read(Liga),
    write("Los ultimos campeones de la liga "),write(Liga),write(" son: "),nl,
    campeon_liga(_,Liga,Anio),
    write(Anio),nl.

opcion(3):- write("Opcion 3").
            
