libname BDDhotel "/home/xxxxxxxxx/Hotels";

										/*Analyse en Composantes Principales*/
				/*Objectif: réduire la dimension des données en conservant au mieux l’information utile*/

/*-------------------------------------------------------------------------------------------------------------------------------------------*/											

						/*Exploration préliminaire: Sélection des statistiques descriptives*/ 

/* 1. Analyse univariée restituant les principaux indicateurs de position (moyenne) et de dispersion (écart-type & étendue) ainsi que le nbre d'observation des 8 variables quantitatives initiales.*/
proc means data=bddhotel.hotels MAXDEC=2; run;
/* Résultat :
Choix porté sur 7 variables quantitatives basées sur les 'notes' qui sont "liées" entre elles :equipement, chambre, reception, restaurant, calme, transport, propreté*/

/* 2. Analyse bivariée permettant de mesurer et d'interpréter les liens entres les 7 variables via une matrice des corrélations*/
proc corr data=bddhotel.hotels; var equipement chambre reception restaurant calme transports proprete prix; run;
/* Résultat :
Les corrélations linéaires entre les variables sont positives et négatives, certaines étant très fortes (0.93) d’autres moyennes (0.7 et 0.65), néanmoins la plupart sont faibles (0.01 et 0.0).*/


											/* ACP: lancement*/ 

options sasmstore=BDDhotel mstored;
data hotels; set BDDhotel.hotels;run;

%acp(dataact=hotels,
varact=equipement chambre reception restaurant calme transports proprete, varsup=prix,
id=nom, impress=O, corr=O, vecp=max, ioa=3, iva=3, ivs=3, classes=villes, axeclas=3, out=sor, naxer=3, fill=var ind bary);

proc princomp data=hotels n=7
vardef=n
plots(ncomp=3)=(patternprofile pattern(vector) score);
id nom;
var equipement chambre reception restaurant calme transports proprete; /*liste des var actives*/
run;

title1 "Cercle de corrélation des 7 variables initiales dans les composantes principales: 'Service' & 'Qualité' ";
%plotACP(data=sor, AXEH=1, AXEV=2, POINTS=varact varsup);
title1 " ";

title2 "Cercle de corrélation des 7 variables initiales dans les composantes principales: 'Service' & 'Tranquillité'";
%plotACP(data=sor, AXEH=1, AXEV=3, POINTS=varact varsup);
title2 " ";

title2 "Cercle de corrélation des 46 observations & des 7 variables initiales dans les composantes principales : 'Service' & 'Qualité'";
%plotACP(data=sor, AXEH=1, AXEV=2, POINTS=obsact varact);
title2 " ";

title2 "Cercle de corrélation des 46 observations & des 7 variables initiales dans les composantes principales : 'Service' & 'Tranquillité'";
%plotACP(data=sor, AXEH=1, AXEV=3, POINTS=obsact varact);
title2 " ";










															/* ACP normée*: Axes factoriels */ 

*/ *normée: les variables intiales sont centrées-réduites par défaut: on choisit de donner le même poids 1n à toutes les observations.*															
															
/* 3.-4. Détermination du nbre d'axes factoriels depuis la table "Valeurs propres de la matrice de corrélation" ou via le diagramme des valeurs propres (Règle de Cattell) 
/* Résultat :		
-	Trois axes factoriels (ou composantes principales) sont les combinaisons linéaires des variables initiales.
-	Représentant 84% de l'inertie (variance) totale du nuage qui maximise la dispersion des observations vis à vis de son centre de gravité:
	-	Axe 1 (CP1) : valeur propre = 2.31613264 / cumul = 33%
	-	Axe 2 (CP2) : valeur propre = 2.03498665 / cumul = 62%
	-	Axe 3 (CP3) : valeur propre = 1.51138929 / cumul = 84%
*/

											/* ACP: Variables initiales */ 
														
