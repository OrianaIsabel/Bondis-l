% Aquí va el código.

% Recorridos en GBA:
recorrido(17, gba(sur), mitre).
recorrido(24, gba(sur), belgrano).
recorrido(247, gba(sur), onsari).
recorrido(60, gba(norte), maipu).
recorrido(152, gba(norte), olivos).

% Recorridos en CABA:
recorrido(17, caba, santaFe).
recorrido(152, caba, santaFe).
recorrido(10, caba, santaFe).
recorrido(160, caba, medrano).
recorrido(24, caba, corrientes).

% Punto 1

puedenCombinarse(Linea1, Linea2):-
    recorrido(Linea1, Zona, Calle),
    recorrido(Linea2, Zona, Calle),
    Linea1 \= Linea2.

% Punto 2

cruzaGralPaz(Linea):-
    recorrido(Linea, gba(_),_),
    recorrido(Linea, caba,_).

pertenece(gba(_), buenosAires).

pertenece(caba, caba).

jurisdiccion(Linea, nacional):-
    cruzaGralPaz(Linea).

jurisdiccion(Linea, provincial(Provincia)):-
    recorrido(Linea, Zona,_),
    pertenece(Zona, Provincia),
    not(cruzaGralPaz(Linea)).

% Punto 3

cuantasTransitan(Calle, Zona, Cantidad):-
    recorrido(_, Zona, Calle),
    findall(Linea, recorrido(Linea, Zona, Calle), Lineas),
    length(Lineas, Cantidad).

calleMasTransitada(Zona, Calle):-
    recorrido(_, Zona, Calle),
    cuantasTransitan(Calle, Zona, Cantidad),
    forall(recorrido(_, Zona, Otra), (cuantasTransitan(Otra, Zona, OtraCantidad), Cantidad >= OtraCantidad)).

calleDeTrasbordo(Zona, Calle):-
    recorrido(_, Zona, Calle),
    cuantasTransitan(Calle, Zona, Cantidad),
    Cantidad >= 3,
    forall(recorrido(Linea, Zona, Calle), jurisdiccion(Linea, nacional)).

% Punto 5

beneficiario(pepito, personal(gba(oeste))).
beneficiario(juanita, estudiantil).
beneficiario(marta, jubilado).
beneficiario(marta, personal(caba)).
beneficiario(marta, personal(gba(sur))).

beneficio(estudiantil,_, 50).

beneficio(personal(Zona), Linea, 0):-
    recorrido(Linea, Zona,_).

beneficio(jubilado, Linea, Costo):-
    costo(Linea, CostoBase),
    Costo is CostoBase / 2.

costo(Linea, 500):-
    jurisdiccion(Linea, nacional).

costo(Linea, 350):-
    jurisdiccion(Linea, provincial(caba)).

costo(Linea, Costo):-
    jurisdiccion(Linea, provincial(buenosAires)),
    cuantasCallesTransita(Linea, Cantidad),
    plus(Linea, Plus),
    Costo is (25 * Cantidad + Plus).

cuantasCallesTransita(Linea, Cantidad):-
    recorrido(Linea,_,_),
    findall(Calle, recorrido(Linea,_, Calle), Calles),
    length(Calles, Cantidad).

plus(Linea, 50):-
    recorrido(Linea, gba(Zona1),_),
    recorrido(Linea, gba(Zona2),_),
    Zona1 \= Zona2.

plus(Linea, 0):-
    recorrido(Linea, gba(_),_),
    findall(Zona, recorrido(Linea, gba(Zona),_), Zonas),
    length(Zonas, 1).

costoConBeneficio(Linea, Beneficio, Costo):-
    recorrido(Linea,_,_),
    not(beneficio(Beneficio, Linea,_)),
    costo(Linea, Costo).

costoConBeneficio(Linea, Beneficio, Costo):-
    recorrido(Linea,_,_),
    beneficio(Beneficio, Linea, Costo).

mayorDescuento(Persona, Linea, Costo):-
    recorrido(Linea,_,_),
    not(beneficiario(Persona,_)),
    costo(Linea, Costo).

mayorDescuento(Persona, Linea, Costo):-
    beneficiario(Persona, Beneficio),
    costoConBeneficio(Linea, Beneficio, Costo),
    forall((beneficiario(Persona, OtroBeneficio), costoConBeneficio(Linea, OtroBeneficio, OtroCosto)), Costo =< OtroCosto).

cuantoPaga(Persona, Linea, Costo):-
    mayorDescuento(Persona, Linea, Costo).