/* 5. Analyse des varaibles & interprétion des axes factoriels

/* Résultat des variables les plus représentatives sur les axes factoriels :

-	les trois variables initiales les plus contributives à l'inertie totale (variance totale), les meilleures qualités de projection et coefficient de corrélation sur l'axe 1 (CP1):
	>AXE 1 (CP1):															
	-	1° RESTAURANT : COS2 & QLT = 74.3 // CTR = 32.1 // coeff. correlation = 0.86						
	-	2° EQUIPEMENT : COS2 & QLT = 60.6 // CTR = 26.2 // coeff. correlation = 0.78							
 	-	3° CHAMBRE : COS2 & QLT = 59.2  // CTR = 25.6 // coeff. correlation = 0.77			

/* 6. Analyse des varaibles & interprétion des axes factoriels
-	Interprétation de l'axe 1 (CP1) : 
	-	La corrélation est positive et forte (>0,7) pour les évaluations 'restaurant', 'équipement' et 'chambre'
	-	La corrélation est positive et moyenne (0,4) pour les évaluations 'propreté', 'réception'
	-	La corrélation est positive et faible (0,2) pour l'évaluation 'transport'
	-	La corrélation est négative et faible (0,2) pour l'évaluation 'calme'
-	Conclusion:
	-	L'Axe 1 équivaut au service du séjour dans l'hotel (bien équipé, chambre confortable, restauration de qualité).

-	Interprétation de l'axe 2 (CP2) : 
	-	La corrélation est positive et forte (>0,7) pour les évaluations 'propreté', 'réception'
	-	La corrélation est positive et moyenne (0,4) pour l'évaluation 'transport'
	-	La corrélation est négative et faible - moyenne (0,3) pour les évaluations 'calme', 'équipement' et 'chambre'
	-	La corrélation est négative et faible (0,1) pour l'évaluation 'restaurant'
-	Conclusion:
	-	L'Axe 2 équivaut à la qualité du séjour dans l'hotel (propre et accueillant).

-	Interprétation de l'axe 3 (CP3) : 
	-	La corrélation est positive et forte (>0,7) pour l'évaluation 'calme'
	-	La corrélation est négative et forte (>0,7) pour l'évaluation 'transport'
	-	La corrélation est positive et moyenne (0,4) pour les évaluations 'propreté', 'réception'
	-	La corrélation est positive et faible (0,4) pour les évaluations 'équipement', 'chambre'
	-	La corrélation est négative et faible (0,1) pour l'évaluation 'restaurant'
-	Conclusion:
	-	L'Axe 3 équivaut à la tranquillité du séjour dans l'hotel (calme ou bien desservi).

/* 7. Représentation des variables initiales sur les axes factoriels:
	-	Via le cercle des corrélation généré via les instructions princomp (ligne 32) & dans la macro %plotACP (lignes 38 & 42)

/* 8. Nom des 3 composantes principales:
	-	Axe 1 (CP1) : 'Service'
	-	Axe 2 (CP2) : 'Qualité'
	-	Axe 3 (CP3) : 'Tranquillité'











											/* ACP: nuage des Observations */ 

/* 9. Contribution des observations à l'inertie totale du nuage par axes:

	- Observations "parasites" pouvant biaiser la lecture:
	>AXE 'Service' (CP1) :
	- l’obs H33 (CTR = 10.6), très excentrée (, « tire » l’axe factoriel vers elle*/ 
	>AXE 'Qualité' (CP2):
	- les obs H40 (CTR = 15.7) & H44 (CTR = 10), très excentrées, ont un fort impact sur l'orientation de l'axe*/
	>AXE 'Tranquillité' (CP3):
	- l’obs H36 (CTR = 11.4), très excentrée, « tire » l’axe factoriel vers elle*/
	
	- Observations les plus contributives:
	>AXE 'Service' (CP1) :
	-	Positivement : obs H43, H41, H23 // Négativement : obs H34
	>AXE 'Qualité' (CP2):
	-	Positivement : obs H2, H3, H45 // Négativement : obs H10
	>AXE 'Tranquillité' (CP3):
	-	Positivement : obs H45, H9, H10 // Négativement : obs H31
	
/* 10. Représentation graphique des observations sur les axes factoriels:
	-	Via le cercle des corrélation généré via les instructions princomp (ligne 32) & dans la macro %plotACP (ligne 46)
			
/* 11. Qualité de représentation des observations sur les axes factoriels
	-	Observations les mieux représentées (positivement):
	>AXE 'Service' (CP1) :
	- les obs H34 (COS2 = 86), H23 (COS2 = 68.4)
	>AXE 'Qualité' (CP2) :	
	- les obs H34 (COS2 = 86), H12 (COS2 = 73), H17 (COS2 = 78)
	>AXE 'Tranquillité' (CP2) :	
	- les obs H43 (COS2 = 68)

/* 12. Mini-synthèse:
- Les établissements situés en haut à droite sont ceux offrant le meilleur confort (service & qualité) et les plus calmes .
- Les établissements situés en bas à droite sont ceux offrant le meilleur rapport service-tranquillité et les mieux desservis.
- Les établissements situés en haut à gauche sont ceux offrant le meilleure qualité et les plus calmes.
- Les établissements situés en bas à gauche sont ceux offrant le meilleur service et les mieux desservis.
*/

									/* ACP: Observations supplémentaires & Variables illustratives */ 

/*13 
>>obs H45 & H46 sont déjà présentes dans le jeu de données (sinon rajout des paramètres 'obssup' & 'ios' )
/* 14 & 15
>>Rajout des paramètres 'varsup' =ville prix & 'iva'=3 dans les macros ACP & PLOTACP
La variable illustrative 'prix' est corrélée positivement avec le 'service'					
